---
phase: 10-onboarding-flow
plan: "03"
subsystem: ui
tags: [flutter, riverpod, pigeon, osc133, shell-config, onboarding, setup-wizard]

# Dependency graph
requires:
  - phase: 10-01
    provides: writeShellConfig Pigeon method in TerminalBridgeApi
  - phase: 10-02
    provides: proceedFromInstall, wizard step infrastructure, isLoading state

provides:
  - writeShellConfig() with correct PROMPT_COMMAND (bash) + precmd (zsh) OSC 133 config
  - Shell config step UI with auto-trigger and Doorgaan button
  - _persistCompletion() private method, called from _advanceToNextStep before complete step
  - completeSetup() public no-op for clean UI contract
  - _buildCompleteStep with _completionSummary() bullet summary
  - _advanceToNextStep() refactored to switch statement with all step transitions
  - Complete onboarding flow: welcome → installing → apiKey → githubAuth → [xiaomiBattery] → shellConfig → complete

affects: [phase-11-ux-polish, soul-awareness]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Persist-before-render: _persistCompletion() called async in _advanceToNextStep before state update to complete step"
    - "Non-fatal shell config: error sets shellConfigDone=true and logs warning, never blocks wizard"
    - "Switch-based step routing: deterministic transitions replace loop-with-skip pattern"

key-files:
  created: []
  modified:
    - flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart
    - flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart

key-decisions:
  - "Use com.soul.terminal home path (not com.termux) for writeShellConfig file targets"
  - "Separate bash (PROMPT_COMMAND) and zsh (precmd) configs instead of one shared config"
  - "Shell config failure is non-fatal: shellConfigDone=true even on exception, log warning to installLog"
  - "completeSetup() is no-op in provider — persistence already done in _persistCompletion() before screen renders"
  - "_advanceToNextStep() refactored from loop-with-skip to explicit switch for deterministic transitions"
  - "selectProfile() now calls _advanceToNextStep() instead of inline step assignment"

patterns-established:
  - "Auto-trigger in step method: addPostFrameCallback inside _buildShellConfigStep replaces _shellConfigStarted flag in build()"

requirements-completed: [ONBR-06, ONBR-07]

# Metrics
duration: 18min
completed: 2026-03-21
---

# Phase 10 Plan 03: Shell config (OSC 133), completion flow, integration validation — Summary

**OSC 133 PROMPT_COMMAND written to .bashrc and precmd hook to .zshrc via Pigeon writeShellConfig, with persist-before-render completion flow and deterministic switch-based step routing**

## Performance

- **Duration:** 18 min
- **Started:** 2026-03-21T17:00:00Z
- **Completed:** 2026-03-21T17:18:00Z
- **Tasks:** 4
- **Files modified:** 2

## Accomplishments

- writeShellConfig() now writes separate bash (PROMPT_COMMAND) and zsh (precmd) OSC 133 configs via Pigeon, with non-fatal error handling
- Completion flow: _persistCompletion() is called from _advanceToNextStep before the complete step renders, so setupCompleted=true is persisted before the UI appears
- Shell config UI step has addPostFrameCallback auto-trigger, loading indicator, check_circle icon on done, and Doorgaan button that calls proceedFromShellConfig()
- _advanceToNextStep() refactored to switch statement — deterministic, readable, no loop-with-skip heuristic

## Task Commits

1. **Task 10-03-01: writeShellConfig in provider** - `2983e830` (feat)
2. **Task 10-03-02: shell config step UI** - `c194db76` (feat)
3. **Tasks 10-03-03 + 10-03-04: completion flow + _advanceToNextStep switch** - `f5348992` (feat)

## Files Created/Modified

- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart` — writeShellConfig with correct OSC 133 configs, _persistCompletion, completeSetup no-op, _advanceToNextStep switch, selectProfile via _advanceToNextStep
- `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — _buildShellConfigStep with auto-trigger + Doorgaan, _buildCompleteStep with _completionSummary(), Begin button only context.go('/')

## Decisions Made

- `com.soul.terminal` home path used (not `com.termux`) per project CLAUDE.md
- Bash gets `PROMPT_COMMAND='printf "\033]133;D\007"'` and zsh gets `precmd() { printf "\033]133;D\007"; }` — different hooks for each shell
- Shell config failure is non-fatal: wizard continues regardless, user gets log message with manual instructions
- `completeSetup()` is a public no-op — the actual persistence is done inside `_persistCompletion()` which runs async in `_advanceToNextStep` before the state update
- `selectProfile()` simplified to call `_advanceToNextStep()` — removed inline step assignment

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed duplicate _shellConfigStarted auto-trigger from build()**
- **Found during:** Task 10-03-02 (shell config UI)
- **Issue:** Old `build()` had `_shellConfigStarted` flag + `addPostFrameCallback`. New `_buildShellConfigStep` also has its own trigger. Double-triggering would call writeShellConfig twice.
- **Fix:** Removed `_shellConfigStarted` field and the `build()` auto-trigger block; only the in-method trigger remains
- **Files modified:** setup_wizard_screen.dart
- **Verification:** Only one `addPostFrameCallback` call for writeShellConfig in codebase
- **Committed in:** c194db76 (Task 10-03-02 commit)

**2. [Rule 1 - Bug] selectProfile refactored to use _advanceToNextStep**
- **Found during:** Task 10-03-04 (_advanceToNextStep switch)
- **Issue:** Old `selectProfile()` had hardcoded step assignment bypassing the switch. After refactoring to switch, the terminalOnly→apiKey skip must go through the switch (which reads `state.currentStep == welcome` and `state.selectedProfile == terminalOnly`)
- **Fix:** `selectProfile()` now sets selectedProfile then calls `_advanceToNextStep()`
- **Files modified:** setup_wizard_provider.dart
- **Verification:** `grep 'terminalOnly.*apiKey'` matches in switch case
- **Committed in:** f5348992 (Task 10-03-03/04 commit)

---

**Total deviations:** 2 auto-fixed (2 bugs)
**Impact on plan:** Both fixes necessary for correctness. No scope creep.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 10 onboarding flow COMPLETE — all 3 plans executed (10-01, 10-02, 10-03)
- All 7 ONBR requirements addressed
- Ready for Phase 11 (UX Polish)

---
*Phase: 10-onboarding-flow*
*Completed: 2026-03-21*
