# Phase 08: Session Management — Research

**Gathered:** 2026-03-21
**Researcher:** Phase Researcher Agent

---

## Executive Summary

- **ViewPager2 is NOT in build.gradle** — only the deprecated `androidx.viewpager:viewpager:1.0.0` is present. `androidx.viewpager2:viewpager2:1.1.0` must be added.
- **TerminalView is a single view** that swaps sessions via `attachSession()` — there is no per-session view to put in a ViewPager2 page. The adapter pattern must be a fake/custom adapter that only signals index changes, not inflates views.
- **`termuxSessionListNotifyUpdated()`** is the existing hook called whenever the session list changes — the tab bar must also update here.
- **`checkAndScrollToSession()`** in `TermuxTerminalSessionActivityClient` still references the ListView (`R.id.terminal_sessions_list`) — this will need to be replaced/guarded once the ListView is removed from the drawer.
- **DrawerLayout swipe is currently the primary session navigation** — disabling it (`LOCK_MODE_LOCKED_CLOSED`) and removing the ListView + "New session" button are required but will break `setToggleKeyboardView()` which calls `getDrawer().closeDrawers()` after keyboard toggle. This needs review.
- **Pigeon `TerminalBridgeApi` currently uses `getLastTermuxSession()`** in `getCurrentTerminalSession()` — for `closeSession` and `switchSession` by index, proper index-based lookups already exist in TermuxService.

---

## Session Architecture

### Service layer (`TermuxService`)

Sessions live in `mShellManager.mTermuxSessions` — a `List<TermuxSession>`. Key methods:

| Method | Purpose |
|--------|---------|
| `createTermuxSession(...)` | Creates session, adds to list, calls `termuxSessionListNotifyUpdated()` |
| `removeTermuxSession(TerminalSession)` | Calls `finish()` on session at index, returns index |
| `getTermuxSession(int index)` | Index-based lookup |
| `getIndexOfSession(TerminalSession)` | Reverse lookup: TerminalSession → index |
| `getTermuxSessions()` | Returns the full list |
| `getTermuxSessionsSize()` | Count |
| `getLastTermuxSession()` | Last session (currently used by Pigeon bridge) |

Session creation path: `addNewSession()` in `TermuxTerminalSessionActivityClient` → `service.createTermuxSession()` → added to `mTermuxSessions` → `termuxSessionListNotifyUpdated()` called.

Session removal path: `removeFinishedSession()` → `service.removeTermuxSession()` (calls `finish()`) → `onTermuxSessionExited()` callback → session removed from list → `termuxSessionListNotifyUpdated()` called.

`MAX_SESSIONS = 8` is enforced in `TermuxTerminalSessionActivityClient.addNewSession()`.

### Activity client (`TermuxTerminalSessionActivityClient`)

All session UI operations go through this class:

| Method | Notes |
|--------|-------|
| `setCurrentSession(TerminalSession)` | Calls `mTerminalView.attachSession(session)` — this is the single view swap |
| `switchToSession(boolean forward)` | Wraps around at boundaries |
| `switchToSession(int index)` | Direct index switch |
| `addNewSession(boolean isFailSafe, String name)` | Creates + immediately sets as current |
| `removeFinishedSession(TerminalSession)` | Removes and switches to adjacent session |
| `renameSession(TerminalSession)` | Shows TextInputDialog, then calls private `renameSession(session, text)` |
| `termuxSessionListNotifyUpdated()` | Calls `mActivity.termuxSessionListNotifyUpdated()` |
| `checkAndScrollToSession(TerminalSession)` | **PROBLEM**: hardcoded `R.id.terminal_sessions_list` ListView lookup |

`onSessionFinished()` auto-removes sessions with exit code 0 or 130 (normal/Ctrl-C exit).

### `TermuxActivity.termuxSessionListNotifyUpdated()`

Currently calls `mTermuxSessionListViewController.notifyDataSetChanged()`. This is the hook to also update the tab bar — extend it to call a tab bar update method.

---

## Current Session UI

`TermuxSessionsListViewController` is an `ArrayAdapter<TermuxSession>` wired to `R.id.terminal_sessions_list` (a `ListView` inside the drawer).

- Items display: `[N] sessionName\nterminaltitle` — bold number+name, italic title
- Running sessions: normal color; exited with error: red; exited OK: strikethrough
- `onItemClick`: calls `setCurrentSession()` + `closeDrawers()`
- `onItemLongClick`: calls `renameSession()` — only rename, no close option

