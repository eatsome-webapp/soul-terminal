# Phase 3: Flutter Integration - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Flutter module embedded in the terminal app met werkende Pigeon bridge — AI kan terminal aansturen. Omvat: Flutter module creatie, FlutterEngine pre-warming, FlutterFragment integratie met toggle, Pigeon bridge (TerminalBridge, SoulBridge, SystemBridge), bidirectionele communicatie, cmd-proxy vervanging, en twee-stage CI/CD build.

</domain>

<decisions>
## Implementation Decisions

### Activity Migration
- TermuxActivity migreren van `Activity` naar `FragmentActivity` (AppCompat) — vereist voor FlutterFragment
- AppCompat theme migratie mee-nemen (Theme.Termux moet AppCompat-based worden)
- Minimale wijzigingen aan Termux upstream code — alleen wat nodig is voor FragmentActivity
- TermuxApplication hoeft niet te wijzigen (is al custom Application class)

### Gradle/AGP Upgrade
- AGP upgraden naar 8.x (minimaal 8.1.0) — vereist voor Flutter embedding
- Gradle wrapper upgraden naar 8.x passend bij AGP versie
- compileSdkVersion verhogen naar 34+ (Flutter vereiste)
- Kotlin Gradle plugin toevoegen (Flutter embedding vereist Kotlin support)
- Java source behouden — geen volledige Kotlin migratie, alleen wat Flutter/Pigeon nodig heeft

### View Toggle Mechanism
- FrameLayout container in activity_termux.xml die zowel terminal als FlutterFragment host
- Terminal view en FlutterFragment wisselen via visibility (VISIBLE/GONE) — niet via Fragment replace
- Toggle knop in toolbar of extra keys row
- FlutterFragment persistent (niet elke keer opnieuw aanmaken) — pre-warmed FlutterEngine
- Terminal blijft actief op achtergrond wanneer Flutter zichtbaar is (processen stoppen niet)

### Pigeon API Surface (v1 — minimaal)
- **TerminalBridge** (Flutter → Host):
  - `executeCommand(String command)` → voert commando uit in actieve terminal sessie
  - `getTerminalOutput(int lines)` → haalt laatste N regels terminal output op
  - `createSession()` → maakt nieuwe terminal sessie
  - `listSessions()` → lijst van actieve sessies met metadata
- **SoulBridge** (Host → Flutter):
  - `onTerminalOutput(String output)` → streamt terminal output naar Flutter (debounced, max 10/sec)
  - `onSessionChanged(SessionInfo info)` → notificeert Flutter bij sessie wissel
- **SystemBridge** (Flutter → Host):
  - `getDeviceInfo()` → device metadata voor SOUL context
  - `getPackageInfo()` → app versie en build info
- Pigeon genereert Java (host-side) en Dart (Flutter-side) code
- Schema in `flutter_module/pigeons/` directory

### Flutter Module Structure
- Flutter module als `flutter_module/` subdirectory in project root
- Minimale v1 UI: Material scaffold met bridge test interface (execute command, view output)
- Riverpod voor state management (consistent met SOUL app architectuur)
- Geen volledige SOUL AI UI in deze fase — dat is later milestone
- `settings.gradle` includet flutter module via `:flutter_module`

### CI/CD Two-Stage Build
- Stage 1: Flutter module build (`flutter build aar` of source inclusion via settings.gradle)
- Stage 2: Gradle assembleRelease (terminal + Flutter module samen)
- Beide debug en release workflows bijwerken
- Flutter SDK installatie in GitHub Actions (via `subosito/flutter-action`)

### Claude's Discretion
- Exacte Gradle/AGP versienummers (minimaal 8.x, exacte minor version is implementatiekeuze)
- FlutterEngine caching strategie details
- Debounce implementatie voor terminal output streaming
- Toggle button design en placement
- Error handling in Pigeon bridge calls

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Flutter Add-to-App
- Flutter official docs: "Add Flutter to existing app" (Android) — FlutterFragment, FlutterEngine caching, module structure
- Flutter official docs: "Pigeon" package — type-safe platform channels

### Existing Codebase (critical integration points)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — Main activity, must migrate to FragmentActivity
- `app/src/main/java/com/termux/app/TermuxApplication.java` — Application class, FlutterEngine pre-warming goes here
- `app/src/main/java/com/termux/app/TermuxService.java` — Terminal service, Pigeon host-side interacts with this
- `app/src/main/res/layout/activity_termux.xml` — Layout file, needs FrameLayout for Flutter container
- `app/build.gradle` — AGP/dependencies, major upgrade needed
- `build.gradle` — Root buildscript, AGP plugin version
- `settings.gradle` — Module includes, add flutter_module
- `.github/workflows/debug_build.yml` — CI debug build, needs Flutter stage
- `.github/workflows/release_build.yml` — CI release build, needs Flutter stage

### Project Architecture
- `.planning/PROJECT.md` — Architectuurbeslissing: Termux + FlutterFragment (optie B)
- `.planning/REQUIREMENTS.md` — FLUT-01..05, PIGB-01..05, CICD-03 requirements

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **TermuxService**: Bestaande terminal service met session management — Pigeon host-side wraps deze API's
- **TermuxActivityRootView**: Custom root view met keyboard handling — moet behouden blijven naast Flutter
- **DrawerLayout**: Session list sidebar — blijft werken in terminal mode
- **TerminalView**: Bestaande terminal renderer — wordt GONE wanneer Flutter zichtbaar is

### Established Patterns
- **Java codebase**: Alle source is Java, geen Kotlin. Pigeon genereert Java host-side code, maar Kotlin Gradle plugin is nodig voor Flutter embedding
- **Activity-based**: Geen Fragments in gebruik — migratie naar FragmentActivity is nieuw patroon
- **Service binding**: TermuxActivity bindt aan TermuxService via ServiceConnection — dit patroon blijft, Pigeon bridge wraps de service calls
- **Custom views**: TermuxActivityRootView, TerminalView — complexe view hierarchy die intact moet blijven

### Integration Points
- **TermuxActivity.onCreate()**: FlutterFragment toevoegen aan FrameLayout container
- **TermuxApplication.onCreate()**: FlutterEngine pre-warming
- **TermuxService**: Pigeon TerminalBridge delegeert naar bestaande session/command methods
- **activity_termux.xml**: FrameLayout toevoegen als sibling van bestaande DrawerLayout
- **settings.gradle**: flutter_module include toevoegen
- **app/build.gradle**: Flutter dependency, AGP upgrade, Kotlin plugin

</code_context>

<specifics>
## Specific Ideas

- cmd-proxy (HTTP op port 18790) wordt volledig vervangen door Pigeon bridge — in-process communicatie, geen token/HTTP overhead
- Terminal output debouncing op max 10 updates/sec voorkomt Flutter UI jank
- FlutterEngine pre-warming in Application.onCreate() zorgt voor instant toggle (geen lag bij eerste keer openen)
- Toggle moet instant voelen — daarom visibility swap, niet Fragment recreate

</specifics>

<deferred>
## Deferred Ideas

- Volledige SOUL AI chat UI in Flutter — later milestone (BRAIN-01..03)
- AI command suggestions op basis van terminal context — v2 (SOUL-01)
- Split panes (terminal + Flutter side-by-side) — v2 (ADVT-02)
- Inline image support via Flutter overlay — v2 (ADVT-01)

</deferred>

---

*Phase: 03-flutter-integration*
*Context gathered: 2026-03-19*
