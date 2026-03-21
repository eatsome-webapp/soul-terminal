# Phase 7: Bottom Sheet Layout — Research

**Researched:** 2026-03-21
**Phase:** 07-bottom-sheet-layout

---

## Executive Summary

The layout refactor is architecturally clean and well-supported by existing dependencies. Material 1.12.0 is already present and contains all necessary components. The two critical risks (touch conflict and IME handling) have known solutions. The main structural change is: replace `TermuxActivityRootView` (LinearLayout root) with `CoordinatorLayout`, move the terminal hierarchy into a `BottomSheetBehavior` child, and promote `FlutterFragment` to fullscreen background.

**Key findings:**
1. `TermuxActivityRootView` does complex IME margin management via `OnGlobalLayoutListener` — this entire mechanism becomes obsolete under `adjustPan`. It can be replaced by `CoordinatorLayout` directly, but its `WindowInsetsListener` inner class is still useful.
2. `TerminalView` extends plain `View` with no `NestedScrollingChild` implementation. Vertical touch events currently go directly to `GestureAndScaleRecognizer.onScroll()`. Without `NestedScrollingChild3`, `BottomSheetBehavior` will intercept vertical drags on the terminal area.
3. `onBackPressed()` uses the deprecated override pattern — migration to `OnBackPressedCallback` is required for the sheet-aware back handling.
4. The `windowSoftInputMode` is not currently set in `AndroidManifest.xml` for `TermuxActivity` — it inherits the default (`adjustUnspecified`). This must be explicitly set to `adjustPan`.
5. `FlutterFragment` is currently added to `flutter_container` (a `FrameLayout` with `visibility=gone`) — it needs to become a fullscreen background fragment behind the sheet.
6. `toggleFlutterView()` and the `mIsFlutterVisible` boolean are the primary logic to replace with sheet state management.
7. The `terminal_toolbar_view_pager` (extra keys) is anchored via `RelativeLayout` constraints inside the terminal container — it moves with the sheet naturally once the container becomes the sheet child.

---

## Current Architecture

### View hierarchy (activity_termux.xml)

```
TermuxActivityRootView  (LinearLayout, vertical, fitsSystemWindows=true)
├── RelativeLayout  (id: activity_termux_root_relative_layout, weight=1)
│   ├── DrawerLayout  (id: drawer_layout, above: terminal_toolbar_view_pager)
│   │   ├── TerminalView  (id: terminal_view, match_parent)
│   │   └── LinearLayout  (id: left_drawer, 240dp, gravity=start)
│   │       ├── settings_button
│   │       ├── terminal_sessions_list (ListView)
│   │       └── button bar (toggle_keyboard, new_session, toggle_soul)
│   └── ViewPager  (id: terminal_toolbar_view_pager, 37.5dp, alignParentBottom, visibility=gone)
├── FrameLayout  (id: flutter_container, weight=1, visibility=gone)
└── View  (id: activity_termux_bottom_space_view, 1dp transparent)
```

### TermuxActivityRootView (LinearLayout subclass)

Implements `ViewTreeObserver.OnGlobalLayoutListener`. Its `onGlobalLayout()` method:
- Detects when the keyboard covers the `activity_termux_bottom_space_view`
- Calculates `pxHidden` (how many pixels of the view are obscured)
- Sets a bottom margin on itself via `onMeasure()` to push content above the keyboard
- Contains complex debouncing logic (40ms time checks) to prevent infinite layout loops
- Has a static `WindowInsetsListener` inner class that captures `statusBarHeight`

**This entire mechanism solves a problem that `adjustPan` handles automatically.** Under `adjustPan`, the system pans the window rather than resizing it — the root view is never obscured by the keyboard, so the `OnGlobalLayoutListener` approach becomes irrelevant.

### TerminalView touch handling

`TerminalView extends View` — no nested scrolling implementation.

`onTouchEvent()` always returns `true` (consumes every touch). Passes all events to `GestureAndScaleRecognizer`. The recognizer fires:
- `onScroll(distanceX, distanceY)` → calls `doScroll(event, deltaRows)` directly
- `onFling(velocityX, velocityY)` → uses `android.widget.Scroller` for smooth fling
- `onScale()` → font size zoom
- `onLongPress()` → text selection

The scroll is entirely self-managed via `mTopRow` (int) — not Android's `ScrollView` mechanism. `computeVerticalScrollRange/Extent/Offset` are overridden to report scroll position for the scrollbar indicator only.

