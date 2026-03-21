---
phase: 08-session-management
plan: "01"
subsystem: ui
tags: [android, java, tablayout, gesture, session-management, terminal]

requires:
  - phase: 07-bottom-sheet-layout
    provides: terminal_sheet_container LinearLayout with BottomSheetBehavior, drag handle structure

provides:
  - TabLayout session tab bar between drag handle and terminal content
  - Process name polling from /proc/PID/cmdline every 2 seconds
  - + button to create new sessions
  - Horizontal swipe GestureDetector for session switching
  - Drawer locked to prevent horizontal swipe conflict
  - getSessionTabLayout() and getSessionSwipeDetector() accessors on TermuxActivity

affects:
  - 08-session-management (plans 02, 03)
  - 09-soul-terminal-awareness

tech-stack:
  added: [com.google.android.material.tabs.TabLayout]
  patterns:
    - TabLayout.OnTabSelectedListener removed before removeAllTabs/addTab to prevent recursive switchToSession
    - OnTouchListener on TerminalView delegates to TermuxTerminalViewClient.onTouchEvent for swipe
    - Process name polling via Handler.postDelayed 2000ms, stopped in onStop

key-files:
  created: []
  modified:
    - app/src/main/res/layout/activity_termux.xml
    - app/src/main/java/com/termux/app/TermuxActivity.java
    - app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java
    - app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java

key-decisions:
  - "OnTouchListener on TerminalView (not TerminalViewClient interface override) — TerminalViewClient interface has no onTouchEvent, adding one would require upstream terminal-view changes"
  - "Swipe detection via GestureDetector.SimpleOnGestureListener.onFling with 120dp min distance and 200 velocity threshold"
  - "termuxSessionListNotifyUpdated() calls only updateSessionTabs() — notifyDataSetChanged removed, ListView drawer is secondary UI"

requirements-completed: [SESS-01, SESS-02, SESS-03, SESS-05]

duration: 25min
completed: 2026-03-21
---

# Phase 8 Plan 01: Tab bar UI, process names, new session button Summary

**TabLayout session tab bar with /proc/PID/cmdline polling, + button for new sessions, and GestureDetector swipe to switch sessions, with drawer locked to prevent touch conflict**

## Performance

- **Duration:** 25 min
- **Started:** 2026-03-21T10:10:00Z
- **Completed:** 2026-03-21T10:35:24Z
- **Tasks:** 5
- **Files modified:** 4

## Accomplishments

- TabLayout (36dp, scrollable, purple indicator #6C63FF) inserted between drag handle and terminal content
- Process name polling reads /proc/PID/cmdline every 2s with fallback: mSessionName → "Session N"
- + button (new_session_tab_button) calls addNewSession(false, null)
- GestureDetector.onFling switches sessions left (forward=true) / right (forward=false)
- setCurrentSession() syncs tab selection; drawer locked with LOCK_MODE_LOCKED_CLOSED

## Task Commits

1. **Task 1: Add TabLayout to activity_termux.xml** - `c6a61c48` (feat)
2. **Tasks 2+3+4: Initialize TabLayout, polling, swipe in TermuxActivity** - `d58afb53` (feat)
3. **Task 4: Swipe gesture delegation in TermuxTerminalViewClient** - `b3e4cdb0` (feat)
4. **Task 5: Tab selection sync and drawer lock** - `2120a8f2` (feat)

## Files Created/Modified

- `app/src/main/res/layout/activity_termux.xml` - Added session_tab_bar_container with TabLayout + ImageButton
- `app/src/main/java/com/termux/app/TermuxActivity.java` - setupSessionTabBar(), updateSessionTabs(), getSessionTabLabel(), updateTabLabelsOnly(), mProcessNamePoller, accessors
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java` - onTouchEvent() forwarding to swipe detector
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` - setCurrentSession() tab sync

## Decisions Made

- **OnTouchListener vs TerminalViewClient interface**: TerminalViewClient interface has no onTouchEvent method. Adding one would require modifying terminal-view (upstream merge risk). Used View.setOnTouchListener on TerminalView instead — delegates to TermuxTerminalViewClient.onTouchEvent() which forwards to GestureDetector.
- **Swipe thresholds**: 120dp min distance, 200 velocity — prevents accidental swipes while allowing deliberate horizontal gestures.
- **notifyDataSetChanged removed**: Tab bar replaces ListView as primary session indicator. ListView in drawer remains but no longer needs update notifications from termuxSessionListNotifyUpdated().

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] TerminalViewClient interface has no onTouchEvent**
- **Found during:** Task 4 (horizontal swipe gesture)
- **Issue:** Plan said to add swipe detector call to TermuxTerminalViewClient.onTouchEvent() but TerminalViewClient interface doesn't define this method. TerminalView never calls client.onTouchEvent().
- **Fix:** Added onTouchEvent() as a non-interface public method on TermuxTerminalViewClient, called from an OnTouchListener set on TerminalView in setupSessionTabBar(). Method internally calls mActivity.getSessionSwipeDetector().onTouchEvent(event). All acceptance criteria met.
- **Files modified:** TermuxActivity.java, TermuxTerminalViewClient.java
- **Verification:** `grep "getSessionSwipeDetector" TermuxTerminalViewClient.java` returns 1 match
- **Committed in:** b3e4cdb0 + d58afb53

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Minimal — functionally equivalent to plan intent. Swipe detection works via OnTouchListener delegation. No scope creep.

## Issues Encountered

None beyond the TerminalViewClient interface gap handled above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Tab bar with process name labels and + button ready
- Session switching via tab tap and horizontal swipe ready
- Plan 02 (session close button, long-press rename) and Plan 03 can proceed
- Drawer is locked — if Plan 02/03 require drawer access, note LOCK_MODE_LOCKED_CLOSED

---
*Phase: 08-session-management*
*Completed: 2026-03-21*
