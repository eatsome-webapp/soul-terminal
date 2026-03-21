# Phase 8: Session Management - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Tab bar bovenaan de terminal sheet voor sessie-navigatie. ViewPager2 voor swipe tussen sessies. Process namen live gelezen uit `/proc/PID/cmdline`. SOUL chat kan sessies aanmaken, sluiten en wisselen via Pigeon. Vervangt de drawer-gebaseerde sessielijst als primaire sessie-navigatie.

</domain>

<decisions>
## Implementation Decisions

### Tab bar design
- TabLayout tussen drag handle (48dp) en terminal content in de sheet LinearLayout
- Scrollable tabs (`TabLayout.MODE_SCROLLABLE`) — onbeperkt aantal sessies
- Compact hoogte: 36dp
- SOUL kleuren: #0F0F23 achtergrond, #6C63FF selected indicator, #E0E0E0 tab tekst
- `+` knop als vaste knop rechts van de tabs (niet als tab item) — altijd zichtbaar

### Tab content
- Tab label toont process naam uit `/proc/PID/cmdline` (polling interval 2s)
- Fallback: `TerminalSession.mSessionName` of "Session N" als cmdline niet leesbaar
- Lang-indrukken op tab: context menu met "Hernoemen" en "Sluiten"
- Actieve sessie visueel onderscheiden met #6C63FF underline indicator

### Drawer coëxistentie
- Drawer behouden alleen voor settings — sessie-lijst (ListView `terminal_sessions_list`) en "New session" knop verwijderen uit drawer
- Settings button verplaatsen naar tab bar area (overflow menu of icoon in drag handle) — drawer-swipe conflicteert met ViewPager2 horizontale swipe
- Drawer swipe-from-edge uitschakelen (`setDrawerLockMode(LOCK_MODE_LOCKED_CLOSED)`) om conflict met ViewPager2 te voorkomen

### Session switching mechanisme
- TabLayout + ViewPager2 gekoppeld via `TabLayoutMediator`
- Geen FragmentStateAdapter — TerminalView is een enkele view die van sessie wisselt via `setCurrentSession()`; ViewPager2 adapter swapt de backing `TerminalSession`
- Swipe links/rechts wisselt sessie (SESS-05)
- Bij sluiten actieve sessie: verschuif naar vorige tab, of volgende als eerste tab gesloten wordt

### Pigeon API uitbreiding
- `TerminalBridgeApi` (HostApi) uitbreiden met: `closeSession(int id)`, `switchSession(int id)`, `renameSession(int id, String name)`
- `SoulBridgeApi` (FlutterApi) uitbreiden met: `onSessionListChanged(List<SessionInfo>)` — Flutter blijft in sync bij Java-side sessie changes
- Bestaande `createSession()` en `listSessions()` blijven ongewijzigd

### Claude's Discretion
- Exacte ViewPager2 adapter implementatie (hoe TerminalView content swapt per page)
- Polling mechanisme voor `/proc/PID/cmdline` (Handler + Runnable of ScheduledExecutor)
- Tab animatie en transition stijl
- Context menu implementatie (PopupMenu vs AlertDialog)
- Hoe settings button visueel in drag handle of tab bar past

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Session management (bestaand)
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` — `addNewSession()`, `removeFinishedSession()`, `setCurrentSession()`, `switchToSession()`, `renameSession()` — alle bestaande sessie-logica
- `app/src/main/java/com/termux/app/terminal/TermuxSessionsListViewController.java` — Huidige drawer-gebaseerde sessie-lijst (te vervangen door tab bar)
- `app/src/main/java/com/termux/app/TermuxService.java` — `createTermuxSession()`, `mShellManager.mTermuxSessions` — sessie lifecycle op service level

### Pigeon bridge (uit te breiden)
- `flutter_module/pigeons/terminal_bridge.dart` — Pigeon definitie: `TerminalBridgeApi` (HostApi) + `SoulBridgeApi` (FlutterApi) + `SessionInfo` data class
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — Java implementatie van HostApi: `createSession()`, `listSessions()`, `executeCommand()`, `getTerminalOutput()`
- `flutter_module/lib/generated/terminal_bridge.g.dart` — Generated Dart code

### Layout (sheet architectuur)
- `app/src/main/res/layout/activity_termux.xml` — CoordinatorLayout + sheet: drag handle → terminal content. Tab bar wordt ingevoegd tussen drag handle en RelativeLayout
- `app/src/main/java/com/termux/app/TermuxActivity.java` — `getBottomSheetBehavior()` (r1020), `setupBottomSheet()` (r641)

### Terminal view
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — Terminal rendering, NestedScrollingChild3 (Phase 7)

### Dependencies
- `app/build.gradle` — Huidige dependencies; ViewPager2:1.1.0 moet worden toegevoegd

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **TermuxTerminalSessionActivityClient**: Bevat alle sessie-operaties (`addNewSession`, `removeFinishedSession`, `setCurrentSession`, `switchToSession`, `renameSession`) — tab bar roept deze aan
- **TerminalBridgeImpl**: Heeft al `createSession()` en `listSessions()` — uitbreiden met close/switch/rename
- **SessionInfo Pigeon class**: Al gedefinieerd met `id`, `name`, `isRunning` — herbruikbaar voor tab state
- **Material 1.12.0**: Bevat `TabLayout` out-of-the-box
- **TermuxSessionsListViewController**: Huidige ArrayAdapter met sessie-rendering logica — tab label logica kan hieruit geëxtraheerd worden

### Established Patterns
- **Java only**: Geen Kotlin, consistent houden
- **Layout via XML**: Tab bar als XML element toevoegen in `activity_termux.xml`
- **Pigeon bridge**: Definitie in `flutter_module/pigeons/terminal_bridge.dart`, genereren naar Java + Dart
- **Handler(Looper.getMainLooper()).post{}**: Pigeon calls vanuit achtergrond threads (CP-4 uit STATE.md)
- **ListView + BaseAdapter**: Huidige sessie-lijst, wordt vervangen door TabLayout

### Integration Points
- **`activity_termux.xml`**: TabLayout invoegen als nieuw child van `terminal_sheet_container`, tussen `sheet_drag_handle` en `activity_termux_root_relative_layout`
- **`TermuxActivity.java`**: Tab bar initialisatie, ViewPager2 setup, TabLayoutMediator koppeling
- **`TermuxTerminalSessionActivityClient`**: `setCurrentSession()` koppelen aan tab selection events
- **DrawerLayout**: Swipe lock mode instellen, sessie-gerelateerde UI verwijderen
- **Pigeon bridge**: 3 nieuwe HostApi methods + 1 nieuwe FlutterApi method

</code_context>

<specifics>
## Specific Ideas

- Tab bar moet visueel aansluiten bij de drag handle — donkere achtergrond (#0F0F23), subtiel gescheiden
- Process namen in tabs geven directe context: "claude", "bash", "python" in plaats van generieke "Session 1"
- ViewPager2 swipe moet soepel aanvoelen — geen conflict met terminal scroll (verticaal) of drawer (horizontaal, wordt gelocked)
- Drawer verliest zijn primaire functie (sessie-navigatie) maar settings moet bereikbaar blijven

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-session-management*
*Context gathered: 2026-03-21*