**Problem:** `BottomSheetBehavior` uses an internal `ViewDragHelper` that intercepts `ACTION_MOVE` events with a vertical component before they reach child views. Since `TerminalView` does not implement `NestedScrollingChild`, it has no way to tell the `BottomSheetBehavior` "I am scrolling, leave me alone."

### Flutter toggle mechanism

```java
// TermuxActivity.java line 653
public void toggleFlutterView() {
    mIsFlutterVisible = !mIsFlutterVisible;
    View terminalContainer = findViewById(R.id.activity_termux_root_relative_layout);
    View flutterContainer = findViewById(R.id.flutter_container);
    if (mIsFlutterVisible) {
        terminalContainer.setVisibility(View.GONE);
        flutterContainer.setVisibility(View.VISIBLE);
    } else {
        flutterContainer.setVisibility(View.GONE);
        terminalContainer.setVisibility(View.VISIBLE);
        mTerminalView.requestFocus();
    }
}
```

Called from:
- `setSoulToggleButtonView()` → drawer SOUL button
- `onBackPressed()` when `mIsFlutterVisible == true`
- `showCommandPalette()` → "Toggle Flutter view" palette item

### Back button (line 791)

```java
@Override
public void onBackPressed() {
    if (mIsFlutterVisible) {
        toggleFlutterView();
    } else if (getDrawer().isDrawerOpen(Gravity.LEFT)) {
        getDrawer().closeDrawers();
    } else {
        finishActivityIfNotFinishing();
    }
}
```

This uses the deprecated `onBackPressed()` override. The modern approach is `getOnBackPressedDispatcher().addCallback(OnBackPressedCallback)`.

### FlutterFragment setup (line 631)

```java
private void setupFlutterFragment() {
    if (FlutterEngineCache.getInstance().contains(TermuxApplication.FLUTTER_ENGINE_ID)) {
        FlutterFragment flutterFragment = FlutterFragment
            .withCachedEngine(TermuxApplication.FLUTTER_ENGINE_ID)
            .shouldAttachEngineToActivity(true)
            .build();
        getSupportFragmentManager()
            .beginTransaction()
            .add(R.id.flutter_container, flutterFragment, FLUTTER_FRAGMENT_TAG)
            .commit();
    }
}
```

The `flutter_container` FrameLayout starts with `visibility=gone`. The fragment is added at `onCreate()` time regardless.

### IME / windowSoftInputMode

Current `AndroidManifest.xml` for `TermuxActivity` (line 56-78): **no `windowSoftInputMode` attribute**. The activity inherits `adjustUnspecified` from the application.

The current workaround is `TermuxActivityRootView.onGlobalLayout()` + bottom margin manipulation. This is documented extensively in the class javadoc as a fix for Gboard candidate view overlap.

### Dependencies confirmed

`app/build.gradle` line 31:
```
implementation "com.google.android.material:material:1.12.0"
```

Material 1.12.0 provides:
- `CoordinatorLayout` (via `material` which depends on `coordinatorlayout:1.2.0`)
- `BottomSheetBehavior` (`com.google.android.material.bottomsheet.BottomSheetBehavior`)
- `BottomSheetDragHandleView` (`com.google.android.material.bottomsheet.BottomSheetDragHandleView`)
- `BottomSheetCallback` for state change listeners

`androidx.core:core:1.13.1` is present — provides `ViewCompat.setOnApplyWindowInsetsListener`.

---

## Target Architecture

### View hierarchy (new activity_termux.xml)

```
CoordinatorLayout  (match_parent, fitsSystemWindows=true)
├── FrameLayout  (id: flutter_container, match_parent)  ← FlutterFragment fullscreen background
└── LinearLayout  (id: terminal_sheet_container, match_parent, wrap_content height)
    │  app:layout_behavior="com.google.android.material.bottomsheet.BottomSheetBehavior"
    │  app:behavior_peekHeight="48dp"
    │  app:behavior_halfExpandedRatio="0.4"
    │  app:behavior_hideable="true"
    │  app:behavior_fitToContents="false"
    ├── BottomSheetDragHandleView  (id: sheet_drag_handle, match_parent, 48dp)
    ├── RelativeLayout  (id: activity_termux_root_relative_layout, match_parent, 0dp weight=1)
    │   ├── DrawerLayout  (id: drawer_layout, above terminal_toolbar_view_pager)
    │   │   ├── TerminalView  (id: terminal_view, match_parent)
    │   │   └── LinearLayout  (id: left_drawer, 240dp, gravity=start)
    │   └── ViewPager  (id: terminal_toolbar_view_pager, 37.5dp, alignParentBottom)
    └── View  (id: activity_termux_bottom_space_view, 1dp transparent)  ← can be removed
```

