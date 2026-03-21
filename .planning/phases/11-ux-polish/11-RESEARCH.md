# Phase 11: UX Polish — Research

**Gathered:** 2026-03-21
**Status:** Complete

---

## 1. Path Detection in TerminalView (UXPL-01)

### Hook Point

`TermuxTerminalViewClient.onLongPress()` at line 368:
- `/app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java`, r368–370
- Currently returns `false` unconditionally — this is the primary hook
- Called from `TerminalView.onLongPress()` at line 264–269 via `mClient.onLongPress(event)`
- If `onLongPress()` returns `true`, the default text-selection mode is **not** started
- If it returns `false`, the view falls through to `startTextSelectionMode(event)` + haptic

### getWordAtLocation

`TerminalBuffer.getWordAtLocation(int x, int y)` at r108–145:
- `/terminal-emulator/src/main/java/com/termux/terminal/TerminalBuffer.java`
- Returns the space-delimited token at a given column/row position
- Handles wrapped lines — expands y1/y2 across screen rows before extracting
- Returns `""` if click is on whitespace or past end of line

Existing call site in `onSingleTapUp` (r188–196 in TermuxTerminalViewClient):
```java
int[] columnAndRow = mActivity.getTerminalView().getColumnAndRow(e, true);
String wordAtTap = term.getScreen().getWordAtLocation(columnAndRow[0], columnAndRow[1]);
```
Exact same pattern to reuse in `onLongPress`.

### Regex Patterns for Path Detection

`getWordAtLocation` returns the whitespace-delimited token. Apply a compiled `Pattern` against the returned string:

```java
private static final Pattern PATH_PATTERN = Pattern.compile(
    "^((/[^\\s:]+)|(\\.{1,2}/[^\\s:]+)|(~/[^\\s:]+))$"
);
```

- Group 1: absolute path `/foo/bar`
- Group 2: relative path `./foo` or `../foo`
- Group 3: home-relative `~/foo`
- Strip trailing `:` and `,` characters before matching (common in compiler errors like `src/main.dart:12:3`)

### File Existence Check

`new java.io.File(path).exists()` after resolving `~` to `System.getenv("HOME")`. Used to show/hide the "Open" option.

### Context Menu Implementation

Use `PopupMenu` (already imported in `TermuxActivity.java` at r83, used in `showSessionContextMenu`). Pattern:
```java
PopupMenu popup = new PopupMenu(mActivity, /* anchor */ anchorView);
popup.getMenu().add(0, 1, 0, "Kopieer pad");
if (fileExists) popup.getMenu().add(0, 2, 0, "Open");
popup.setOnMenuItemClickListener(...);
popup.show();
```

The anchor view for the PopupMenu needs to be the `TerminalView` itself (since `onLongPress` has no specific anchor).

### Pitfalls

- `getWordAtLocation` uses space as delimiter only — paths with spaces will be split. This is acceptable since paths with spaces are uncommon in terminal output.
- The regex must not match ANSI escape sequences. The transcript from `getTranscriptText()` may contain residual escape sequences. `getWordAtLocation` returns a single token, so escape sequences would not be part of a path token in practice.
- `getColumnAndRow(event, true)` — pass `relativeToScroll = true` to handle scrolled transcript correctly.
- Must call `performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)` manually when returning `true` (since the view skips its own haptic if `mClient.onLongPress()` returns `true`).

---

## 2. Y/N Prompt Interception (UXPL-02)

### Output Stream Hook

`TermuxTerminalSessionActivityClient.onTextChanged()` at r128–138:
- `/app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java`
- Called on every terminal text update for the active session
- Already calls `SoulBridgeController.onTerminalTextChanged()` here

### Monitoring Strategy

Add a second listener call alongside the existing `controller.onTerminalTextChanged()`. A new `PromptInterceptor` class (or inline logic) checks the last visible line for y/n prompt patterns:

```java
// In onTextChanged(), after the existing SoulBridgeController call:
mActivity.getPromptInterceptor().checkForPrompt(changedSession);
```

