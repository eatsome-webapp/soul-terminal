---
phase: 07-bottom-sheet-layout
plan: 03
subsystem: ui
tags: [bottom-sheet, back-button, OnBackPressedCallback, TermuxActivityRootView, terminal-resize]

# Dependency graph
requires:
  - phase: 07-01
    provides: setupBottomSheet, OnBackPressedCallback, BottomSheetBehavior field
  - phase: 07-02
    provides: NestedScrollingChild3 in TerminalView, adjustPan IME mode
provides:
  - Hardened back button: null-safety for DrawerLayout + STATE_DRAGGING/SETTLING handling
  - Terminal resize debounce: updateSize() only on sheet settle, not during animation
  - TermuxActivityRootView stubbed: no more compile error from removed getTermuxActivityBottomSpaceView()
  - Zero remaining references to toggleFlutterView / mIsFlutterVisible / old toggle mechanism
  - Phase 07 fully closed
affects: [08-session-management, 09-soul-terminal-awareness]

# Tech tracking
tech-stack:
  added: []
  patterns: [null-safe-drawer-check, debounced-terminal-resize, stub-legacy-views]

key-files:
  created: []
  modified:
    - app/src/main/java/com/termux/app/TermuxActivity.java
    - app/src/main/java/com/termux/app/terminal/TermuxActivityRootView.java

key-decisions:
  - "Treat STATE_DRAGGING and STATE_SETTLING as non-collapsed for back button — back always animates to collapsed, never exits app mid-drag"
  - "Call updateSize() on every settled state (not just EXPANDED) — ensures correct PTY dimensions after any sheet state change"
  - "Stub TermuxActivityRootView.onGlobalLayout() rather than delete the file — class referenced nowhere at runtime but kept for safe compilation"

patterns-established:
  - "Null-safe accessor pattern for DrawerLayout: always guard getDrawer() != null before calling isDrawerOpen()"
  - "Sheet callback debounce pattern: skip transient states (DRAGGING/SETTLING), act only on stable states"

requirements-completed: [LAYT-05, LAYT-06]

# Metrics
duration: 20min
completed: 2026-03-21
---

# Plan 07-03: Back button behavior + state management + terminal process continuity

**Null-safe back button with transient-state handling, debounced terminal resize on sheet settle, and TermuxActivityRootView compile-safe stub — completing Phase 07.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-03-21T11:00:00Z
- **Completed:** 2026-03-21T11:20:00Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments
- Back button callback now guards against null DrawerLayout (early lifecycle) and handles mid-drag/settling states correctly
- BottomSheetCallback calls `mTerminalView.updateSize()` whenever sheet reaches a stable state, preventing stale PTY dimensions
- `TermuxActivityRootView.onGlobalLayout()` stubbed with empty body — removes compile error from `getTermuxActivityBottomSpaceView()` which was removed in Plan 07-01

## Task Commits

Each task was committed atomically:

1. **Task 07-03-01: Back button null-safety + transient states** - `66962a26` (feat)
2. **Task 07-03-02: Debounce terminal resize during sheet animation** - `8ad0f80f` (feat)
3. **Task 07-03-03: Stub TermuxActivityRootView + confirm clean codebase** - `3c388fcc` (feat)

## Files Created/Modified
- `app/src/main/java/com/termux/app/TermuxActivity.java` — back callback + sheet callback updated
- `app/src/main/java/com/termux/app/terminal/TermuxActivityRootView.java` — stubbed to compile-safe no-op

## Decisions Made
- `updateSize()` called on all stable states (COLLAPSED, EXPANDED, HALF_EXPANDED, HIDDEN), not only EXPANDED — ensures PTY is correct regardless of target state
- TermuxActivityRootView kept as a file (not deleted) per plan guidance — compiles cleanly, no runtime impact

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered
- `TermuxActivityRootView.onGlobalLayout()` referenced `mActivity.getTermuxActivityBottomSpaceView()` which was removed in 07-01. A simple two-line stub would leave the rest of the old method body with compile errors. Replaced entire `onGlobalLayout()` with a clean stub and rewrote the file minimally — no logic removed that was still needed, all constructors and the WindowInsetsListener inner class preserved.

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- Phase 07 is complete. All 6 LAYT requirements delivered across plans 07-01, 07-02, 07-03.
- CI push triggered (3c388fcc → master). Green build = final Phase 07 gate.
- Phase 08 (Session Management, SESS-01..06) can begin once CI is green.

---
*Phase: 07-bottom-sheet-layout*
*Completed: 2026-03-21*
