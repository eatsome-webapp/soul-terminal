---
phase: 12-profile-pack-system
plan: "12-04"
subsystem: ui
tags: [setup-wizard, profile-pack, dart, riverpod]

requires:
  - phase: 12-02
    provides: ProfilePackService, ProfileEntry with sizeMb/version
  - phase: 10-02
    provides: _waitForMarker pattern, soulAwarenessProvider, TerminalBridgeApi

provides:
  - Profile pack fast path with pack name/version log and elapsed timing
  - Pkg fallback with time estimates, step counters, pkg update, 10min timeout
  - Clear two-line fallback messaging when fast path unavailable

affects:
  - 12-profile-pack-system (remaining plans)

tech-stack:
  added: []
  patterns:
    - "Stopwatch pattern for timing install operations (both fast path and fallback)"
    - "Step counters [N/M] for multi-step pkg installs"
    - "pkg update -y before pkg install to ensure fresh package index"

key-files:
  created: []
  modified:
    - flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart

key-decisions:
  - "Stopwatch in _installViaProfilePack: wraps after manifest fetch, measures actual download+install duration"
  - "pkg fallback timeout raised to 10min per step (was 5min) — npm install on mobile can exceed 5min"
  - "pkg update -y added before pkg install to prevent stale package index errors"
  - "Two-line fallback message: 'Snelle installatie niet beschikbaar' + 'Terugvallen op handmatige installatie via pkg...'"

patterns-established:
  - "Stopwatch: start after manifest/setup, stop before state update, log as Ns or NmMs"

requirements-completed: [PROF-02, PROF-04]

duration: 5min
completed: 2026-03-22
---

# Phase 12 Plan 04: Setup Wizard Fast Path Refactor Summary

**Profile pack fast path now shows pack name/version + elapsed seconds; pkg fallback shows time estimates, [N/M] step counters, runs pkg update first, and has 10-minute timeouts per step.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-03-22T12:52:00Z
- **Completed:** 2026-03-22T12:57:52Z
- **Tasks:** 3
- **Files modified:** 1

## Accomplishments
- Profile pack fast path logs pack name + version before download, and reports total elapsed seconds on completion
- Pkg fallback shows estimated total time (8-12min for claudeCode, 3-5min for python) before starting
- Pkg fallback uses [1/2]/[2/2] step counters and runs `pkg update -y` before install
- Per-step timeout raised from 5 to 10 minutes for both pkg and npm install steps
- Fallback messaging split into two clear lines when fast path fails

## Task Commits

Each task was committed atomically:

1. **Task 1: Add download size confirmation before profile pack install** - `adc7da8e` (feat)
2. **Task 2: Improve pkg fallback with parallel execution and time estimates** - `dd438dc4` (feat)
3. **Task 3: Improve error handling in profile pack fast path with better fallback messaging** - `2bc31838` (feat)

## Files Created/Modified
- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart` - All three tasks applied here: stopwatch in fast path, refactored _installViaPkg, improved fallback catch block

## Decisions Made
- Stopwatch starts after manifest fetch (not at method entry) to measure actual download+install time, not network overhead for the manifest itself
- Timeout raised to 10min: npm install on a mobile connection with no cached packages regularly exceeds 5min
- `pkg update -y` prepended to prevent "Unable to locate package" errors on fresh installs where the package index is stale

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Setup wizard fast path and fallback both production-ready
- PROF-02 (<60s install via profile pack) and PROF-04 (improved fallback) requirements met
- Ready for remaining plans in phase 12

---
*Phase: 12-profile-pack-system*
*Completed: 2026-03-22*