`PromptInterceptor` reads the last non-empty line from the session transcript. Since `SoulBridgeController` already has the debounce pattern (100ms, `Handler.postDelayed`), reuse the same structure.

### Regex Patterns

```java
private static final Pattern YN_PROMPT_PATTERN = Pattern.compile(
    ".*\\s(\\[y/N\\]|\\[Y/n\\]|\\[yes/no\\]|\\(yes/no\\)|\\[Y/N\\])\\s*$",
    Pattern.CASE_INSENSITIVE
);
```

Check only the last line: `lines[lines.length - 1]`.

The prompt text (question) is the content of the last line before the `[y/N]` token — extract via:
```java
String promptText = lastLine.replaceAll("\\s*\\[y/N\\].*$", "").trim();
```

### Dialog and Response

`AlertDialog.Builder` already used in `TermuxActivity` (r904, r1038, r1203) and `TerminalBridgeImpl` (r169). Pattern:
```java
new AlertDialog.Builder(mActivity)
    .setTitle("Bevestiging vereist")
    .setMessage(promptText)
    .setPositiveButton("Ja", (d, w) -> session.write("y\n"))
    .setNegativeButton("Nee", (d, w) -> session.write("n\n"))
    .setCancelable(false)
    .show();
```

Must post to main thread if called from a background thread — same `Handler(Looper.getMainLooper()).post()` pattern already established (CP-4).

### Guard Against Duplicate Dialogs

Track a boolean `mPromptDialogShowing`. Set to `true` when dialog opens, reset to `false` in both button callbacks. Check before showing.

### Pitfalls

- Claude Code prompts appear at end of line, but the line may still be partially rendered. Use a short debounce (200ms) to avoid triggering on partial lines.
- The session transcript from `getTranscriptText()` can contain ANSI codes. Strip them before regex matching. Simple approach: `output.replaceAll("\\x1B\\[[0-9;]*[mK]", "")`.
- Only intercept prompts when the terminal sheet is visible (state not `STATE_HIDDEN`), otherwise the user cannot interact with the dialog context.
- Prompt lines in `less`, `man`, or `nano` may also contain `[y/n]` patterns. The guard `mPromptDialogShowing` prevents stacking, and cancelling the dialog is acceptable.

---

## 3. BottomSheet Velocity/Fling (UXPL-03)

### Current Setup

`setupBottomSheet()` at r682–738 in `TermuxActivity.java`:
- `mBottomSheetBehavior` is `BottomSheetBehavior<View>`
- Callback has `onStateChanged()` and `onSlide()` (no-op)
- No velocity detection on the sheet drag handle itself

### Existing Fling Pattern

`mSessionSwipeDetector` at r768–789 uses `GestureDetector.SimpleOnGestureListener.onFling()` with velocity thresholds. Same pattern applicable to the drag handle.

### Implementation Strategy

Attach a `GestureDetector` to the `sheet_drag_handle` view (id `R.id.sheet_drag_handle`). In `onFling()`:

```java
View dragHandle = findViewById(R.id.sheet_drag_handle);
GestureDetector sheetFlingDetector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
    private static final float VELOCITY_THRESHOLD_DP = 1500f;

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
        float density = getResources().getDisplayMetrics().density;
        float threshold = VELOCITY_THRESHOLD_DP * density;
        if (velocityY < -threshold) {
            // Fling up — always expand
            mBottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
            return true;
        } else if (velocityY > threshold) {
            // Fling down — collapse to peek
            mBottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
            return true;
        }
        return false;
    }
});
dragHandle.setOnTouchListener((v, event) -> {
    sheetFlingDetector.onTouchEvent(event);
    return false; // let BottomSheetBehavior handle drag too
});
```

`return false` is critical — it lets `BottomSheetBehavior` continue to receive the touch events for dragging. `return true` would steal the events and prevent drag-based positioning.

### No Subclassing Needed

`BottomSheetBehavior` already handles fling internally, but its threshold is lower than 1500 dp/s. Overriding via a `GestureDetector` on the handle preempts its fling with explicit `setState()` before `BottomSheetBehavior` settles on an intermediate state.