**What to keep**: The session rendering logic (name + running state) can be extracted for tab labels.
**What to remove**: The entire ListView from the drawer, the `mTermuxSessionListViewController` field, `setTermuxSessionsListView()` call in `onServiceConnected`.
**What to update**: `termuxSessionListNotifyUpdated()` — replace `notifyDataSetChanged()` with tab bar refresh.

---

## TabLayout + ViewPager2 Integration

### The Core Problem

`TerminalView` is a single Android `View` that renders one session at a time via `attachSession(TerminalSession)`. ViewPager2 normally expects each page to be a separate Fragment or View. We cannot put `TerminalView` in a ViewPager2 page — it must remain a single view in the layout.

### Solution: Fake Adapter Pattern

Create a `SessionTabsAdapter extends RecyclerView.Adapter` (required by ViewPager2). Each "item" is a minimal placeholder `View` (e.g., an empty `View` with `MATCH_PARENT`). The adapter item count = session count.

ViewPager2 page changes trigger `onPageSelected(position)` → `switchToSession(position)` → `mTerminalView.attachSession(...)`. The TerminalView content updates without any view replacement.

```
ViewPager2 (position N) ──onPageSelected──> switchToSession(N) ──> TerminalView.attachSession(sessions[N])
```

**TabLayoutMediator** links the `TabLayout` tab text to the adapter position. Tab text = process name or session name.

### Adapter implementation notes

- `getItemCount()`: returns `mTermuxService.getTermuxSessionsSize()`
- `onCreateViewHolder()`: returns a ViewHolder with an empty `View(context)` — the actual terminal content is always the single `mTerminalView`
- `onBindViewHolder()`: no-op (placeholder views have no content)
- The adapter must be invalidated (`notifyDataSetChanged()`) whenever sessions are added/removed

### TabLayoutMediator

```java
new TabLayoutMediator(mSessionTabLayout, mSessionViewPager2, (tab, position) -> {
    tab.setText(getProcessNameForSession(position));
}).attach();
```

Tab text is set dynamically. The mediator is reattached when session count changes (or tab text is updated via `tab.setText()` on existing tabs).

### `+` button

Not a tab — a separate `ImageButton` positioned at the end of the tab bar row (via horizontal `LinearLayout` or `ConstraintLayout`). Click handler: `addNewSession(false, null)`.

---

## Process Name Reading

### Mechanism

Each `TerminalSession` has a PID accessible via `mExecutionCommand.mPid` on the associated `TermuxSession`. The PID is set via `setTerminalShellPid()` callback in `TermuxTerminalSessionActivityClient` (already implemented).

Read `/proc/PID/cmdline`: the file contains null-byte-separated args. The first token (before the first `\0`) is the process name. On Android, no special permissions are needed to read `/proc/PID/cmdline` for processes in the same app.

```java
private String readCmdlineForPid(int pid) {
    try (FileInputStream fis = new FileInputStream("/proc/" + pid + "/cmdline")) {
        byte[] buffer = new byte[256];
        int read = fis.read(buffer);
        if (read <= 0) return null;
        // Find first null byte
        int end = 0;
        while (end < read && buffer[end] != 0) end++;
        String fullPath = new String(buffer, 0, end);
        // Extract basename: "/usr/bin/python3" → "python3"
        int slash = fullPath.lastIndexOf('/');
        return slash >= 0 ? fullPath.substring(slash + 1) : fullPath;
    } catch (IOException e) {
        return null;
    }
}
```

**Edge cases:**
- PID 0 or -1: PID not yet set (session just started) — fall back to session name
- Process has exited: file does not exist → `IOException` → fall back
- PID is a shell wrapper (`bash`, `sh`): cmdline shows the shell — that is actually useful and correct
- Long path names: buffer of 256 bytes is enough for the first argument

### Fallback chain

1. `/proc/PID/cmdline` basename
2. `TerminalSession.mSessionName` (if non-null and non-empty)
3. `"Session " + (index + 1)`

### Polling

Use a `Handler(Looper.getMainLooper())` with a `Runnable` that posts itself with a 2-second delay. Start polling in `onStart()`, stop in `onStop()`. Update all tab texts on each poll tick.

```java
private final Runnable mProcessNamePoller = new Runnable() {
    @Override
    public void run() {
        updateAllTabLabels();
        mHandler.postDelayed(this, 2000);
    }
};
```

