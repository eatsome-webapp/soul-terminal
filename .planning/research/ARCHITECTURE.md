# Architecture Research: SOUL Terminal

## Component Overview

SOUL Terminal bestaat uit 5 duidelijke componenten met heldere grenzen:

### 1. Terminal Emulator Library (`terminal-emulator/`)
Pure Java library, geen Android dependencies. Bevat de core terminal emulatie: `TerminalEmulator`, `TerminalSession`, `TerminalBuffer`, `KeyHandler`, ANSI/VT parsing, Unicode width. Dit is upstream Termux code — minimaal wijzigen.

**Grens:** Communiceert via `TerminalSessionClient` interface (callbacks naar boven) en `TerminalOutput` interface (schrijft bytes naar PTY). Geen kennis van UI, Android, of Flutter.

### 2. Terminal View (`terminal-view/`)
Android `View` subclass (`TerminalView`) die een `TerminalSession` rendert. Handelt touch, keyboard input, scrolling, text selection af. Communiceert met de Activity via `TerminalViewClient` interface.

**Grens:** Kent alleen `TerminalSession` (van terminal-emulator) en de `TerminalViewClient` callback interface. Geen kennis van services, Flutter, of app-logica.

### 3. Termux Shared (`termux-shared/`)
Constants (`TermuxConstants`), settings, preferences, shell utilities, crash handling, logging, extra keys. De "glue" library die door alle modules wordt gebruikt.

**Grens:** Definieert package names, file paths, shared preferences keys. Kernpunt voor rebranding (alles wijst naar `com.soul.terminal` paths).

### 4. App Module (`app/`)
De Android applicatie zelf. Bevat:
- **TermuxActivity** — Hoofd-Activity, host `TerminalView` in een `DrawerLayout`. Bindt aan `TermuxService` via `ServiceConnection`.
- **TermuxService** — Foreground Service die terminal sessions beheert. Overleeft Activity lifecycle.
- **TermuxInstaller** — Bootstrap installer (extracts bootstrap-*.zip naar $PREFIX).
- **Terminal clients** — `TermuxTerminalSessionActivityClient`, `TermuxTerminalViewClient` — bridge tussen view/session callbacks en Activity.
- **Extra Keys** — Toolbar met programmeerbare extra toetsen.

**Grens:** Praat met terminal-emulator via interfaces, met terminal-view via interfaces, met termux-shared voor config/constants.

### 5. Flutter Module (nieuw toe te voegen)
Een apart Flutter module project (`flutter_module/` of `soul_module/`) dat via add-to-app als AAR wordt ingebouwd. Bevat de SOUL AI interface: chat UI, Claude API communicatie, memory layer.

**Grens:** Draait in eigen `FlutterEngine`, gehost via `FlutterFragment` in de App module. Communiceert met de Java/Kotlin host uitsluitend via Pigeon-gegenereerde interfaces.

---

## Integration Points

### A. TermuxActivity ↔ FlutterFragment

De primaire integratie. Twee architectuuropties:

**Optie 1: Split-screen layout (aanbevolen voor v1)**
- `activity_termux.xml` uitbreiden met een `FrameLayout` container voor de `FlutterFragment`
- Toggle-knop om te wisselen tussen terminal-fullscreen, Flutter-fullscreen, of split
- `FlutterFragment` wordt lazy geïnitialiseerd (pas bij eerste gebruik)
- FlutterEngine wordt gecached in `FlutterEngineCache` (via `TermuxApplication`) voor snelle start

**Optie 2: Aparte Activity**
- `SoulActivity` extends `FlutterFragmentActivity`
- Navigatie via drawer of bottom nav
- Eenvoudiger, maar verliest de "één scherm" ervaring

**Aanbeveling:** Optie 1 — `FlutterFragment` in dezelfde Activity, met een ViewSwitcher of FrameLayout overlay.

### B. Pigeon Bridge (Flutter ↔ Host)

Pigeon genereert type-safe interfaces aan beide kanten:

```
┌─────────────────┐         ┌──────────────────┐
│  Flutter Module  │         │   Android Host   │
│                  │         │                  │
│  SoulApi         │◄───────►│  SoulApiImpl     │  (Flutter calls host)
│  (generated)     │         │  (implements)    │
│                  │         │                  │
│  HostApiImpl     │◄───────►│  HostApi         │  (Host calls Flutter)
│  (implements)    │         │  (generated)     │
└─────────────────┘         └──────────────────┘
```