### Pitfalls

- The drag handle is `48dp` tall — small touch target. The `GestureDetector` must be attached to the same view that receives the drag events, not a parent.
- `BottomSheetBehavior.STATE_SETTLING` will be emitted before `STATE_EXPANDED` — `onStateChanged` must handle this gracefully (it already does via the `DRAGGING/SETTLING` guard at r694–699).

---

## 4. RenderEffect Blur (UXPL-04)

### API Requirement

`RenderEffect.createBlurEffect()` requires API 31 (Android 12). `minSdkVersion=24` — fallback is mandatory.

From `gradle.properties`:
- `minSdkVersion=24`
- `compileSdkVersion=36`

### Target View

`flutter_container` (id `R.id.flutter_container`) — `FrameLayout`, fullscreen behind the sheet. This is what gets blurred.

### Implementation

In `onSlide()` callback (currently a no-op at r704–706):

```java
@Override
public void onSlide(@NonNull View bottomSheet, float slideOffset) {
    applyBlurForOffset(slideOffset);
}
```

```java
@RequiresApi(Build.VERSION_CODES.S)
private void applyBlurEffect(View target, float radius) {
    if (radius <= 0f) {
        target.setRenderEffect(null);
    } else {
        target.setRenderEffect(
            RenderEffect.createBlurEffect(radius, radius, Shader.TileMode.CLAMP)
        );
    }
}

private void applyBlurForOffset(float slideOffset) {
    // slideOffset: 0.0 = collapsed (peek), 1.0 = fully expanded
    // Clamp to [0, 1]
    float clamped = Math.max(0f, Math.min(1f, slideOffset));
    View flutterContainer = findViewById(R.id.flutter_container);
    if (flutterContainer == null) return;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        float blurRadius = clamped * 10f; // 0–10px
        applyBlurEffect(flutterContainer, blurRadius);
    } else {
        // Fallback: semi-transparent scrim
        int alpha = (int) (clamped * 0x80); // 0x00–0x80
        flutterContainer.setForeground(
            new android.graphics.drawable.ColorDrawable(
                android.graphics.Color.argb(alpha, 0, 0, 0)
            )
        );
    }
}
```

`slideOffset` comes from `BottomSheetBehavior` — it ranges from 0.0 (fully collapsed / peek) to 1.0 (fully expanded). At `STATE_HIDDEN`, offset is negative. Guard: `if (slideOffset < 0) slideOffset = 0`.

### Pitfalls

- `setRenderEffect(null)` clears the effect — must be called when `slideOffset == 0` to avoid persistent blur after collapse.
- `View.setForeground()` for the API < 31 fallback requires API 23+ — safe given `minSdkVersion=24`.
- Calling `setRenderEffect()` on every `onSlide()` event is potentially expensive. Consider throttling to every other call or only updating when the delta exceeds 0.05. In practice, `onSlide` is called ~60 fps during animation — keep the blur computation minimal (linear scaling only).
- The `@RequiresApi` annotation is needed to suppress lint warning without suppressing all lint.

---

## 5. VibrationEffect Haptics (UXPL-05)

### API Requirements

- `VibrationEffect` available from API 26. `minSdkVersion=24` — guard required.
- `VibrationEffect.EFFECT_TICK` and `VibrationEffect.EFFECT_CLICK` are API 29+. Guard separately.
- `Vibrator` service available all SDKs. `VibrationEffect` wraps it from API 26.
- `VIBRATE` permission already declared at `AndroidManifest.xml` r29.

### Existing Haptic Usage

`TerminalView.java` r267 uses `performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)` — this is a view-level haptic, no Vibrator needed, works all SDKs. Use as universal fallback.

### Helper Method

Add a private `triggerHaptic(int type)` to `TermuxActivity`:

```java
private static final int HAPTIC_TICK = 0;
private static final int HAPTIC_CLICK = 1;

private void triggerHaptic(int type) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        // API 29+: predefined effects
        Vibrator vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator == null) return;
        int effectId = (type == HAPTIC_TICK)
            ? VibrationEffect.EFFECT_TICK
            : VibrationEffect.EFFECT_CLICK;
        vibrator.vibrate(VibrationEffect.createPredefined(effectId));
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // API 26–28: one-shot vibration
        Vibrator vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        if (vibrator == null) return;
        vibrator.vibrate(VibrationEffect.createOneShot(
            type == HAPTIC_TICK ? 10L : 20L,
            VibrationEffect.DEFAULT_AMPLITUDE
        ));
    } else {
        // API 24–25: view-based fallback
        mTerminalView.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY);
    }
}
```

### Integration Points

1. **Sheet state changes** — in `onStateChanged()` at r689:
   ```java
   // Only on settled states
   if (newState == STATE_EXPANDED || newState == STATE_COLLAPSED || newState == STATE_HALF_EXPANDED) {
       triggerHaptic(HAPTIC_TICK);
   }
   ```

2. **Tab switch** — in `mTabSelectedListener.onTabSelected()` at r756:
   ```java
   triggerHaptic(HAPTIC_CLICK);
   ```

3. **Long-press path** — in `TermuxTerminalViewClient.onLongPress()`: the view already calls `performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)` if `onLongPress()` returns `false`. When returning `true` (path detected), call `mActivity.triggerHaptic(HAPTIC_TICK)` explicitly before showing the popup.

### Pitfalls

- `VibrationEffect.createPredefined()` is API 29+ despite being in the same `VibrationEffect` class as the API 26 methods. Separate guards are needed.
- Some OEMs (including Xiaomi/HyperOS) override haptic intensity system-wide. `EFFECT_TICK` and `EFFECT_CLICK` are predefined, so intensity is device-controlled — this is desirable.

---

## 6. Landscape Layout (UXPL-06)

### Configuration Change Handling

`AndroidManifest.xml` r58:
```xml
android:configChanges="orientation|screenSize|smallestScreenSize|density|screenLayout|keyboard|keyboardHidden|navigation"
```
`orientation` is in the list — no activity restart. `onConfigurationChanged()` is called instead.

`onConfigurationChanged()` is **not currently overridden** in `TermuxActivity.java`. It must be added.

### Layout Strategy

Create `app/src/main/res/layout-land/activity_termux.xml` as the landscape variant. Android inflates `res/layout-land/` automatically when `configChanges` includes `orientation` and `onConfigurationChanged` calls `setContentView()` again — but this approach requires re-initializing all views.

**Better approach:** A single layout with both portrait and landscape variants, switching visibility/parameters in `onConfigurationChanged()`. Use `ConstraintLayout` for the landscape-specific arrangement.

The simplest clean approach: the current layout uses `CoordinatorLayout` + `BottomSheetBehavior`. In landscape:
1. Remove `BottomSheetBehavior` from `terminal_sheet_container`
2. Place `flutter_container` (60% width) and `terminal_sheet_container` (40% width) side-by-side

Since `configChanges` prevents recreation, `setContentView()` can be called again in `onConfigurationChanged()`:

```java
@Override
public void onConfigurationChanged(@NonNull Configuration newConfig) {
    super.onConfigurationChanged(newConfig);
    boolean isLandscape = (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE);
    // Re-inflate the layout — portrait or landscape variant
    setContentView(R.layout.activity_termux); // Android picks layout-land/ automatically
    // Re-bind all view references
    rebindViews();
    if (isLandscape) {
        disableBottomSheetBehavior();
    } else {
        setupBottomSheet();
    }
    mTerminalView.updateSize();
}
```

### Layout-land File Structure

`res/layout-land/activity_termux.xml` — use `LinearLayout` with `android:orientation="horizontal"`:

```xml
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="horizontal">

    <FrameLayout
        android:id="@+id/flutter_container"
        android:layout_width="0dp"
        android:layout_height="match_parent"
        android:layout_weight="3" />  <!-- 60% -->

    <LinearLayout
        android:id="@+id/terminal_sheet_container"
        android:layout_width="0dp"
        android:layout_height="match_parent"
        android:layout_weight="2"     <!-- 40% -->
        android:orientation="vertical"
        android:background="@color/black">
        <!-- Same drag handle + tab bar + terminal content as portrait -->
    </LinearLayout>

</LinearLayout>
```

In landscape, `terminal_sheet_container` is a plain `LinearLayout` — **no** `BottomSheetBehavior`. The drag handle is still present visually for consistency, but non-functional.

### Tab Bar in Landscape

The tab bar stays as the top child of `terminal_sheet_container` in landscape — same XML structure, same IDs. No change needed to tab bar logic. `setupSessionTabBar()` can be called normally after `rebindViews()`.

### TerminalView.updateSize() Call

After orientation change, the terminal PTY must be resized. `mTerminalView.updateSize()` is already called in `BottomSheetCallback.onStateChanged()` — in landscape, call it once after `rebindViews()`.

### Pitfalls

- Re-calling `setContentView()` in `onConfigurationChanged()` destroys and recreates all views. All `findViewById()` references become stale. A `rebindViews()` method must re-assign `mTerminalView`, `mSessionTabLayout`, `mNewSessionTabButton`, etc.
- `FlutterFragment` is added to `R.id.flutter_container` in `setupFlutterFragment()` via `FragmentManager`. Re-inflating destroys the fragment container. Must re-attach the fragment in `rebindViews()` or use `FragmentTransaction.replace()`.
- `BottomSheetBehavior.from()` throws if called on a view not in a `CoordinatorLayout`. The landscape layout must not call `setupBottomSheet()`.
- The `OnBackPressedCallback` registered in `setupBottomSheet()` should be removed before re-calling setup on orientation change.

---

## 7. Accessibility (UXPL-07)

### Current State

Existing `contentDescription` attributes in `activity_termux.xml`:
- `new_session_tab_button`: `"New session"` (r66)
- `settings_tab_button`: `"Settings"` (r75)
- `settings_button` (drawer): `"@string/action_open_settings"` (r128)

Missing descriptions:
- `sheet_drag_handle` — no `contentDescription`
- `session_tab_layout` (the tabs themselves — set programmatically per tab)
- `terminal_view` — no `contentDescription`
- `toggle_keyboard_button`, `toggle_soul_button` (in drawer)

### TerminalView Accessibility

`TerminalView.java` already has `mAccessibilityEnabled` (r133) and at r511:
```java
if (mAccessibilityEnabled) setContentDescription(getText());
```
This sets the full terminal text as content description on each screen update — TalkBack will read it. This is the existing mechanism. The `AccessibilityLiveRegion.POLITE` attribute should be set in XML on the `TerminalView` to signal it updates:

```xml
android:accessibilityLiveRegion="polite"
```

### Content Descriptions to Add

In `activity_termux.xml`:
```xml
<!-- sheet_drag_handle -->
android:contentDescription="Terminal openen"

<!-- terminal_view (in TerminalView XML) -->
android:contentDescription="Terminal output"
```

Programmatically in `setupSessionTabBar()`, add per-tab descriptions when tabs are created:
```java
TabLayout.Tab tab = mSessionTabLayout.newTab();
tab.setText(sessionName);
tab.setContentDescription(sessionName + " sessie");
```

In `setSoulToggleButtonView()` and `setToggleKeyboardView()`, set descriptions:
```java
// toggle_soul_button
findViewById(R.id.toggle_soul_button).setContentDescription("SOUL AI toggling");
// toggle_keyboard_button
findViewById(R.id.toggle_keyboard_button).setContentDescription("Toetsenbord wisselen");
```

### TalkBack Announcements

Use `View.announceForAccessibility(CharSequence)` in:
1. `onStateChanged()` for sheet state transitions:
   ```java
   if (newState == STATE_EXPANDED) mTerminalView.announceForAccessibility("Terminal geopend");
   if (newState == STATE_COLLAPSED) mTerminalView.announceForAccessibility("Terminal gesloten");
   ```
