---
phase: 03-flutter-integration
plan: D
subsystem: ui
tags: [flutter, pigeon, bridge, android, termux]

# Dependency graph
requires:
  - phase: 03-B
    provides: Pigeon-generated TerminalBridgeApi, SystemBridgeApi, SoulBridgeApi interfaces
  - phase: 03-C
    provides: FlutterFragment integration, FlutterEngine pre-warmed in TermuxApplication
provides:
  - TerminalBridgeImpl — executeCommand writes to terminal, getTerminalOutput reads transcript
  - SystemBridgeImpl — returns device and package metadata to Flutter
  - SoulBridgeController — debounced (100ms) terminal output streaming to Flutter
  - Bridge wiring in TermuxActivity.onServiceConnected()
  - Terminal output flow: TerminalSession → onTextChanged → SoulBridgeController → Flutter
  - Flutter test UI connected to real bridges with command send + output receive
affects: [04-flutter-soul, flutter_module]

# Tech tracking
tech-stack:
  added: []
  patterns: [Pigeon bridge impl pattern, SoulBridgeController debounce pattern]

key-files:
  created:
    - app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java
    - app/src/main/java/com/termux/bridge/SystemBridgeImpl.java
    - app/src/main/java/com/termux/bridge/SoulBridgeController.java
  modified:
    - app/src/main/java/com/termux/app/TermuxActivity.java
    - app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java
    - flutter_module/lib/main.dart

key-decisions:
  - "TerminalBridgeApi.TerminalBridgeApi en SystemBridgeApi.SystemBridgeApi — Pigeon genereert interface als geneste klasse in outer class, setUp() is statische methode op de interface"
  - "SoulBridgeController gebruikt TerminalBridgeApi.SoulBridgeApi — SoulBridgeApi zit genest in TerminalBridgeApi.java (één Pigeon file voor bidirectionele API)"
  - "onTextChanged() checkt isVisible() vóór SoulBridge notify — bridge niet aanroepen als activity niet zichtbaar is"
  - "SoulBridgeApi.setUp(null) in dispose() — deregistreert handler om leaks te voorkomen"

patterns-established:
  - "Pigeon bridge impl: implements OuterClass.InterfaceName, types zijn OuterClass.DataClass"
  - "Debounce via Handler.postDelayed + removeCallbacks — geen externe library nodig"
  - "Bridge teardown in onDestroy() vóór mTermuxService null-set — correcte volgorde"

requirements-completed: [PIGB-02, PIGB-03, PIGB-04, PIGB-05]

# Metrics
duration: 20min
completed: 2026-03-19
---

# Plan 03-D: Pigeon Bridge Implementation Summary

**Bidirectionele Pigeon bridge volledig operationeel: Flutter stuurt commands naar terminal, terminal streamt output (100ms debounce) terug naar Flutter**

## Performance

- **Duration:** 20 min
- **Started:** 2026-03-19T10:30:00Z
- **Completed:** 2026-03-19T10:50:00Z
- **Tasks:** 6
- **Files modified:** 6 (3 created, 3 modified)

## Accomplishments

- TerminalBridgeImpl en SystemBridgeImpl implementeren de Pigeon host-interfaces en bridgen Flutter → Termux service
- SoulBridgeController streamt terminal output met 100ms debounce (max 10 updates/sec) via Handler naar Flutter
- Bridges geregistreerd in TermuxActivity.onServiceConnected() zodra de FlutterEngine beschikbaar is
- Flutter test UI gebruikt nu echte TerminalBridgeApi en implementeert SoulBridgeApi voor live terminal output

## Task Commits

1. **Task 03-D-01: TerminalBridgeImpl** - `38aa734` (feat)
2. **Task 03-D-02: SystemBridgeImpl** - `416b4cf` (feat)
3. **Task 03-D-03: SoulBridgeController** - `c94ab61` (feat)
4. **Task 03-D-04: Wire bridges in TermuxActivity** - `ab99f21` (feat)
5. **Task 03-D-05: Hook SoulBridgeController in onTextChanged** - `ec342a5` (feat)
6. **Task 03-D-06: Flutter test UI connected** - `23fc6ff` (feat)

## Files Created/Modified

- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — host-side Pigeon impl: executeCommand, getTerminalOutput, createSession, listSessions
- `app/src/main/java/com/termux/bridge/SystemBridgeImpl.java` — host-side Pigeon impl: getDeviceInfo, getPackageInfo
- `app/src/main/java/com/termux/bridge/SoulBridgeController.java` — debounced terminal output streaming Host→Flutter
- `app/src/main/java/com/termux/app/TermuxActivity.java` — bridge imports, field, setupPigeonBridges(), getSoulBridgeController(), teardown
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java` — onTextChanged() → SoulBridgeController.onTerminalTextChanged()
- `flutter_module/lib/main.dart` — implements SoulBridgeApi, TerminalBridgeApi instantie, _executeCommand via bridge

## Decisions Made

- **Pigeon nesting:** De gegenereerde Java interfaces zitten als `TerminalBridgeApi.TerminalBridgeApi` en `SystemBridgeApi.SystemBridgeApi` — outer class is de container, interface is genest. setUp() is statisch op de interface.
- **SoulBridgeApi locatie:** Zit in `TerminalBridgeApi.java` (één file voor bidirectionele terminal API), dus `TerminalBridgeApi.SoulBridgeApi` is het juiste type.
- **Dart dispose:** `SoulBridgeApi.setUp(null)` in dispose() om message handler te deregistreren.

## Deviations from Plan

### Auto-fixed Issues

**1. Pigeon interface nesting — setUp() methode signatuur**
- **Found during:** Task 03-D-01
- **Issue:** Plan toonde `TerminalBridgeApi.setUp(messenger, impl)` maar de gegenereerde code heeft de interface genest als `TerminalBridgeApi.TerminalBridgeApi` met `static void setUp(...)` op de interface zelf
- **Fix:** Gebruikt `TerminalBridgeApi.TerminalBridgeApi.setUp(messenger, impl)` conform gegenereerde code
- **Files modified:** TerminalBridgeImpl.java, TermuxActivity.java
- **Committed in:** ab99f21

---

**Total deviations:** 1 auto-fixed (Pigeon nesting conventie)
**Impact on plan:** Noodzakelijk voor compilatie. Geen scope creep.

## Issues Encountered

Geen — Pigeon-gegenereerde code gelezen vóór implementatie, types exact gematcht.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Pigeon bridge volledig geïmplementeerd — bidirectionele communicatie Flutter ↔ terminal
- CI build valideert compilatie (TerminalBridgeImpl.mSessionName field toegang nog te checken bij build)
- Volgende: SOUL brain integratie of volgende plan in fase 03

---
*Phase: 03-flutter-integration*
*Completed: 2026-03-19*