The Handler should be a new `Handler(Looper.getMainLooper())` in `TermuxActivity` (not the one in `TermuxService`).

---

## Pigeon API Extensions

### Current state (`terminal_bridge.dart` + `TerminalBridgeImpl.java`)

**HostApi (Flutter → Java):**
- `executeCommand(String command)` — writes to last session
- `getTerminalOutput(int lines)` — reads from last session
- `createSession()` → returns index
- `listSessions()` → `List<SessionInfo>`

**FlutterApi (Java → Flutter):**
- `onTerminalOutput(String output)` — debounced output stream
- `onSessionChanged(SessionInfo info)` — active session changed

**Problem in `TerminalBridgeImpl`**: `getCurrentTerminalSession()` always returns `getLastTermuxSession()`. This is wrong for multi-session — it should track the actual current session.

### New HostApi methods to add

```dart
// Close session by index. If it's the current, switches to adjacent.
void closeSession(int id);

// Switch to session by index.
void switchSession(int id);

// Rename session by index.
void renameSession(int id, String name);
```

### New FlutterApi method to add

```dart
// Called whenever session list changes (add/remove/rename).
void onSessionListChanged(List<SessionInfo> sessions);
```

### Implementation notes

- `closeSession(id)`: look up by index → call `terminalSession.finishIfRunning()`. `removeFinishedSession` will be called via the `onSessionFinished` callback path — do not call it directly from Pigeon to avoid double-removal.
- `switchSession(id)`: call `mTermuxTerminalSessionActivityClient.switchToSession(id)` — must be wrapped in `Handler(Looper.getMainLooper()).post()` per CP-4.
- `renameSession(id, name)`: call the private `renameSession(session, name)` path directly (no dialog), then call `termuxSessionListNotifyUpdated()`.
- `onSessionListChanged` should be fired from `termuxSessionListNotifyUpdated()` — already the central update hook.

### Pigeon regeneration

After modifying `flutter_module/pigeons/terminal_bridge.dart`, run Pigeon to regenerate:
- `flutter_module/lib/generated/terminal_bridge.g.dart`
- `app/src/main/java/com/termux/bridge/TerminalBridgeApi.java`

---

## Layout Integration

### Current sheet structure (`activity_termux.xml`)

```
CoordinatorLayout
└── LinearLayout (terminal_sheet_container) [BottomSheetBehavior]
    ├── FrameLayout (sheet_drag_handle, 48dp)    ← drag handle with pill
    └── RelativeLayout (activity_termux_root_relative_layout)
        ├── DrawerLayout (drawer_layout)
        │   ├── TerminalView (terminal_view)
        │   └── LinearLayout (left_drawer) [gravity=start]
        │       ├── settings_button
        │       ├── terminal_sessions_list (ListView)
        │       └── [toggle_keyboard, new_session, toggle_soul buttons]
        └── ViewPager (terminal_toolbar_view_pager) [alignParentBottom]
```

### Tab bar insertion point

Insert a new `LinearLayout` (horizontal) between `sheet_drag_handle` and `activity_termux_root_relative_layout` in the sheet's `LinearLayout`:

```xml
<!-- Between drag handle and RelativeLayout -->
<LinearLayout
    android:id="@+id/session_tab_bar"
    android:layout_width="match_parent"
    android:layout_height="36dp"
    android:orientation="horizontal"
    android:background="#0F0F23">

    <com.google.android.material.tabs.TabLayout
        android:id="@+id/session_tab_layout"
        android:layout_width="0dp"
        android:layout_height="match_parent"
        android:layout_weight="1"
        app:tabMode="scrollable"
        app:tabBackground="@null"
        app:tabSelectedTextColor="#E0E0E0"
        app:tabTextColor="#9E9E9E"
        app:tabIndicatorColor="#6C63FF"
        app:tabIndicatorHeight="2dp" />

    <ImageButton
        android:id="@+id/new_session_tab_button"
        android:layout_width="36dp"
        android:layout_height="match_parent"
        android:src="@drawable/ic_add"
        android:background="@null"
        android:contentDescription="New session" />

</LinearLayout>

<!-- ViewPager2 (hidden, used only for tab swipe gesture detection) -->
<androidx.viewpager2.widget.ViewPager2
    android:id="@+id/session_view_pager"
    android:layout_width="match_parent"
    android:layout_height="0dp"
    android:visibility="gone" />
```