2. `mTabSelectedListener.onTabSelected()` for session switches:
   ```java
   String label = tab.getText() != null ? tab.getText().toString() : "onbekend";
   mSessionTabLayout.announceForAccessibility("Sessie " + label);
   ```
3. In `PromptInterceptor` when y/n dialog appears:
   ```java
   mTerminalView.announceForAccessibility("Bevestiging vereist: " + promptText);
   ```

### Focus Order

The default focus order in the XML is: `flutter_container` → `terminal_sheet_container` (drag handle → tab bar → terminal view). This matches the required order. No explicit `android:nextFocusDown` overrides needed unless TalkBack testing reveals issues.

### Strings.xml

Hard-coded Dutch strings are acceptable per the CONTEXT decision ("Welke accessibility strings hardcoded vs in strings.xml" is Claude's discretion). For consistency with existing strings (see `action_open_settings` in strings.xml), add the new ones to `res/values/strings.xml`:
```xml
<string name="desc_terminal_drag_handle">Terminal openen</string>
<string name="desc_terminal_output">Terminal output</string>
<string name="announce_terminal_opened">Terminal geopend</string>
<string name="announce_terminal_closed">Terminal gesloten</string>
```

### Pitfalls

- `announceForAccessibility()` only fires when a `AccessibilityManager` is active. It is safe to call unconditionally.
- `setContentDescription()` on tabs must happen after `addTab()` — the tab view is created lazily.
- `AccessibilityLiveRegion.POLITE` on `TerminalView` will cause TalkBack to read new output aloud. This could be noisy during active terminal use. The existing mechanism (`setContentDescription(getText())` on each update) already handles this. Adding `POLITE` live region means TalkBack announces changes automatically — the implementation is opt-in at the attribute level.

---

## API Level Summary

| Feature | Min API | Notes |
|---------|---------|-------|
| UXPL-01 path detection | 24 | No new API requirements |
| UXPL-02 y/n dialog | 24 | No new API requirements |
| UXPL-03 velocity fling | 24 | GestureDetector, no new API |
| UXPL-04 RenderEffect blur | 31 for blur, 24 for scrim fallback | `@RequiresApi(S)` annotation needed |
| UXPL-05 VibrationEffect predefined | 29 for EFFECT_TICK; 26 for one-shot; 24 for view fallback | Triple guard |
| UXPL-06 landscape layout | 24 | `onConfigurationChanged` already handled |
| UXPL-07 accessibility | 24 | `announceForAccessibility`, `contentDescription` all available |

`minSdkVersion=24`, `targetSdkVersion=28`, `compileSdkVersion=36`.

---

## Dependencies Between Features

- **UXPL-01 depends on nothing** — isolated to `TermuxTerminalViewClient.onLongPress()`
- **UXPL-02 depends on nothing** — isolated to `TermuxTerminalSessionActivityClient.onTextChanged()` + new `PromptInterceptor`
- **UXPL-03 depends on UXPL-05** — sheet fling triggers haptic feedback; implement haptics helper first or alongside
- **UXPL-04 depends on UXPL-03** — both use `BottomSheetCallback`; implement in same callback extension
- **UXPL-05 depends on nothing** — standalone `triggerHaptic()` helper in `TermuxActivity`
- **UXPL-06 has risk of breaking UXPL-03/04** — landscape layout removes `BottomSheetBehavior`; blur/fling logic must be guarded with `if (!isLandscape())`
- **UXPL-07 depends on UXPL-01 and UXPL-02** — accessibility announcements needed in path dialog and y/n dialog

**Recommended implementation order:** UXPL-05 → UXPL-03 → UXPL-04 → UXPL-01 → UXPL-02 → UXPL-06 → UXPL-07

---

## Key Files Summary

| File | Role |
|------|------|
| `app/src/main/java/com/termux/app/TermuxActivity.java` | Sheet setup (r682), tab listener (r754), all haptic/blur integration |
| `app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java` | `onLongPress()` hook at r368 |
| `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` | `onTextChanged()` hook at r128 |
| `terminal-emulator/src/main/java/com/termux/terminal/TerminalBuffer.java` | `getWordAtLocation()` at r108 |
| `terminal-view/src/main/java/com/termux/view/TerminalView.java` | `onLongPress` dispatch r264, haptic r267, accessibility r511 |
| `terminal-view/src/main/java/com/termux/view/GestureAndScaleRecognizer.java` | `onLongPress` in GestureDetector at r54 |
| `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` | `sendInput()` at r182, `AlertDialog` pattern at r169 |
| `app/src/main/java/com/termux/bridge/SoulBridgeController.java` | Debounce pattern to reuse for UXPL-02 |
| `app/src/main/res/layout/activity_termux.xml` | Current portrait layout, content descriptions |
| `app/src/main/AndroidManifest.xml` | `VIBRATE` r29, `configChanges` r58 |
| `gradle.properties` | `minSdkVersion=24`, `compileSdkVersion=36` |

---

## Validation Architecture

How each requirement can be verified after implementation:

### UXPL-01 — Path long-press
1. Run `ls -la` in terminal — long-press on a displayed filename
2. Verify `PopupMenu` appears with "Kopieer pad" option
3. Tap "Kopieer pad" — verify path is in clipboard via paste
4. For existing path: verify "Open" option appears
5. For non-existent path: verify only "Kopieer pad" appears
6. Long-press on non-path text (e.g., `bash`) — verify text selection mode activates (not path menu)

### UXPL-02 — Y/N prompt interception
1. Run `rm somefile` when file does not exist — no prompt expected, no dialog
2. Use a shell script: `read -p "Doorgaan? [y/N] " yn` — verify `AlertDialog` appears
3. Tap "Ja" in dialog — verify `y\n` was sent (file acted upon or `yes` echoed)
4. Tap "Nee" — verify `n\n` was sent
5. Verify no duplicate dialogs if two prompts appear in rapid succession

### UXPL-03 — Velocity-based sheet expand
1. Slowly drag sheet up — verify it stops at intermediate state (half-expanded)
2. Fast fling upward from collapsed state — verify sheet goes to `STATE_EXPANDED` (full screen)
3. Fast fling downward from expanded state — verify sheet collapses to peek
4. Check with `Logger.logDebug` that `STATE_EXPANDED` is reached after fast fling

### UXPL-04 — RenderEffect blur
1. Slowly drag sheet from collapsed to expanded — verify SOUL chat behind sheet gradually blurs
2. On API 31+ device: check blur is visible (not just black)
3. On API < 31: verify dark scrim darkens progressively (not blur, but visual feedback)
4. Collapse sheet fully — verify blur/scrim is removed (SOUL chat fully clear)

### UXPL-05 — Haptic feedback
1. Open sheet (collapse → half-expanded) — feel `EFFECT_TICK` vibration
2. Expand sheet to full — feel `EFFECT_TICK`
3. Switch between terminal sessions via tab — feel `EFFECT_CLICK`
4. Long-press on path in terminal — feel `EFFECT_TICK` (or LONG_PRESS fallback)
5. Test on API 24/25 device — verify no crash, view-level haptic fires

### UXPL-06 — Landscape side drawer
1. Rotate device to landscape — verify SOUL chat on left (60%), terminal on right (40%)
2. Verify tab bar visible above terminal in landscape
3. Rotate back to portrait — verify bottom sheet behavior restored, tab bar still functional
4. Verify terminal content continues running through rotation (no session restart)
5. Run `tput cols` in terminal after rotation — verify column count matches 40% screen width

### UXPL-07 — Accessibility / TalkBack
1. Enable TalkBack — navigate to app
2. Double-tap drag handle — verify "Terminal openen" is read aloud
3. Navigate to `+` tab button — verify "Nieuwe sessie" read aloud
4. Switch terminal sessions with TalkBack — verify session name announced
5. Open/close sheet — verify "Terminal geopend" / "Terminal gesloten" announced
6. Navigate to settings button — verify settings description read

---

## RESEARCH COMPLETE
