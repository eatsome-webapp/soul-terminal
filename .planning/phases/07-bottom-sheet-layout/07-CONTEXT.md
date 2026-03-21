# Phase 7: Bottom Sheet Layout - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

CoordinatorLayout refactor van `TermuxActivity`. Flutter (SOUL chat) wordt het fullscreen hoofdscherm; de terminal schuift omhoog als een persistent BottomSheet. Vervangt het huidige binary toggle (GONE/VISIBLE) tussen terminal en Flutter. Legt de visuele architectuur voor alle volgende fasen (session tabs, awareness UI, UX polish).

</domain>

<decisions>
## Implementation Decisions

### Layout architectuur
- `TermuxActivity` root layout refactoren van `TermuxActivityRootView` (LinearLayout) naar `CoordinatorLayout`
- `FlutterFragment` als fullscreen achtergrond (vervangt huidige `flutter_container` FrameLayout met `visibility=gone`)
- Terminal container (huidige `activity_termux_root_relative_layout` + DrawerLayout + TerminalView + extra keys) als `BottomSheetBehavior` child
- Binary toggle (`toggleFlutterView()` met GONE/VISIBLE) volledig vervangen door sheet state management
- `TermuxActivityRootView` (custom LinearLayout) evalueren: mogelijk vervangen door CoordinatorLayout direct, of nesten

### Sheet states
- 4 states: hidden, collapsed/peek (48dp handle zichtbaar), half-expanded (40% schermhoogte), expanded (fullscreen)
- Default state bij app start: collapsed/peek — alleen handle bar zichtbaar, SOUL chat fullscreen erachter
- `BottomSheetBehavior.STATE_HIDDEN`, `STATE_COLLAPSED`, `STATE_HALF_EXPANDED`, `STATE_EXPANDED`
- `peekHeight = 48dp` (handle bar hoogte)
- `halfExpandedRatio = 0.4f`

### Touch conflict resolutie
- Dedicated `BottomSheetDragHandleView` als exclusieve swipe-zone bovenaan het terminal sheet
- TerminalView mag GEEN vertical swipes doorlaten naar BottomSheetBehavior — terminal scroll moet altijd winnen
- `NestedScrollingChild3` implementatie toevoegen aan `TerminalView` (terminal-view module)
- Handle bar is de enige manier om sheet te slepen — finger op terminal scrollt terminal content

### IME (keyboard) handling
- `windowSoftInputMode="adjustPan"` instellen in AndroidManifest voor TermuxActivity
- `ViewCompat.setOnApplyWindowInsetsListener` op sheet container voor correcte inset handling
- Keyboard mag sheet niet omhoog duwen voorbij expanded state
- Terminal content moet zichtbaar blijven boven keyboard in expanded en half-expanded state

### Back button gedrag
- Expanded sheet: back → collapsed/peek state
- Half-expanded sheet: back → collapsed/peek state
- Collapsed/peek sheet: back → standaard (app sluiten of drawer handling)
- Vervangt huidige `onBackPressed()` die `toggleFlutterView()` aanroept

### Terminal process continuïteit
- Terminal sessie (TermuxService, TermuxSession) draait ongeacht sheet state — dit is al het geval (service-bound)
- Sheet state wijzigingen mogen terminal process NOOIT onderbreken
- TerminalView moet correct her-renderen bij sheet state transitions (onLayout/onSizeChanged)

### Claude's Discretion
- Exacte animatie duration/interpolator voor sheet transitions
- Handle bar visueel ontwerp (kleur, breedte, hoogte van de pill indicator)
- Of DrawerLayout genest blijft binnen sheet of apart behandeld wordt
- Exacte implementatie van NestedScrollingChild3 delegate methods in TerminalView
- Of `TermuxActivityRootView` behouden of vervangen wordt

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Layout en Activity
- `app/src/main/res/layout/activity_termux.xml` — Huidige layout: TermuxActivityRootView → RelativeLayout (terminal+drawer) + FrameLayout (flutter_container)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — Activity code: FlutterFragment setup (r631), toggleFlutterView (r653), onBackPressed (r791), setupPigeonBridges (r681)
- `app/src/main/java/com/termux/app/terminal/TermuxActivityRootView.java` — Custom root view (LinearLayout subclass)