**Wait** — if ViewPager2 is `GONE`, the swipe gesture won't work. The ViewPager2 must be visible but positioned over the TerminalView in a way that intercepts horizontal swipe only. This is the central touch conflict problem — see below.

### Revised approach

ViewPager2 is NOT placed in the layout as a content container. The swipe-to-switch is implemented via a custom `GestureDetector` on the TerminalView's gesture pipeline, OR via a thin transparent overlay. The TabLayout + `+` button live in the 36dp bar. Session switching from ViewPager2 swipe is replaced by a horizontal swipe gesture detector on the TerminalView itself.

**Simpler alternative**: Use `TabLayout` only (no ViewPager2). Swipe-to-switch (SESS-05) is implemented via a horizontal swipe detector added to the `DrawerLayout` or the `RelativeLayout` container — intercepts horizontal swipes when the drawer is locked closed.

---

## Drawer Conflict Resolution

### Current state

- Drawer opens on left-edge swipe (`gravity=start`)
- `getDrawer().closeDrawers()` is called in: `addNewSession()`, `setToggleKeyboardView()`, `setSoulToggleButtonView()`, `onItemClick` (session list)

### Required changes

1. **Lock drawer swipe**: In `setupBottomSheet()` or a new `setupSessionTabs()` method:
   ```java
   getDrawer().setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
   ```

2. **Remove session UI from drawer**: Remove `terminal_sessions_list` ListView and `new_session_button` from `activity_termux.xml`. The `toggle_keyboard_button` and `toggle_soul_button` can remain if the drawer is still openable via button (but swipe is locked).

3. **Settings access**: The `settings_button` in the drawer becomes unreachable when swipe is locked. Options:
   - Add an overflow menu icon to the drag handle or tab bar that opens settings
   - Keep the drawer accessible via button tap (lock only swipe, not programmatic open)
   - Move settings to a long-press gesture on the drag handle

   **Recommendation**: Add a `⋮` (overflow) `ImageButton` to the tab bar row (right of the `+` button), whose click opens `SettingsActivity` directly. The drawer can then be removed entirely from the layout, or kept but only for the settings button (the `left_drawer` `LinearLayout` keeps only `settings_button`).

4. **`closeDrawers()` call sites**: After locking the drawer, these calls become no-ops — safe to leave as-is.

---

## Touch Conflict Analysis

### Conflict matrix

| Gesture | Direction | Handler | Conflict |
|---------|-----------|---------|----------|
| Terminal scroll | Vertical | TerminalView (NestedScrollingChild3) | None (Phase 7 resolved) |
| Sheet drag | Vertical | BottomSheetBehavior | None (Phase 7 resolved) |
| Session swipe | Horizontal | To be implemented | Conflicts with drawer (resolved by locking) |
| Extra keys toolbar scroll | Horizontal | ViewPager v1 | No conflict (different area) |

### SESS-05 swipe implementation without ViewPager2

Implement a `GestureDetector` overlay on the terminal content area (the `RelativeLayout` containing the DrawerLayout):

```java
GestureDetector sessionSwipeDetector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
    private static final int SWIPE_MIN_DISTANCE = 120;
    private static final int SWIPE_THRESHOLD_VELOCITY = 200;

    @Override
    public boolean onFling(MotionEvent e1, MotionEvent e2, float vX, float vY) {
        float deltaX = e2.getX() - e1.getX();
        if (Math.abs(deltaX) > SWIPE_MIN_DISTANCE && Math.abs(vX) > SWIPE_THRESHOLD_VELOCITY) {
            if (deltaX < 0) { // swipe left → next session
                mTermuxTerminalSessionActivityClient.switchToSession(true);
            } else { // swipe right → previous session
                mTermuxTerminalSessionActivityClient.switchToSession(false);
            }
            return true;
        }
        return false;
    }
});
```

Wire this in `TerminalView.onTouchEvent()` or via `TermuxTerminalViewClient`. The TerminalView already has a `GestureAndScaleRecognizer` — the session swipe detector should be chained after it, only consuming horizontal flings when the drawer is locked.

**Alternative**: Use ViewPager2 with a custom `RecyclerView.ItemAnimator` and visibility tricks. However, the fake-adapter approach with a transparent ViewPager2 overlay is complex and fragile. The GestureDetector approach is simpler and more maintainable.

### Tab tap conflict

TabLayout tab clicks call `setCurrentSession()` directly. No conflict.