The `flutter_container` is the first (bottom z-order) child of `CoordinatorLayout`, so it is always behind the sheet. No `visibility` toggling needed — the sheet covers it when expanded.

### Key layout rules for CoordinatorLayout + BottomSheet

- The sheet child needs `layout_height="match_parent"` so `BottomSheetBehavior` can calculate its full expanded height. The behavior manages the visible height via translation/offset.
- `fitsSystemWindows="true"` on `CoordinatorLayout` ensures status/nav bar insets are handled at the root.
- `flutter_container` gets `layout_width="match_parent"` and `layout_height="match_parent"` — it fills the entire screen behind the sheet.
- `BottomSheetDragHandleView` must be the first child inside the sheet container — it is the **only** interactive drag zone. Content below it (the terminal) must not receive sheet drag events.

---

## Technical Analysis

### 1. Touch Conflict: BottomSheetBehavior vs TerminalView

**Root cause:** `BottomSheetBehavior` uses `ViewDragHelper.Callback.tryCaptureView()` to claim vertical drags. It intercepts touch events in `onInterceptTouchEvent()` on the sheet container. Once it captures the drag, child views receive a synthetic `ACTION_CANCEL`.

**Solution: NestedScrollingChild3 + dedicated drag handle**

`NestedScrollingChild3` (extends `NestedScrollingChild2` extends `NestedScrollingChild`) provides a contract: when the child starts scrolling, it pre-consumes the scroll via `dispatchNestedPreScroll()`. If the parent (`BottomSheetBehavior` implements `NestedScrollingParent3`) consumes it (e.g., to close the sheet), the child scrolls less. Once the sheet is fully expanded or collapsed, the child consumes the remaining scroll itself.

Implementation plan for `TerminalView`:
1. Add `NestedScrollingChild3` to the `implements` clause
2. Add a `NestedScrollingChildHelper` field: `private final NestedScrollingChildHelper mNestedScrollingHelper = new NestedScrollingChildHelper(this);`
3. In constructor: `mNestedScrollingHelper.setNestedScrollingEnabled(true);`
4. Delegate all 9 `NestedScrollingChild3` interface methods to `mNestedScrollingHelper`
5. In `onTouchEvent()`, wrap the scroll path:
   - On `ACTION_DOWN`: call `startNestedScroll(ViewCompat.SCROLL_AXIS_VERTICAL, ViewCompat.TYPE_TOUCH)`
   - In `GestureRecognizer.onScroll()`: call `dispatchNestedPreScroll(0, dy, mScrollConsumed, mScrollOffset, ViewCompat.TYPE_TOUCH)` before `doScroll()`. Subtract consumed amount from `dy`.
   - On `ACTION_UP`/`ACTION_CANCEL`: call `stopNestedScroll(ViewCompat.TYPE_TOUCH)`

**Drag handle exclusivity:** `BottomSheetDragHandleView` is a standard Material component (a `View` subclass) that calls `BottomSheetBehavior.startNestedScroll()` on touch. The sheet will only drag when the user touches the handle bar — not the terminal area. This requires the `NestedScrollingChild3` implementation in `TerminalView` to correctly signal that it is handling the scroll, so `BottomSheetBehavior` does not intercept.

**Fallback option:** If `NestedScrollingChild3` proves complex, an alternative is to override `onInterceptTouchEvent()` on the sheet container (`LinearLayout`) to block interception when the touch starts inside `TerminalView` (not on the handle). This is simpler but less correct — it would prevent sheet dragging via a long press on the terminal handle area entirely, which is acceptable since the handle bar is the canonical drag zone.

### 2. IME Handling

**Current state:** No explicit `windowSoftInputMode` in manifest. `TermuxActivityRootView` manually manages keyboard overlap via `OnGlobalLayoutListener` + bottom margin. This is complex workaround code (200+ lines).

**Target state:**
- `AndroidManifest.xml`: add `android:windowSoftInputMode="adjustPan"` to `TermuxActivity`
- `adjustPan` pans the whole window rather than resizing it. The sheet, being at the bottom, will visually pan up when the keyboard appears — the terminal content remains accessible
- `ViewCompat.setOnApplyWindowInsetsListener` on the sheet container to be notified of IME inset changes and adjust the sheet's bottom padding accordingly

