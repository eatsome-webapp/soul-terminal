---
phase: 07-bottom-sheet-layout
plan: "02"
subsystem: ui
tags: [nested-scrolling, ime, bottom-sheet, android, touch-conflict]

requires:
  - phase: 07-bottom-sheet-layout
    provides: BottomSheetBehavior layout infrastructure from plan 07-01

provides:
  - TerminalView implements NestedScrollingChild3 — cooperates with BottomSheetBehavior
  - windowSoftInputMode=adjustPan on TermuxActivity — correct IME handling in bottom sheet

affects:
  - 07-bottom-sheet-layout (plans 03+)

tech-stack:
  added: [androidx.core.view.NestedScrollingChild3, androidx.core.view.NestedScrollingChildHelper, androidx.core.view.ViewCompat]
  patterns:
    - NestedScrollingChild3 via NestedScrollingChildHelper delegate pattern
    - startNestedScroll on first finger scroll, stopNestedScroll in onUp()

key-files:
  created: []
  modified:
    - app/src/main/AndroidManifest.xml
    - terminal-view/src/main/java/com/termux/view/TerminalView.java

key-decisions:
  - "startNestedScroll placed in onScroll() guarded by !scrolledWithFinger (not in ACTION_DOWN) because GestureAndScaleRecognizer handles touch — onScroll() is the earliest hook for scroll initiation"
  - "TerminalView still consumes all its own scrolls — NestedScrollingChild3 only signals BottomSheetBehavior to not intercept, no behavioral change to terminal scrolling"

patterns-established:
  - "NestedScrollingChild3 delegate: all 15 methods forwarded to NestedScrollingChildHelper"

requirements-completed: [LAYT-04]

duration: 1min
completed: "2026-03-21"
---

# Phase 07 Plan 02: Touch conflict resolution + IME handling Summary

**NestedScrollingChild3 implemented in TerminalView via NestedScrollingChildHelper, plus windowSoftInputMode=adjustPan on TermuxActivity to prevent BottomSheetBehavior from intercepting terminal scroll gestures**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-21T09:52:54Z
- **Completed:** 2026-03-21T09:53:54Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- `android:windowSoftInputMode="adjustPan"` toegevoegd aan TermuxActivity — keyboard pan gedrag in bottom sheet context
- `TerminalView` implementeert nu `NestedScrollingChild3` via `NestedScrollingChildHelper`
- `startNestedScroll` aangroepen bij eerste vinger-scroll, `stopNestedScroll` bij `onUp()` — BottomSheetBehavior intercepteert terminal scrolls niet meer

## Task Commits

Each task was committed atomically:

1. **Task 07-02-01: windowSoftInputMode=adjustPan in AndroidManifest** - `edf632de` (feat)
2. **Task 07-02-02: NestedScrollingChild3 in TerminalView** - `faef023c` (feat)

**Plan metadata:** (follows in docs commit)

## Files Created/Modified

- `app/src/main/AndroidManifest.xml` - Added `android:windowSoftInputMode="adjustPan"` to TermuxActivity
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` - Implements NestedScrollingChild3 with all 15 delegate methods, field, constructor init, startNestedScroll/stopNestedScroll calls

## Decisions Made

- `startNestedScroll` staat in `onScroll()` (bewaakt door `!scrolledWithFinger`) in plaats van `ACTION_DOWN`, omdat `GestureAndScaleRecognizer` touch afhandelt en `onScroll()` het vroegste punt is waarop een scroll-gesture zeker actief is.
- TerminalView consumeert nog steeds al zijn eigen scrolls — geen gedragsverandering, alleen signalering naar de parent.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- IME handling en touch conflict resolution voor bottom sheet zijn klaar
- TerminalView is gereed voor gebruik als NestedScrollingChild3 in een CoordinatorLayout/BottomSheetBehavior context
- Klaar voor plan 07-03

---
*Phase: 07-bottom-sheet-layout*
*Completed: 2026-03-21*