**Kerninterfaces (Pigeon):**

1. **TerminalBridge** (Flutter → Host):
   - `executeCommand(String cmd)` — voer een commando uit in de actieve terminal sessie
   - `readTerminalBuffer()` — lees huidige terminal output
   - `createSession()` / `switchSession(int index)` — sessiebeheer
   - `getEnvironmentVariable(String name)` — lees env vars
   - `sendInput(String text)` — stuur tekst naar terminal stdin

2. **SoulBridge** (Host → Flutter):
   - `onTerminalOutput(String text)` — stream terminal output naar Flutter
   - `onSessionChanged(int index, String title)` — sessie-updates
   - `onAppLifecycleChanged(String state)` — lifecycle events

3. **SystemBridge** (Flutter → Host):
   - `readContacts()`, `readCalendar()` — Android data access
   - `showNotification(...)` — systeem notificaties
   - `getDeviceInfo()` — device metadata

### C. TermuxService ↔ FlutterEngine

FlutterEngine moet in-process communiceren met TermuxService voor terminal access. Twee paden:

1. **Via Activity** — Activity heeft binding met Service, Flutter praat via Pigeon met Activity, Activity delegeert naar Service. Eenvoudig maar Activity moet actief zijn.
2. **Via eigen Service binding** — FlutterEngine draait in een `FlutterEngineService` die direct bindt aan TermuxService. Werkt ook als Activity op de achtergrond is.

**Aanbeveling:** Start met pad 1 (via Activity), migreer naar pad 2 als background processing nodig is.

---

## Data Flow

```
┌─────────────────────────────────────────────────┐
│                  TermuxActivity                  │
│                                                  │
│  ┌──────────┐    ServiceConnection    ┌────────┐│
│  │ Terminal  │◄──────────────────────►│ Termux ││
│  │ View     │                         │ Service││
│  │          │   TerminalViewClient    │        ││
│  │          │◄───────────────────────►│Sessions││
│  └──────────┘   TerminalSessionClient └────────┘│
│       ▲                                    ▲     │
│       │ layout                             │     │
│       │ toggle                      Pigeon │     │
│       ▼                            Bridge  │     │
│  ┌──────────┐                             │     │
│  │ Flutter  │◄────────────────────────────┘     │
│  │ Fragment │   TerminalBridge / SoulBridge      │
│  │ (SOUL)   │                                    │
│  └──────────┘                                    │
└─────────────────────────────────────────────────┘
```

**Informatiestromen:**

1. **User input → Terminal:** Keyboard → TerminalView → TerminalSession → PTY → shell proces
2. **Terminal output → Display:** Shell → PTY → TerminalSession → TerminalSessionClient callback → TerminalView render
3. **Terminal output → SOUL:** Shell → PTY → TerminalSession → Host interceptor → Pigeon `onTerminalOutput` → Flutter SOUL brain
4. **SOUL command → Terminal:** Flutter → Pigeon `executeCommand` → Host → TermuxService → TerminalSession → PTY
5. **SOUL → Claude API:** Flutter → ClaudeService → HTTP → Claude API (direct vanuit Flutter, geen host betrokkenheid)
6. **SOUL → Local memory:** Flutter → Drift SQLite / ObjectBox (in Flutter, eigen databases)

---

## Build Order

Fasering op basis van afhankelijkheden:

### Fase 1: Rebranding (geen nieuwe componenten)
**Afhankelijk van:** niets
- Package name → `com.soul.terminal` in TermuxConstants, build.gradle, manifests
- App naam, icon, theming
- Eigen signing keys
- CI/CD pipeline (GitHub Actions)
- **Output:** werkende SOUL Terminal APK die identiek functioneert aan Termux

### Fase 2: Bootstrap Pipeline
**Afhankelijk van:** Fase 1 (package name moet vast staan)
- Fork termux-packages, wijzig `properties.sh` prefix
- Build bootstrap zips voor aarch64
- Eigen apt repository (GitHub Releases of eigen hosting)
- **Output:** SOUL Terminal installeert eigen packages met com.soul.terminal prefix