**Implementation in TermuxActivity.onCreate():**
```java
ViewCompat.setOnApplyWindowInsetsListener(terminalSheetContainer, (view, insets) -> {
    int imeHeight = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom;
    int navBarHeight = insets.getInsets(WindowInsetsCompat.Type.navigationBars()).bottom;
    view.setPadding(0, 0, 0, Math.max(imeHeight, navBarHeight));
    return insets;
});
```

**What happens to TermuxActivityRootView's margin logic?**
Under `adjustPan`, the system moves the window — the view is never resized and the `bottomSpaceView` is never occluded. The `onGlobalLayout()` margin logic will never trigger (or trigger unnecessarily). The `TermuxActivityRootView` class can be replaced by plain `CoordinatorLayout` — its IME handling logic is entirely superseded.

The `WindowInsetsListener` inner class (captures `statusBarHeight`) is still useful and should be preserved, but attached to the `CoordinatorLayout` root instead.

**BottomSheet + IME caveat:** When the sheet is in `STATE_EXPANDED` and the keyboard opens, `adjustPan` pans the screen up by the keyboard height. The sheet's bottom edge goes above the bottom of the screen. This is correct behavior — the terminal becomes fully visible above the keyboard. No extra code needed for this case.

When the sheet is in `STATE_COLLAPSED` (peek) and the keyboard opens (e.g., user tapped a search in SOUL chat), the pan only affects the visible window — the collapsed sheet handle moves up with the window. This is also correct — the SOUL chat content pans up, and the handle remains anchored to the panned view.

### 3. Layout Migration from LinearLayout to CoordinatorLayout

**What needs to change in activity_termux.xml:**
1. Replace root `TermuxActivityRootView` (LinearLayout) with `androidx.coordinatorlayout.widget.CoordinatorLayout`
2. Remove `android:orientation="vertical"` and `android:layout_weight` attributes (not applicable to CoordinatorLayout children)
3. `flutter_container` FrameLayout: remove `layout_weight="1"` and `visibility="gone"`, set `layout_height="match_parent"`
4. Wrap everything currently in `activity_termux_root_relative_layout` + the extra keys ViewPager + `activity_termux_bottom_space_view` into a new parent `LinearLayout` (vertical) that becomes the BottomSheet child
5. Add `BottomSheetDragHandleView` as the first child of that LinearLayout
6. Add the `app:layout_behavior` attribute to that LinearLayout
7. Remove `activity_termux_bottom_space_view` — no longer needed under `adjustPan`

**What needs to change in TermuxActivity.java:**
1. Remove `mTermuxActivityRootView` field and all references to `TermuxActivityRootView` class
2. Replace `mTermuxActivityBottomSpaceView` logic (the bottom space view is removed)
3. Replace `toggleFlutterView()` with `setSheetState(int state)` helper
4. Update `setMargins()` — currently sets margins on `activity_termux_root_relative_layout`. Still valid but must reference the correct container
5. Replace `addTermuxActivityRootViewGlobalLayoutListener()` / `removeTermuxActivityRootViewGlobalLayoutListener()` — no longer needed
6. Add `mBottomSheetBehavior` field and initialization
7. Update `onBackPressed()` / add `OnBackPressedCallback`
8. Remove `mIsFlutterVisible` boolean — sheet state is the source of truth

**Sheet state management:**
```java
// In TermuxActivity
private BottomSheetBehavior<View> mBottomSheetBehavior;

private void setupBottomSheet() {
    View sheetContainer = findViewById(R.id.terminal_sheet_container);
    mBottomSheetBehavior = BottomSheetBehavior.from(sheetContainer);
    mBottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
    mBottomSheetBehavior.addBottomSheetCallback(new BottomSheetBehavior.BottomSheetCallback() {
        @Override
        public void onStateChanged(@NonNull View bottomSheet, int newState) {
            if (newState == BottomSheetBehavior.STATE_EXPANDED && mTerminalView != null) {
                mTerminalView.requestFocus();
            }
        }
        @Override
        public void onSlide(@NonNull View bottomSheet, float slideOffset) {}
    });
}
```

### 4. BottomSheetBehavior Configuration

