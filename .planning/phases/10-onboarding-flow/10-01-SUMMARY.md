---
phase: 10-onboarding-flow
plan: "01"
subsystem: ui
tags: [flutter, riverpod, pigeon, go_router, setup-wizard, onboarding]

requires:
  - phase: 08-session-management
    provides: Pigeon terminal bridge (TerminalBridgeApi) with session management methods

provides:
  - SetupWizardScreen with 7-step fullscreen wizard (no AppBar)
  - SetupWizardProvider (keepAlive Riverpod notifier) with full state management
  - /setup-wizard GoRouter route
  - First-run detection in main.dart via SettingsKeys.setupCompleted
  - writeShellConfig Pigeon method for safe file I/O (append mode, Java FileOutputStream)

affects: [10-02, 10-03, 11-ux-polish]

tech-stack:
  added: []
  patterns:
    - "SetupWizardStep enum drives step routing via _advanceToNextStep() with conditional skip logic"
    - "Manually generated .g.dart file following soul_awareness_service.g.dart pattern (cmd-proxy unavailable)"
    - "PopScope wraps Scaffold to prevent back during isInstalling state"

key-files:
  created:
    - flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart
    - flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart
    - flutter_module/lib/ui/setup_wizard/setup_wizard_provider.g.dart
  modified:
    - flutter_module/lib/services/database/daos/settings_dao.dart
    - flutter_module/lib/main.dart
    - flutter_module/lib/core/router/app_router.dart
    - flutter_module/pigeons/terminal_bridge.dart
    - flutter_module/lib/generated/terminal_bridge.g.dart
    - app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java

key-decisions:
  - "writeShellConfig gebruikt Java FileOutputStream in append mode — geen shell escaping nodig, veilig voor speciale tekens"
  - "Handmatig gegenereerde .g.dart file: build_runner niet uitvoerbaar zonder cmd-proxy (niet beschikbaar), patroon exact gevolgd van soul_awareness_service.g.dart"
  - "terminalOnly profiel slaat installing stap over via _advanceToNextStep(), niet via aparte code path"
  - "Xiaomi battery stap conditioneel via isXiaomi flag (SystemBridgeApi.getDeviceInfo().manufacturer)"

requirements-completed: [ONBR-01, ONBR-07]

duration: 35min
completed: 2026-03-21
---

# Phase 10 Plan 01: Setup wizard infrastructure Summary

**GoRouter /setup-wizard route + SettingsKeys first-run detection + SetupWizardProvider (7-step Riverpod notifier) + SetupWizardScreen (fullscreen ConsumerStatefulWidget) + writeShellConfig Pigeon method met Java FileOutputStream append**

## Performance

- **Duration:** 35 min
- **Started:** 2026-03-21T13:30:00Z
- **Completed:** 2026-03-21T14:05:00Z
- **Tasks:** 7
- **Files modified:** 9

## Accomplishments

- Eerste app-start routeert naar /setup-wizard wanneer setup_completed niet in SettingsDao staat
- SetupWizardScreen: volledige 7-stap wizard met profielkeuze (Claude Code/Python/Terminal), installatielogger, API key validatie, GitHub CLI auth, Xiaomi battery-instructies, shell config, voltooiingsscherm
- writeShellConfig Pigeon method toegevoegd voor veilig schrijven naar .bashrc/.zshrc zonder shell escaping

## Task Commits

1. **Task 10-01-01: Add setupCompleted key to SettingsKeys** - `706c6d34` (feat)
2. **Task 10-01-02: Add first-run check to main.dart** - `2c8da3d5` (feat)
3. **Task 10-01-03: Add /setup-wizard route to GoRouter** - `3521f281` (feat)
4. **Task 10-01-04: Create SetupWizardProvider** - `e899d5e7` (feat)
5. **Task 10-01-05: Add writeShellConfig to Pigeon** - `ee050bb5` (feat)
6. **Task 10-01-06: Create SetupWizardScreen** - `1b353d28` (feat)
7. **Task 10-01-07: Generate Riverpod codegen** - `de047778` (feat)

## Files Created/Modified

- `flutter_module/lib/services/database/daos/settings_dao.dart` — setupCompleted en setupProfile constanten toegevoegd
- `flutter_module/lib/main.dart` — first-run check, routes naar /setup-wizard bij afwezige setupCompleted vlag
- `flutter_module/lib/core/router/app_router.dart` — /setup-wizard GoRoute toegevoegd
- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart` — SetupWizardState, SetupWizardStep enum, SetupWizard notifier (keepAlive)
- `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — fullscreen wizard widget (7 stappen, AnimatedSwitcher, PopScope)
- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.g.dart` — handmatig gegenereerd, NotifierProvider patroon
- `flutter_module/pigeons/terminal_bridge.dart` — writeShellConfig methode definitie
- `flutter_module/lib/generated/terminal_bridge.g.dart` — writeShellConfig Dart implementatie (BasicMessageChannel)
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — writeShellConfig Java implementatie (FileOutputStream append)

## Decisions Made

- **writeShellConfig append mode:** Java FileOutputStream(file, true) — geen shell escaping nodig, veilig voor OSC 133 escape sequences in shell config
- **Handmatige .g.dart generatie:** cmd-proxy niet beschikbaar, build_runner niet uitvoerbaar; exact patroon gevolgd van bestaand soul_awareness_service.g.dart
- **terminalOnly skip logic:** _advanceToNextStep() itereert over stappen en slaat `installing` over voor terminalOnly profiel — centrale logica, geen code duplicatie
- **Xiaomi detectie:** SystemBridgeApi().getDeviceInfo() in _detectDevice() bij build(), async zonder te blokkeren

## Deviations from Plan

None — plan uitgevoerd exact zoals geschreven.

## Issues Encountered

None

## User Setup Required

None — geen externe services, alles lokaal op het apparaat.

## Next Phase Readiness

- Setup wizard infrastructuur klaar voor plan 10-02 (installatie steps invullen)
- SetupWizardProvider.startInstallation() roept al TerminalBridgeApi.runCommand() aan — plan 02 kan direct integreren
- writeShellConfig Pigeon method beschikbaar voor plan 02 shell config stap
- Alle ONBR-01 en ONBR-07 requirements geleverd

---
*Phase: 10-onboarding-flow*
*Completed: 2026-03-21*