### Long-press conflict

Tab long-press for context menu: use `tab.view.setOnLongClickListener()`. The TerminalView long-press (context menu) only fires when touching the terminal content, not the tab bar.

---

## Pitfalls & Risks

### 1. ViewPager2 dependency missing
`app/build.gradle` only has `androidx.viewpager:viewpager:1.0.0`. If ViewPager2 is used, `androidx.viewpager2:viewpager2:1.1.0` must be added. **If the swipe-without-ViewPager2 approach is chosen, this dependency is not needed.**

### 2. `checkAndScrollToSession()` crash
`TermuxTerminalSessionActivityClient.checkAndScrollToSession()` does `findViewById(R.id.terminal_sessions_list)` — this will silently return null after the ListView is removed. The null-check `if (termuxSessionsListView == null) return;` is already present, so it won't crash, but it's dead code. Should be replaced with a tab scroll call.

### 3. `termuxSessionListNotifyUpdated()` called before tab bar initialized
This method is called during `onServiceConnected()` → `setCurrentSession()` → early in activity lifecycle. The tab bar must be initialized before `onServiceConnected()` can fire, or the update call must be guarded (`if (mSessionTabLayout != null)`).

### 4. `addNewSession()` calls `mActivity.getDrawer().closeDrawers()`
After locking the drawer, `closeDrawers()` is a no-op. Safe, but should be cleaned up.

### 5. Session PID availability
`mExecutionCommand.mPid` is set via `setTerminalShellPid()` callback which fires after the PTY forks. There is a brief period after `addNewSession()` where PID is 0. The poll interval of 2s handles this gracefully — first tick may show fallback name.

### 6. `MAX_SESSIONS = 8` limit
Currently enforced with an `AlertDialog`. The tab bar `+` button should also respect this and be visually disabled (or show the same dialog) when at 8 sessions. The existing alert dialog path already handles this.

### 7. `onSessionFinished` auto-removal race
When a session exits with code 0, `removeFinishedSession()` is called automatically. The tab bar must handle the case where the tab count decreases without explicit user action. Since `termuxSessionListNotifyUpdated()` is called in the removal path, the tab bar update hook fires correctly.

### 8. Pigeon `closeSession` vs `finishIfRunning`
Calling `finishIfRunning()` triggers `onSessionFinished()` → `removeFinishedSession()`. The Pigeon `closeSession` implementation must NOT additionally call `removeTermuxSession()` to avoid double removal.

### 9. `TerminalBridgeImpl.getCurrentTerminalSession()` is wrong
It always returns the last session. For `executeCommand` and `getTerminalOutput`, it should return the *currently active* session. `TerminalBridgeImpl` needs a reference to `TermuxActivity` (or a callback) to get `getCurrentSession()`. Currently it only holds `TermuxService`. Fix: pass `TermuxActivity` reference or add a `getCurrentSession()` method to `TermuxService` that delegates to the activity client.

### 10. Tab bar visible in peek state (48dp)
The sheet's `peekHeight` is 48dp, which equals the drag handle height. The tab bar (36dp) is BELOW the drag handle. In collapsed state, only the 48dp drag handle is visible — the tab bar is hidden. This is correct behavior (tabs are only relevant when the sheet is open). No conflict.

---

## Validation Architecture

| Requirement | Validation |
|-------------|------------|
| **SESS-01**: Tab bar visible | Manual: expand sheet → tab bar appears below drag handle with session tabs |
| **SESS-02**: Process names | Manual: open `python3` in a session → tab shows "python3" within 2s |
| **SESS-03**: New session via + | Manual: tap `+` → new tab appears, TerminalView shows new shell |
| **SESS-04**: Rename/close via long press | Manual: long-press tab → context menu → "Hernoemen" shows dialog, "Sluiten" removes tab |
| **SESS-05**: Swipe to switch | Manual: horizontal swipe on terminal → session switches (tab updates) |
| **SESS-06**: SOUL can create/close | Functional: Flutter `TerminalBridgeApi.createSession()` → new tab appears; `closeSession(id)` → tab disappears |

Edge case validation:
- Single session + close: app should not crash (currently shows dialog or finishes activity — preserve this)
- 8 sessions + `+` tap: existing AlertDialog fires
- Session exits naturally (code 0): tab disappears automatically
- Rotate screen / process death: tab count restored from `TermuxService` session list (service survives)

---

## RESEARCH COMPLETE