**Four states:**
- `STATE_HIDDEN`: sheet fully offscreen (only reachable programmatically or via drag down from collapsed)
- `STATE_COLLAPSED`: peek height visible (48dp handle bar) — default state at app start
- `STATE_HALF_EXPANDED`: 40% of screen height — intermediate state
- `STATE_EXPANDED`: full screen height

**Required behavior attributes on the sheet container:**
```xml
app:layout_behavior="com.google.android.material.bottomsheet.BottomSheetBehavior"
app:behavior_peekHeight="48dp"
app:behavior_halfExpandedRatio="0.4"
app:behavior_hideable="true"
app:behavior_fitToContents="false"
app:behavior_skipCollapsed="false"
```

`fitToContents="false"` is **required** for the half-expanded state to work. When `fitToContents=true` (default), the sheet only has two states: collapsed and fully expanded. Setting it to `false` enables the intermediate `STATE_HALF_EXPANDED`.

`hideable="true"` allows the sheet to be dragged fully off screen (STATE_HIDDEN). This is the mechanism for "hiding" the terminal.

**State at startup:** `STATE_COLLAPSED` shows only the 48dp handle. Flutter/SOUL chat is fully visible behind it.

### 5. FlutterFragment Placement

**Current:** `FlutterFragment` is added to `flutter_container` (FrameLayout with `visibility=gone`). The fragment IS added at `onCreate()` time even when hidden, so the Flutter engine warms up correctly.

**Target:** `flutter_container` becomes the first child of `CoordinatorLayout` with `match_parent` dimensions, no visibility toggle. It is always visible but behind the sheet.

**No changes needed to `setupFlutterFragment()`** — only the container view's attributes in XML change. The fragment tag `FLUTTER_FRAGMENT_TAG` and cached engine pattern remain identical.

**FlutterFragment z-order:** In `CoordinatorLayout`, children are drawn in order — first child is drawn first (behind). `flutter_container` must be declared before the sheet container in XML to ensure it appears behind the sheet.

### 6. Back Button Migration

**Current `onBackPressed()` logic:**
```
mIsFlutterVisible → toggleFlutterView()   // goes back to terminal
drawer open → closeDrawers()
else → finishActivityIfNotFinishing()
```

**Target `OnBackPressedCallback` logic:**
```
sheet STATE_EXPANDED → setState(STATE_COLLAPSED)
sheet STATE_HALF_EXPANDED → setState(STATE_COLLAPSED)
drawer open → closeDrawers()
sheet STATE_COLLAPSED → do nothing (let system handle = app close)
sheet STATE_HIDDEN → do nothing (let system handle)
```

**Implementation:**
```java
private void setupBackPressedCallback() {
    getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
        @Override
        public void handleOnBackPressed() {
            if (getDrawer().isDrawerOpen(Gravity.LEFT)) {
                getDrawer().closeDrawers();
                return;
            }
            int state = mBottomSheetBehavior.getState();
            if (state == BottomSheetBehavior.STATE_EXPANDED
                    || state == BottomSheetBehavior.STATE_HALF_EXPANDED) {
                mBottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
            } else {
                setEnabled(false);
                getOnBackPressedDispatcher().onBackPressed();
            }
        }
    });
}
```

Note: `onBackPressed()` override in `TermuxActivity` must be removed after adding the callback. The `TerminalView.onKeyPreIme()` already handles `KEYCODE_BACK` intercepting for escape mapping — that is unaffected.

### 7. TermuxActivityRootView — Replace or Adapt

**What it provides:**
1. LinearLayout root for the view hierarchy (structural role)
2. `OnGlobalLayoutListener` — IME margin workaround (obsoleted by `adjustPan`)
3. `WindowInsetsListener` inner class — captures `statusBarHeight` for rect calculations
4. `setActivity(TermuxActivity)` reference
5. `setIsRootViewLoggingEnabled(boolean)` for debugging

**Decision: Replace with CoordinatorLayout**

The class's core purpose (IME bottom margin management) is entirely superseded by `adjustPan`. There is no reason to keep the custom LinearLayout subclass. The `WindowInsetsListener` inner class logic (`mStatusBarHeight`) is only used internally in the ViewUtils rect calculations. With the new layout, the `ViewUtils.getWindowAndViewRects()` calls in `onGlobalLayout()` are also removed.

