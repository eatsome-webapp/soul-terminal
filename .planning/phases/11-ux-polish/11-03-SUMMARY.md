---
phase: 11-ux-polish
plan: 03
subsystem: ui
tags: [android, haptics, vibration, rendereffect, blur, gestures, bottomsheet]

# Dependency graph
requires:
  - phase: 07-bottom-sheet-layout
    provides: setupBottomSheet(), BottomSheetBehavior, sheet_drag_handle, flutter_container

provides:
  - triggerHaptic(HAPTIC_TICK/HAPTIC_CLICK) public helper with API guards
  - Progressive RenderEffect blur (0-10px) on flutter_container as sheet slides (API 31+)
  - Semi-transparent dark scrim fallback for API < 31
  - HAPTIC_TICK on sheet STATE_EXPANDED/COLLAPSED/HALF_EXPANDED settle
  - HAPTIC_CLICK on tab switch in onTabSelected
  - Velocity-based fling (1500dp/s) on sheet_drag_handle for snap expand/collapse

affects: [11-ux-polish]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - API-guarded haptic: Q+ predefined, O-Q oneshot, pre-O performHapticFeedback
    - RenderEffect blur with @RequiresApi(S) split method
    - View.setForeground(ColorDrawable) as pre-S scrim fallback
    - GestureDetector.onFling returning false in OnTouchListener to pass-through to BottomSheetBehavior

key-files:
  created: []
  modified:
    - app/src/main/java/com/termux/app/TermuxActivity.java

key-decisions:
  - "triggerHaptic made public so TermuxTerminalViewClient can call it in future"
  - "applyBlurEffect split into separate @RequiresApi(S) method for lint safety"
  - "OnTouchListener on drag handle returns false — BottomSheetBehavior must keep receiving drag events"
  - "Blur cleared at radius=0 via setRenderEffect(null) instead of conditional skip"

patterns-established:
  - "API version guards: use Build.VERSION_CODES constants, not raw integers"
  - "Progressive RenderEffect blur: clamped slideOffset * maxRadius"
  - "Fling threshold in dp, converted to px via DisplayMetrics.density"

requirements-completed: [UXPL-03, UXPL-04, UXPL-05]

# Metrics
duration: 25min
completed: 2026-03-21
---

# Plan 11-03: Sheet physics, blur & haptics — Summary

**Velocity fling on drag handle, progressive RenderEffect blur on SOUL chat behind sheet, and API-guarded haptic feedback on sheet state and tab switch**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-03-21T15:00Z
- **Completed:** 2026-03-21T15:25Z
- **Tasks:** 4
- **Files modified:** 1

## Accomplishments
- Haptic helper with full API coverage (Q+, O-Q, pre-O fallback) — UXPL-03
- Sheet settle haptics (TICK) and tab switch haptics (CLICK) wired up
- Progressive RenderEffect blur 0-10px on flutter_container as sheet opens (API 31+) — UXPL-04
- Dark scrim fallback via setForeground for pre-API 31 devices
- Velocity fling detector on drag handle: >1500dp/s snaps to expanded/collapsed — UXPL-05

## Task Commits

Each task was committed atomically:

1. **Task 1: Haptic helper** - `e3d9640d` (feat)
2. **Task 2: Sheet/tab haptic calls** - `06a33b9c` (feat)
3. **Task 3: Blur/scrim in onSlide** - `8d5472b1` (feat)
4. **Task 4: Velocity fling on drag handle** - `33280a6e` (feat, included in concurrent commit)

## Files Created/Modified
- `app/src/main/java/com/termux/app/TermuxActivity.java` — triggerHaptic helper, applyBlurForOffset, applyBlurEffect, fling detector, haptic calls in callbacks

## Decisions Made
- `triggerHaptic` is `public` so it can be called from `TermuxTerminalViewClient` if needed in future
- `applyBlurEffect` extracted with `@RequiresApi(S)` annotation — avoids lint suppression in calling method
- `return false` in OnTouchListener is critical — BottomSheetBehavior needs all touch events for drag positioning
- Blur `setRenderEffect(null)` at radius=0 clears the effect cleanly on collapse

## Deviations from Plan
None — plan executed exactly as written.

## Issues Encountered
Task 4 code was included in a concurrent commit (`33280a6e feat(ux): wire PromptInterceptor into TermuxActivity`) instead of getting its own atomic commit. Code is correctly implemented and committed; only the commit message attribution deviates from ideal.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- UXPL-03, UXPL-04, UXPL-05 complete
- Phase 11 has 4 plans total; this is plan 03
- Next: plan 11-04 (if exists) or phase completion

---
*Phase: 11-ux-polish*
*Completed: 2026-03-21*
