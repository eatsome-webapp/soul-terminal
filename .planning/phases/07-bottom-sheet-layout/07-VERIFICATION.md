---
status: human_needed
phase: 07
verified: 2026-03-21
---
# Phase 07 Verification

## Summary

All 6 LAYT requirements are implemented in code across plans 07-01, 07-02, and 07-03.
Status is `human_needed` because visual drag behavior, touch feel, and keyboard resize
need device confirmation — no automated test covers these.

---

## Requirement Checks

### LAYT-01 — Flutter als hoofdscherm bij app start
**Status: PASS**

- `activity_termux.xml` root is `CoordinatorLayout`
- `flutter_container` is a fullscreen `FrameLayout` (match_parent × match_parent) at z-order bottom — no visibility toggle, always rendered
- `setupFlutterFragment()` called in `onCreate()` (line 243), adds `FlutterFragment` to `R.id.flutter_container`
- Terminal sheet starts as `STATE_COLLAPSED` (48dp peek), Flutter fully visible beneath it

### LAYT-02 — Terminal omhoog slepen via handle bar
**Status: PASS**

- `terminal_sheet_container` LinearLayout has `app:layout_behavior="com.google.android.material.bottomsheet.BottomSheetBehavior"`
- `sheet_drag_handle` FrameLayout (48dp height, #0F0F23 bg) with 40×4dp pill indicator (`@drawable/sheet_drag_handle_pill`) is the first child of the sheet — drag target is correct
- BottomSheetBehavior handles drag natively; no custom touch code needed

*Visual confirmation needed: pill renders correctly, drag gesture feels natural on device.*

### LAYT-03 — 4 sheet states: hidden, collapsed (peek), half-expanded (40%), expanded (full)
**Status: PASS**

XML attributes on `terminal_sheet_container`:
- `app:behavior_peekHeight="48dp"` — collapsed peek height
- `app:behavior_halfExpandedRatio="0.4"` — 40% half-expanded
- `app:behavior_hideable="true"` — STATE_HIDDEN enabled
- `app:behavior_fitToContents="false"` — required for half-expanded to be a distinct stop
- `app:behavior_skipCollapsed="false"` — collapsed is a real stop

`setupBottomSheet()` sets initial state `STATE_COLLAPSED`.
Toggle button cycles `COLLAPSED/HIDDEN → HALF_EXPANDED` and `HALF_EXPANDED/EXPANDED → COLLAPSED`.

*Visual confirmation needed: all 4 stops accessible by drag and programmatic toggle.*

### LAYT-04 — Keyboard zonder layout glitches
**Status: PASS**

- `android:windowSoftInputMode="adjustPan"` confirmed in `AndroidManifest.xml` line 59 for `TermuxActivity`
- `TerminalView implements NestedScrollingChild3` (line 50 of TerminalView.java)
- Full 15-method delegate via `NestedScrollingChildHelper` (lines 1564–1628)
- `startNestedScroll(SCROLL_AXIS_VERTICAL, TYPE_TOUCH)` called in `onScroll()` guarded by `!scrolledWithFinger`
- `stopNestedScroll(TYPE_TOUCH)` called in `onUp()`
- IME insets listener in `setupBottomSheet()` pads sheet container to avoid keyboard overlap

*Keyboard-on-device test needed to confirm no bounce/resize glitch.*

### LAYT-05 — Back button sluit sheet, niet app
**Status: PASS**

`OnBackPressedCallback` registered in `setupBottomSheet()` (lines 676–695):
- Drawer check first (null-safe, closes if open)
- `STATE_EXPANDED | STATE_HALF_EXPANDED | STATE_DRAGGING | STATE_SETTLING` → collapse to `STATE_COLLAPSED`
- `STATE_COLLAPSED | STATE_HIDDEN` → `finishActivityIfNotFinishing()`
- Deprecated `onBackPressed()` override removed

*Touch test needed: back from expanded → collapsed, back from collapsed → app closes.*

### LAYT-06 — Terminal process draait door ongeacht sheet state
**Status: PASS**

- `TermuxService` binding happens unconditionally in `onCreate()` (lines 278–285), completely independent of sheet state
- `BottomSheetCallback.onStateChanged()` only calls `mTerminalView.updateSize()` on stable states — does not affect service or process lifecycle
- `unbindService()` only in `onDestroy()` (line 376)
- `updateSize()` called for ALL stable states (COLLAPSED, EXPANDED, HALF_EXPANDED, HIDDEN) — PTY dimensions stay correct after any sheet transition

*Process continuity confirmed structurally; long-running session test during sheet drag confirms empirically.*

---

## Requirement Coverage

| ID | Description | Plan | Code Evidence | Status |
|----|-------------|------|---------------|--------|
| LAYT-01 | Flutter als hoofdscherm | 07-01 | `flutter_container` fullscreen, `setupFlutterFragment()` | PASS |
| LAYT-02 | Terminal slepen via handle | 07-01 | `BottomSheetBehavior` + drag handle view | PASS |
| LAYT-03 | 4 sheet states | 07-01 | `peekHeight=48dp`, `halfExpandedRatio=0.4`, `hideable=true`, `fitToContents=false` | PASS |
| LAYT-04 | Keyboard zonder glitches | 07-02 | `adjustPan` in manifest + `NestedScrollingChild3` in TerminalView | PASS |
| LAYT-05 | Back sluit sheet, niet app | 07-01/03 | `OnBackPressedCallback` met null-safe drawer check + transient state handling | PASS |
| LAYT-06 | Terminal process continu | 07-03 | Service binding onafhankelijk van sheet; `updateSize()` op alle stable states | PASS |

All 6 requirements accounted for. No gaps in code.

---

## Wat nog device-test vereist

1. Drag handle visueel zichtbaar en draggable bij 48dp peek
2. Half-expanded stop op ~40% schermhoogte voelt correct aan
3. Keyboard openen in terminal sheet: geen bounce of layout jump
4. Back gesture vanuit expanded en half-expanded → collapsed, daarna → app sluit
5. Claude Code sessie actief houden terwijl sheet heen en weer gesleept wordt

---

## Files Verified

- `app/src/main/res/layout/activity_termux.xml` — CoordinatorLayout + BottomSheetBehavior XML
- `app/src/main/java/com/termux/app/TermuxActivity.java` — setupBottomSheet, OnBackPressedCallback, sheet state persistence
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — NestedScrollingChild3 implementation
- `app/src/main/AndroidManifest.xml` — windowSoftInputMode=adjustPan
