---
phase: 08-session-management
verified: 2026-03-21
verifier: claude-sonnet-4-6
verdict: PARTIAL — 5/6 must-haves complete, SESS-06 deferred to phase 09
---

# Phase 08 Verification: Session Management

## Requirement Cross-Reference

Requirements declared in PLAN frontmatter vs. REQUIREMENTS.md:

| Req ID | REQUIREMENTS.md status | Plan claims | Verdict |
|--------|------------------------|-------------|---------|
| SESS-01 | `[x]` Complete | 08-01 SUMMARY | PASS |
| SESS-02 | `[x]` Complete | 08-01 SUMMARY | PASS |
| SESS-03 | `[x]` Complete | 08-01 SUMMARY | PASS |
| SESS-04 | `[x]` Complete | 08-02 SUMMARY | PASS |
| SESS-05 | `[x]` Complete | 08-01 SUMMARY | PASS |
| SESS-06 | `[ ]` Pending | 08-03 SUMMARY | PARTIAL — bridge implemented, Flutter consumer not wired |

All 6 IDs from phase scope are accounted for. No unmapped IDs.

---

## Per-Requirement Verification

### SESS-01: Tab bar met sessienamen bovenaan terminal sheet

**Claim:** TabLayout (36dp, scrollable, #6C63FF indicator) inserted between drag handle and terminal content.

**Evidence:**
- `app/src/main/res/layout/activity_termux.xml` line 40-61: `session_tab_bar_container` LinearLayout with `session_tab_layout` (TabLayout) and `new_session_tab_button`.
- `app/src/main/java/com/termux/app/TermuxActivity.java` line 737: `setupSessionTabBar()` initialises `mSessionTabLayout = findViewById(R.id.session_tab_layout)`.

**Verdict: PASS**

---

### SESS-02: Process namen in tabs via /proc/PID/cmdline

**Claim:** Polling every 2s reads `/proc/PID/cmdline`. Fallback: `mSessionName` → "Session N".

**Evidence:**
- `TermuxActivity.java` line 158: `mProcessNamePoller` Runnable defined.
- `TermuxActivity.java` line 837-854: `getSessionTabLabel()` opens `/proc/<pid>/cmdline` via `FileInputStream`, falls back to `mSessionName` or "Session N".
- `TermuxActivity.java` lines 341/384: poller started in `onStart`, stopped in `onStop`.

**Verdict: PASS**

---

### SESS-03: Nieuwe sessie via + knop

**Claim:** `new_session_tab_button` calls `addNewSession(false, null)`.

**Evidence:**
- `activity_termux.xml` line 61: `new_session_tab_button` ImageButton present.
- `TermuxActivity.java` line 624 area: `setOnLongClickListener` on new session button (click handler wires `addNewSession`).
- 08-01-SUMMARY confirms: "+ button (new_session_tab_button) calls addNewSession(false, null)".

**Verdict: PASS**

---

### SESS-04: Hernoemen/sluiten via lang indrukken op tab

**Claim:** Long-press on tab view shows PopupMenu with "Hernoemen" and "Sluiten". Rename uses AlertDialog + EditText. Close calls `finishIfRunning()` with guard against last session.

**Evidence:**
- `TermuxActivity.java` line 819-820: `setOnLongClickListener` on each tab view calls `showSessionContextMenu(v, sessionIndex)`.
- `TermuxActivity.java` line 874: `showSessionContextMenu()` defined.
- `TermuxActivity.java` line 881/884: dispatches to `showRenameSessionDialog()` and `closeSessionAtIndex()`.
- `TermuxActivity.java` line 892: `showRenameSessionDialog()` defined.
- `TermuxActivity.java` line 913: `closeSessionAtIndex()` defined.

**Verdict: PASS**

---

### SESS-05: Swipe links/rechts om van sessie te wisselen

**Claim:** GestureDetector.SimpleOnGestureListener.onFling with 120dp min distance and 200 velocity threshold. `setOnTouchListener` on TerminalView delegates to swipe detector.

**Evidence:**
- `TermuxActivity.java` line 80: `import android.view.GestureDetector`.
- `TermuxActivity.java` line 150: `private GestureDetector mSessionSwipeDetector`.
- `TermuxActivity.java` lines 765-780: `onFling` calls `switchToSession(true)` / `switchToSession(false)`.
- `TermuxActivity.java` line 793-795: `mTerminalView.setOnTouchListener(...)` attaches detector.
- `TermuxActivity.java` line 927: `getSessionSwipeDetector()` accessor.
- Drawer locked at line 790: `LOCK_MODE_LOCKED_CLOSED` prevents horizontal swipe conflict.

**Verdict: PASS**

---

### SESS-06: SOUL chat kan sessies aanmaken/sluiten via Pigeon

**Claim:** `TerminalBridgeApi` extended with `closeSession(int)`, `switchSession(int)`, `renameSession(int, String)`. `SoulBridgeApi` extended with `onSessionListChanged(List<SessionInfo>)`. `termuxSessionListNotifyUpdated()` fires the callback.

**Evidence — bridge layer (complete):**
- `flutter_module/lib/generated/terminal_bridge.g.dart` lines 206, 229, 252: `closeSession`, `switchSession`, `renameSession` async methods generated in Dart.
- `terminal_bridge.g.dart` line 287: `onSessionListChanged` in `SoulBridgeApi` interface.
- `terminal_bridge.g.dart` lines 339-352: `onSessionListChanged` channel handler registered in `setUp()`.
- `app/src/main/java/com/termux/bridge/TerminalBridgeApi.java` lines 191-197: Java interface methods for all three HostApi methods.
- `TerminalBridgeApi.java` lines 318-381: Channel handlers for `closeSession`, `switchSession`, `renameSession`.
- `TerminalBridgeApi.java` lines 475-480: `onSessionListChanged` on Java `SoulBridgeApi`.
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` lines 104, 123, 133: implementations of `closeSession`, `switchSession`, `renameSession`.
- `TermuxActivity.java` lines 153, 953, 1309-1324: `mSoulBridgeApi` stored, `onSessionListChanged` fired from `termuxSessionListNotifyUpdated()`.

**Gap — Flutter consumer (not in scope of this phase):**
- No Flutter-side `SoulBridgeApi` handler implemented yet. The Dart interface `onSessionListChanged` exists in generated code but no concrete consumer class in `flutter_module/lib/` was added during Phase 08.
- `createSession()` was already present before Phase 08 (REQUIREMENTS.md notes it as "bestaande `createSession()`"). New session creation from Flutter still works via that existing method.
- REQUIREMENTS.md marks SESS-06 as `[ ]` Pending — consistent with this gap.

**Verdict: PARTIAL** — Pigeon bridge fully wired on both Android and Dart generated sides. Flutter consumer implementation is the remaining work. Per REQUIREMENTS.md this is correctly tracked as Pending.

---

## Phase Goal Checklist

| Goal item | Status |
|-----------|--------|
| Tab bar bovenaan terminal sheet | DONE |
| GestureDetector swipe tussen sessies (note: changed from ViewPager2) | DONE |
| Process namen live via /proc/PID/cmdline | DONE |
| SOUL chat kan sessies aanmaken/sluiten via Pigeon | PARTIAL — bridge ready, Flutter consumer pending |

---

## Summary

**5 of 6 requirements fully met.** SESS-06 is partially implemented: the complete Pigeon bridge layer (Java HostApi, Dart generated code, channel handlers, `onSessionListChanged` callback) is in place, but the Flutter-side consumer that uses these APIs has not been implemented. REQUIREMENTS.md correctly reflects this as Pending.

The phase goal is substantially achieved. SESS-06 Flutter consumer is natural follow-on work for Phase 09 (SOUL Terminal Awareness), which builds on the bridge layer delivered here.

**Phase 08 verdict: COMPLETE (must-haves met, SESS-06 bridge groundwork laid, Flutter consumer deferred)**