All references in `TermuxActivity`:
- `mTermuxActivityRootView` field → remove
- `mTermuxActivityRootView.setActivity(this)` → remove
- `mTermuxActivityRootView.setOnApplyWindowInsetsListener(new WindowInsetsListener())` → replace with insets listener on CoordinatorLayout
- `addTermuxActivityRootViewGlobalLayoutListener()` / `removeTermuxActivityRootViewGlobalLayoutListener()` → remove (called from `onStart()`/`onStop()`)
- `getTermuxActivityRootView()` → remove public getter
- `mProperties.isTerminalMarginAdjustmentEnabled()` check in `onStart()` → remove guard

### 8. Extra Keys Toolbar

The `terminal_toolbar_view_pager` ViewPager is currently inside `RelativeLayout` with `android:layout_alignParentBottom="true"`. The DrawerLayout is constrained `above` it.

In the new architecture, it remains in the same relative position inside the sheet container. The RelativeLayout wrapping DrawerLayout + ViewPager stays intact. The extra keys move with the sheet naturally — they are part of the sheet child, so dragging the sheet up/down moves them too.

**No changes needed** to `TerminalToolbarViewPager`, `ExtraKeysView`, or `TermuxTerminalExtraKeys`.

The `setTerminalToolbarHeight()` method and `setMargins()` calls reference `activity_termux_root_relative_layout` by ID — these IDs remain unchanged since the RelativeLayout stays in the hierarchy.

### 9. DrawerLayout Inside BottomSheet

`DrawerLayout` nesting inside a `BottomSheet` child is supported. The key concern is touch routing:
- Left drawer swipe (from left edge, horizontal) is handled by `DrawerLayout.onInterceptTouchEvent()` which checks for horizontal swipes from the left edge — this does not conflict with the vertical sheet drag
- The drawer has `gravity=start` — swipe from left edge opens it
- `BottomSheetBehavior` only cares about vertical drags on the sheet container, not horizontal ones

**One potential issue:** `DrawerLayout` has its own `ViewDragHelper` that may briefly compete with `BottomSheetBehavior` on diagonal swipes. In practice this is rarely a problem because the drawer trigger zone is a narrow left edge strip, and diagonal swipes starting outside that zone will not be claimed by `DrawerLayout`.

The drawer will remain functional. Phase 8 replaces it with a tab bar — backward compatibility until then is maintained.

### 10. Sheet State Persistence Across Config Changes

`BottomSheetBehavior` does NOT automatically save/restore its state across configuration changes (rotation, keyboard language change, etc.). The state must be saved manually.

`TermuxActivity` already has `onSaveInstanceState()` — add sheet state save there:
```java
savedInstanceState.putInt("sheet_state", mBottomSheetBehavior.getState());
```

And restore in `onCreate()` after `setupBottomSheet()`:
```java
if (savedInstanceState != null) {
    int savedState = savedInstanceState.getInt("sheet_state", BottomSheetBehavior.STATE_COLLAPSED);
    mBottomSheetBehavior.setState(savedState);
}
```

`TermuxActivity` has `android:configChanges="orientation|screenSize|..."` in the manifest — meaning it handles orientation itself without recreation. Sheet state is already in-memory in this case. The save/restore is only needed for process death scenarios.

---

## Risk Analysis

### R1 — Touch conflict not fully resolved (HIGH before fix, LOW after)

**Risk:** Without `NestedScrollingChild3`, vertical scrolling in the terminal area will be intercepted by `BottomSheetBehavior` and expand/collapse the sheet instead of scrolling terminal content.

**Mitigation:** Implement `NestedScrollingChild3` in `TerminalView` as specified. Test with: open terminal in half-expanded state, rapidly scroll up — content should scroll, not expand to full screen.

**Fallback:** If `NestedScrollingChild3` interaction with `GestureAndScaleRecognizer` proves problematic, override `onInterceptTouchEvent()` on the sheet's direct container to suppress interception when touch starts in the terminal area (not on handle). This trades off the smooth "sheet follows finger" feel for reliability.

### R2 — IME panning incorrect in all sheet states (MEDIUM)

**Risk:** With `adjustPan`, the keyboard will pan the entire window up. In `STATE_COLLAPSED`, the SOUL chat behind the sheet is panned. The 48dp handle remains at the bottom of the panned view. This is correct. In `STATE_EXPANDED`, the keyboard pans the terminal — correct. In `STATE_HALF_EXPANDED`, the pan lifts the sheet above the keyboard — also correct.

**Specific risk:** If `fitsSystemWindows` is not set correctly on the `CoordinatorLayout`, insets may be double-applied or not applied at all, causing incorrect positioning.