### Fase 3: Flutter Module Skeleton
**Afhankelijk van:** Fase 1 (build pipeline)
- Maak Flutter module project (`flutter create --template module`)
- Configureer Gradle: `settings.gradle` include Flutter module
- `FlutterEngine` caching in `TermuxApplication.onCreate()`
- Lege `FlutterFragment` toevoegen aan `TermuxActivity`
- Toggle-knop in drawer of toolbar
- **Output:** Flutter UI (placeholder) zichtbaar naast terminal

### Fase 4: Pigeon Bridge
**Afhankelijk van:** Fase 3 (Flutter module moet bestaan)
- Definieer Pigeon schema (`pigeons/soul_api.dart`)
- Genereer Java/Dart code
- Implementeer `TerminalBridge` aan host-kant (Java)
- Implementeer `SoulBridge` aan Flutter-kant
- **Output:** Flutter kan commando's sturen naar terminal en output ontvangen

### Fase 5: SOUL Brain Integration
**Afhankelijk van:** Fase 4 (Pigeon bridge moet werken)
- Migreer SOUL Flutter code (claude_service, soul_brain, memory) naar module
- Chat UI in Flutter
- Claude API integratie
- Memory layer (Drift + ObjectBox)
- **Output:** volledige SOUL AI interface in de terminal app

### Fase 6: Terminal Enhancements
**Afhankelijk van:** Fase 1 (onafhankelijk van Flutter fases)
- Kitty keyboard protocol
- OSC9 desktop notifications
- Command palette
- Kan parallel met Fase 3-5

---

## Key Technical Decisions

### 1. FlutterEngine lifecycle management
**Beslissing nodig:** Pre-warm de FlutterEngine bij app start, of lazy bij eerste gebruik?
- Pre-warming: snellere eerste open, maar +40MB geheugen vanaf start
- Lazy: langzamere eerste open (~1-2 sec), minder geheugen als gebruiker SOUL niet opent
- **Aanbeveling:** Pre-warm in `TermuxApplication.onCreate()` met `FlutterEngineCache`. Geheugen is geen probleem op Xiaomi 17 Ultra (16GB RAM).

### 2. Java vs Kotlin voor host-side Pigeon
**Beslissing nodig:** Termux is puur Java. Pigeon genereert zowel Java als Kotlin.
- Kotlin toevoegen vereist Kotlin Gradle plugin, vergroot build complexity
- Java-only houdt het simpel en compatible met upstream Termux
- **Aanbeveling:** Java voor Pigeon host-side. Kotlin pas als Android side groeit voorbij Pigeon implementaties.

### 3. Terminal output streaming naar Flutter
**Beslissing nodig:** Hoe stream je terminal output efficiënt naar Flutter?
- `TerminalSessionClient.onTextChanged()` wordt bij elke screen update aangeroepen
- Direct doorsturen via Pigeon zou flooding veroorzaken
- **Aanbeveling:** Debounce/batch terminal output (bijv. max 10 updates/sec), stuur alleen diff of volledige buffer op request. Flutter pollt niet — host pusht via `SoulBridge.onTerminalOutput()`.

### 4. Enkele of meerdere FlutterEngines
**Beslissing nodig:** Eén engine voor alles, of meerdere voor isolatie?
- Meerdere engines: meer geheugen, complexer
- Eén engine: eenvoudiger, alle SOUL logica in één Dart isolate
- **Aanbeveling:** Eén FlutterEngine. SOUL is conceptueel één entiteit.

### 5. Flutter module als source of als AAR
**Beslissing nodig:** Include Flutter module als source dependency of als pre-built AAR?
- Source: makkelijker development, maar vereist Flutter SDK in CI
- AAR: CI bouwt AAR apart, Android project includet als dependency. Complexer maar schonere scheiding.
- **Aanbeveling:** Source dependency voor development snelheid. CI pipeline bouwt alles in één stap. AAR is premature optimization.

### 6. cmd-proxy eliminatie timeline
De Pigeon bridge vervangt uiteindelijk cmd-proxy voor Claude Code ↔ proot-distro communicatie. Dit is pas relevant na Fase 4. Tot die tijd blijft cmd-proxy de werkende oplossing.

---

*Geschreven: 2026-03-19*