### Terminal rendering
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — Terminal rendering view, touch handling, scroll — moet NestedScrollingChild3 krijgen
- `app/src/main/java/com/termux/app/terminal/io/TerminalToolbarViewPager.java` — Extra keys toolbar (ViewPager)
- `termux-shared/src/main/java/com/termux/shared/termux/extrakeys/ExtraKeysView.java` — Extra keys view

### Dependencies
- `app/build.gradle` r31 — `com.google.android.material:material:1.12.0` (bevat CoordinatorLayout + BottomSheetBehavior)

### Kritieke pitfalls (uit v1.1 research)
- `.planning/STATE.md` §Accumulated Context — CP-1 (IME): `adjustPan` + `ViewCompat.setOnApplyWindowInsetsListener`
- `.planning/STATE.md` §Accumulated Context — CP-2 (touch): dedicated drag handle + `NestedScrollingChild3`

### Prior phase decisions
- `.planning/phases/06-app-merge/06-CONTEXT.md` — UncontrolledProviderScope pattern, FlutterFragment init flow, SoulBridgeApi lifecycle
- `.planning/phases/05-terminal-quick-wins/05-CONTEXT.md` — SOUL kleurthema waarden (#0F0F23, #E0E0E0, #6C63FF)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Material 1.12.0**: Al als dependency — bevat `CoordinatorLayout`, `BottomSheetBehavior`, `BottomSheetCallback` out-of-the-box
- **FlutterFragment setup**: Cached engine pattern in `setupFlutterFragment()` — kan hergebruikt worden, alleen container ID en placement wijzigen
- **TermuxService binding**: Terminal processen zijn service-bound, niet view-bound — sheet state veranderingen raken processen niet

### Established Patterns
- **Java only**: Alle Android code is Java, geen Kotlin (consistent houden)
- **Layout via XML**: `activity_termux.xml` definieert de view hierarchy — refactor in XML, niet programmatisch
- **DrawerLayout**: Sessie-lijst zit in een DrawerLayout die genest is in de terminal container — moet mee in het sheet
- **Extra keys**: ViewPager-based toolbar onder terminal, `visibility=gone` by default — moet mee in sheet container
- **FlutterFragment lifecycle**: Fragment wordt toegevoegd in `onCreate()` → `setupFlutterFragment()`, niet lazy

### Integration Points
- **`activity_termux.xml`**: Volledige layout refactor nodig — van LinearLayout root naar CoordinatorLayout
- **`TermuxActivity.java`**: `toggleFlutterView()` vervangen door sheet state management, `onBackPressed()` aanpassen
- **`TerminalView.java`**: `NestedScrollingChild3` interface toevoegen (terminal-view module)
- **`AndroidManifest.xml`**: `windowSoftInputMode="adjustPan"` toevoegen aan TermuxActivity entry
- **Phase 8 dependency**: Tab bar komt bovenaan het terminal sheet — layout moet hier ruimte voor laten

</code_context>

<specifics>
## Specific Ideas

- Handle bar moet de SOUL kleur pill tonen (#6C63FF) op donkere achtergrond (#0F0F23) — consistent met Phase 5 branding
- Sheet moet "soepel" animeren — geen jank bij transitions, vooral niet bij half-expanded ↔ expanded
- Terminal extra keys balk moet mee bewegen met het sheet — altijd onderaan de terminal content
- DrawerLayout (sessie-lijst) blijft functioneel binnen het sheet voor backward compatibility tot Phase 8 het vervangt met tab bar

</specifics>

<deferred>
## Deferred Ideas

- Tab bar bovenaan terminal sheet — Phase 8 (Session Management)
- Velocity-based sheet expand (snel vegen = altijd fullscreen) — Phase 11 (UX Polish, UXPL-03)
- Blur effect achter sheet — Phase 11 (UX Polish, UXPL-04)
- Haptic feedback bij sheet transitions — Phase 11 (UX Polish, UXPL-05)
- Landscape side drawer layout — Phase 11 (UX Polish, UXPL-06)

</deferred>

---

*Phase: 07-bottom-sheet-layout*
*Context gathered: 2026-03-21*