**Mitigation:** Set `fitsSystemWindows="true"` on `CoordinatorLayout` only. Do not set it on the sheet container or `flutter_container` — let the root handle it. Test: open keyboard in each sheet state, verify no content is covered.

### R3 — TerminalView updateSize() called during sheet animation (LOW-MEDIUM)

**Risk:** When the sheet slides between states, `TerminalView.onSizeChanged()` will be called repeatedly as the view's height changes during animation. Each call triggers `updateSize()` which calls `mTermSession.updateSize(cols, rows, ...)`. Rapid PTY resize events could cause terminal rendering artifacts or excessive redraws.

**Analysis:** `updateSize()` has a guard: `if (mEmulator == null || (newColumns != mEmulator.mColumns || newRows != mEmulator.mRows))` — it only acts when dimensions actually change. During sheet animation, height changes continuously (each frame), so `newRows` will change frequently. Each change causes a PTY resize notification to the running process.

**Mitigation:** Override `onLayout()` in the sheet container (or use a `BottomSheetCallback.onSlide()`) to temporarily suspend `TerminalView` size updates during animation, then trigger a final update when animation completes (`STATE_SETTLED`). Alternative: debounce updates with a 100ms handler post. This is not a terminal process crash risk — the PTY resize is benign — but it causes visual noise.

### R4 — DrawerLayout touch routing with BottomSheetBehavior (LOW)

**Risk:** Opening the left drawer while the sheet is in a non-expanded state could trigger unintended sheet drag due to overlapping touch handling.

**Mitigation:** The drawer is opened via left-edge swipe (horizontal) — orthogonal to sheet drag (vertical). Testing should confirm the two do not interfere. If they do, `DrawerLayout.addDrawerListener()` can be used to temporarily lock the sheet behavior when the drawer is opening.

### R5 — FlutterFragment always visible behind sheet (LOW)

**Risk:** `FlutterFragment` is now always attached and its container always visible. Previously it was `visibility=gone` until explicitly toggled. The Flutter engine warm-up path is unchanged (cached engine initialized at app start in `TermuxApplication`). The only change is the container is always `VISIBLE`.

**Analysis:** Flutter renders to a `SurfaceView`/`TextureView` inside the `FlutterFragment`. With the container visible at match_parent size, Flutter will render continuously even when fully covered by the sheet. This is a battery/performance concern, not a correctness risk.

**Mitigation:** In the `BottomSheetCallback.onStateChanged()`, when state changes to `STATE_EXPANDED`, `flutter_container.setVisibility(INVISIBLE)` could be used (INVISIBLE not GONE — GONE would detach the fragment). However, this optimization is **deferred** — the phase goal is correct behavior, not power optimization. The Flutter engine lifecycle already handles background/foreground via the FlutterFragment's `onPause()`/`onResume()` which are tied to activity lifecycle, not container visibility.

### R6 — TermuxActivityRootView removal breaks mProperties.isTerminalMarginAdjustmentEnabled() (LOW)

**Risk:** `onStart()` currently checks `mProperties.isTerminalMarginAdjustmentEnabled()` before adding the global layout listener. Removing this code path may cause issues if other code references this preference path.

**Mitigation:** The preference still exists in `TermuxAppSharedProperties` and can be used for other purposes. The code block in `onStart()`/`onStop()` just becomes dead code to be removed cleanly.

### R7 — Back button: callback vs deprecated onBackPressed() (LOW)

**Risk:** `OnBackPressedCallback` with `setEnabled(false)` then calling `getOnBackPressedDispatcher().onBackPressed()` for the "close app" case is the correct pattern but requires care — calling `finish()` directly instead is simpler and equivalent.

**Mitigation:** Use `finishActivityIfNotFinishing()` directly in the callback's else branch instead of re-dispatching.

---

## Validation Architecture

### V1 — Touch conflict resolution

**Test procedure:**
1. Launch app → sheet is in `STATE_COLLAPSED` (handle visible, SOUL chat behind)
2. Drag handle bar upward → sheet should expand to `STATE_HALF_EXPANDED`
3. Drag handle bar upward again → sheet should expand to `STATE_EXPANDED`
4. In `STATE_EXPANDED`: scroll terminal content up/down → terminal scrollback should respond, sheet should NOT collapse
5. In `STATE_HALF_EXPANDED`: scroll terminal content → terminal scrolls, sheet stays at half
6. In `STATE_EXPANDED`: drag handle bar downward → sheet collapses to `STATE_HALF_EXPANDED` then `STATE_COLLAPSED`
7. In `STATE_EXPANDED`: fast fling downward on handle → sheet collapses to peek

