---
phase: 10-onboarding-flow
plan: "02"
subsystem: ui
tags: [flutter, riverpod, pigeon, terminal, onboarding, api-key]

# Dependency graph
requires:
  - phase: 10-01
    provides: SetupWizardProvider stub, SetupWizardScreen shell, TerminalBridgeApi.sendInput, SoulAwareness service

provides:
  - Package installation via sendInput + marker-based polling (OSC 133-free)
  - Real-time output streaming through soulAwareness.outputStream to install log
  - API key format check (sk-ant-) + validateAndSaveKey + app-wide key update via apiKeyNotifierProvider
  - GitHub CLI auth step: openTerminalSheet() + sendInput('gh auth login --web')
  - Xiaomi/HyperOS battery instruction step (conditional on device detection)

affects: [10-03, 11-ux-polish]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - sendInput + echo marker + _waitForMarker for terminal command completion without OSC 133
    - outputStream.listen for real-time terminal output streaming to UI state

key-files:
  created: []
  modified:
    - flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart
    - flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart

key-decisions:
  - "Use sendInput() + marker polling (SOUL_PKG_DONE, SOUL_NPM_DONE) instead of runCommand() — OSC 133 not yet configured at install time"
  - "apiKeyNotifierProvider.notifier.setKey() called immediately after save so rest of app sees new key without restart"
  - "proceedFromInstall() added as public method so screen can advance after installSuccess without exposing _advanceToNextStep"

patterns-established:
  - "Marker pattern: sendInput('cmd && echo MARKER') + _waitForMarker('MARKER') for completion detection pre-OSC 133"
  - "outputStream.listen subscription created in async method, cancelled in finally block"

requirements-completed: [ONBR-02, ONBR-03, ONBR-04, ONBR-05]

# Metrics
duration: 25min
completed: 2026-03-21
---

# Plan 10-02: Package installation, API key, GitHub CLI, HyperOS instructions

**Package install rewritten from runCommand to sendInput+marker polling, API key step gains format validation and app-wide key propagation, GitHub/Xiaomi steps verified complete**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-03-21
- **Tasks:** 4 (01-02 implemented, 03-04 already complete from 10-01)
- **Files modified:** 2

## Accomplishments
- `startInstallation()` rewritten: sendInput + SOUL_PKG_DONE/SOUL_NPM_DONE marker polling, real-time output via `soulAwareness.outputStream.listen`, retry + proceed buttons
- `validateApiKey()` now checks `sk-ant-` format before network call and propagates key to `apiKeyNotifierProvider` immediately after save
- All 6 plan verification checks pass (sendInput count >= 3, ApiKeyService, openTerminalSheet, manufacturer==xiaomi, 2x Overslaan, monospace)

## Task Commits

1. **Tasks 10-02-01 + 10-02-02: installation streaming + API key validation** - `4a7bd4e4` (feat)
2. **Tasks 10-02-03 + 10-02-04: GitHub CLI + Xiaomi** — already committed in 10-01 (`1b81344b`)

## Files Created/Modified
- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart` — startInstallation rewrite, retryInstallation, proceedFromInstall, _waitForMarker, validateApiKey format check + notifier update
- `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — retry button wires to retryInstallation(), Doorgaan button on installSuccess, auto-scroll ScrollController

## Decisions Made
- sendInput + echo marker instead of runCommand() — OSC 133 not configured until shellConfig step (later in wizard)
- `_waitForMarker` uses a separate `outputStream.listen` subscription (not the outer subscription) for precise per-command completion detection

## Deviations from Plan

None — plan executed exactly as written. Tasks 03 and 04 acceptance criteria were already satisfied by 10-01 implementation; no changes needed.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Plan 10-02 complete: all 4 ONBR steps (02-05) wired up
- Plan 10-03 (shell config + completion) is next — writeShellConfig already implemented from 10-01

---
*Phase: 10-onboarding-flow*
*Completed: 2026-03-21*