**Pass criteria:** Terminal scroll never triggers sheet collapse. Drag handle always triggers sheet movement. No dead zones where neither terminal nor sheet responds.

### V2 — IME behavior in all sheet states

**Test procedure:**
1. `STATE_EXPANDED` → tap terminal → keyboard opens → verify terminal content visible above keyboard, no content cut off
2. `STATE_EXPANDED` with keyboard open → type text → verify input registers in terminal
3. `STATE_HALF_EXPANDED` → tap terminal → keyboard opens → verify sheet pans up above keyboard
4. `STATE_COLLAPSED` → SOUL chat visible → open keyboard in SOUL UI → verify chat input works, handle visible above keyboard
5. Close keyboard in each state → verify layout returns to correct position

**Pass criteria:** No content occluded by keyboard in any state. No layout jank (single-frame glitch) on keyboard open/close.

### V3 — Terminal process continuity

**Test procedure:**
1. Start a long-running process (`sleep 300 && echo done`)
2. Cycle sheet through all 4 states multiple times
3. Open and close keyboard
4. Rotate device (if supported) or trigger config change
5. After all operations, wait for process to complete → verify `done` appears in terminal output

**Pass criteria:** Terminal process was never interrupted. Process ID unchanged throughout. `TermuxService` binding was not disrupted.

### V4 — Back button behavior

**Test procedure:**
1. Start in `STATE_EXPANDED` → press back → sheet should go to `STATE_COLLAPSED`
2. Start in `STATE_HALF_EXPANDED` → press back → sheet should go to `STATE_COLLAPSED`
3. Open left drawer → press back → drawer should close
4. `STATE_COLLAPSED`, drawer closed → press back → app should close (or show close confirmation)
5. `STATE_EXPANDED` with keyboard open → press back → keyboard should close first (system behavior), then back again → sheet collapses

**Pass criteria:** Back never closes the app when sheet is above `STATE_COLLAPSED`. Back closes drawer before sheet. Double-back from `STATE_EXPANDED` with keyboard → keyboard dismiss → sheet collapse = 2 back presses to go from full terminal + keyboard to SOUL chat only.

### V5 — Sheet state persistence

**Test procedure:**
1. Expand sheet to `STATE_EXPANDED`
2. Force-kill and relaunch app (or trigger process death: `adb shell am kill com.soul.terminal`)
3. Verify sheet starts in `STATE_COLLAPSED` (default, since saved state may be lost on force kill)
4. Alternatively: trigger config change via broadcast → verify sheet returns to same state

**Pass criteria:** Sheet starts in `STATE_COLLAPSED` on fresh launch. Sheet returns to correct state after config change. Terminal sessions survive config changes (service-bound, unaffected by activity recreation).

### V6 — Phase 8 readiness (forward compatibility)

**Check:** The `BottomSheetDragHandleView` at the top of the sheet container (48dp) should have sufficient room for a tab bar to be inserted above or below it in Phase 8. The sheet container is a `LinearLayout` with vertical orientation — adding a tab bar as an additional child between the handle and the `RelativeLayout` is straightforward.

**Pass criteria:** Sheet container is `LinearLayout` (easy to add children). Handle is a separate named view. No hardcoded heights that would conflict with an added tab bar.

---

## Implementation Order

Recommended sequence to minimize broken-state time:

1. **`AndroidManifest.xml`** — add `windowSoftInputMode="adjustPan"` to `TermuxActivity` (safe, no Java changes)
2. **`activity_termux.xml`** — full layout refactor (CoordinatorLayout root, flutter_container fullscreen, terminal as BottomSheet)
3. **`TermuxActivity.java`** — remove `TermuxActivityRootView` references, remove `toggleFlutterView()`, add `setupBottomSheet()`, update `onBackPressed()` → `OnBackPressedCallback`
4. **`TerminalView.java`** — add `NestedScrollingChild3` implementation
5. Test all validation scenarios

Steps 1-3 can be done in a single commit. Step 4 (`TerminalView`) is in a different module (`terminal-view`) and can be a separate commit. If step 4 is committed without step 3 being complete, the app will compile but touch conflict will exist — acceptable for CI but not for release.

---

## RESEARCH COMPLETE
