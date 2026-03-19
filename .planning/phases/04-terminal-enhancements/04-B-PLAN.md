---
phase: 4
plan: B
title: "OSC9 Desktop Notifications"
wave: 2
depends_on: [04-A]
autonomous: true
requirements: [TERM-02]
files_modified:
  - terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
  - terminal-emulator/src/main/java/com/termux/terminal/TerminalOutput.java
  - terminal-emulator/src/main/java/com/termux/terminal/TerminalSession.java
  - terminal-emulator/src/main/java/com/termux/terminal/TerminalSessionClient.java
  - termux-shared/src/main/java/com/termux/shared/terminal/TermuxTerminalSessionClientBase.java
  - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
  - app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java
---

# Plan 04-B: OSC9 Desktop Notifications

<objective>
Implement OSC9 escape sequence handling so that terminal commands can trigger Android notifications via `printf '\033]9;message\007'`. Notifications are rate-limited (max 1 per 3 seconds per session), grouped per session, and tapping a notification opens the app and switches to the originating session.
</objective>

<tasks>

<task id="04-B-01">
<title>Add onDesktopNotification to TerminalSessionClient interface</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/TerminalSessionClient.java
</read_first>
<action>
In `TerminalSessionClient.java`, add a new method declaration after the existing `onTerminalCursorStateChange(boolean state)` line (line 24):

```java
void onDesktopNotification(TerminalSession session, String body);
```
</action>
<acceptance_criteria>
- TerminalSessionClient.java contains `void onDesktopNotification(TerminalSession session, String body);`
</acceptance_criteria>
</task>

<task id="04-B-02">
<title>Add onDesktopNotification to TerminalOutput abstract class</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/TerminalOutput.java
</read_first>
<action>
In `TerminalOutput.java`, add a new abstract method after the existing `onColorsChanged()` method (line 30):

```java
/** Called when an OSC 9 desktop notification escape sequence is received. */
public abstract void onDesktopNotification(String body);
```
</action>
<acceptance_criteria>
- TerminalOutput.java contains `public abstract void onDesktopNotification(String body);`
</acceptance_criteria>
</task>

<task id="04-B-03">
<title>Implement onDesktopNotification in TerminalSession</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/TerminalSession.java
</read_first>
<action>
In `TerminalSession.java`, add the implementation of `onDesktopNotification` after the existing `onBell()` method (around line 284):

```java
@Override
public void onDesktopNotification(String body) {
    mClient.onDesktopNotification(this, body);
}
```

This follows the exact same pattern as `onBell()` (line 282-284) and `onCopyTextToClipboard()` (line 272-274) — delegate to `mClient` with `this` as the session reference.
</action>
<acceptance_criteria>
- TerminalSession.java contains `public void onDesktopNotification(String body)`
- TerminalSession.java contains `mClient.onDesktopNotification(this, body);`
</acceptance_criteria>
</task>

<task id="04-B-04">
<title>Add case 9 to doOscSetTextParameters in TerminalEmulator</title>
<read_first>
- terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
</read_first>
<action>
In `TerminalEmulator.java`, in the `doOscSetTextParameters` method, add a `case 9:` before the `case 10:` block (between line 1958 and line 1959):

```java
case 9: // OSC 9 — Desktop notification. Format: \033]9;body\007
    if (!textParameter.isEmpty()) {
        mSession.onDesktopNotification(textParameter);
    }
    break;
```
</action>
<acceptance_criteria>
- TerminalEmulator.java contains `case 9: // OSC 9`
- TerminalEmulator.java contains `mSession.onDesktopNotification(textParameter);`
</acceptance_criteria>
</task>

<task id="04-B-05">
<title>Add no-op onDesktopNotification to TermuxTerminalSessionClientBase</title>
<read_first>
- termux-shared/src/main/java/com/termux/shared/terminal/TermuxTerminalSessionClientBase.java
</read_first>
<action>
In `TermuxTerminalSessionClientBase.java`, add the default no-op implementation after the existing `onBell` method (around line 35):

```java
@Override
public void onDesktopNotification(TerminalSession session, String body) {
    // No-op in base implementation
}
```

Also add the import if not already present:
```java
import com.termux.terminal.TerminalSession;
```
(Check first — it's likely already imported since other methods reference `TerminalSession`.)
</action>
<acceptance_criteria>
- TermuxTerminalSessionClientBase.java contains `public void onDesktopNotification(TerminalSession session, String body)`
</acceptance_criteria>
</task>

<task id="04-B-06">
<title>Add notification channel and ID constants to TermuxConstants</title>
<read_first>
- termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
</read_first>
<action>
In `TermuxConstants.java`, after the existing `TERMUX_APP_NOTIFICATION_ID` constant (line 762), add:

```java
/** Notification channel for OSC 9 terminal desktop notifications. */
public static final String TERMUX_TERMINAL_NOTIFICATION_CHANNEL_ID = "terminal_desktop_notifications";
/** Display name for the terminal notification channel. */
public static final String TERMUX_TERMINAL_NOTIFICATION_CHANNEL_NAME = "Terminal Notifications";
/** Base notification ID for OSC 9 notifications. Each session adds its index to this base. */
public static final int TERMUX_TERMINAL_NOTIFICATION_ID_BASE = 2000;
```
</action>
<acceptance_criteria>
- TermuxConstants.java contains `TERMUX_TERMINAL_NOTIFICATION_CHANNEL_ID = "terminal_desktop_notifications"`
- TermuxConstants.java contains `TERMUX_TERMINAL_NOTIFICATION_CHANNEL_NAME = "Terminal Notifications"`
- TermuxConstants.java contains `TERMUX_TERMINAL_NOTIFICATION_ID_BASE = 2000`
</acceptance_criteria>
</task>

<task id="04-B-07">
<title>Implement onDesktopNotification with rate limiting in TermuxTerminalSessionClient</title>
<read_first>
- app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java
- app/src/main/java/com/termux/app/TermuxActivity.java
- termux-shared/src/main/java/com/termux/shared/notification/NotificationUtils.java
- termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
</read_first>
<action>
In `TermuxTerminalSessionClient.java`:

1. Add imports at the top:
   ```java
   import android.app.NotificationManager;
   import android.app.PendingIntent;
   import android.content.Intent;
   import java.util.concurrent.ConcurrentHashMap;
   import com.termux.shared.notification.NotificationUtils;
   import com.termux.shared.termux.TermuxConstants;
   ```
   (Only add imports not already present.)

2. Add instance variables after the existing `private static final String LOG_TAG` (line 44):
   ```java
   /** Rate limiting: last notification timestamp per session. */
   private final ConcurrentHashMap<TerminalSession, Long> mLastNotificationTime = new ConcurrentHashMap<>();
   private static final long NOTIFICATION_RATE_LIMIT_MS = 3000;
   private boolean mNotificationChannelCreated = false;
   ```

3. Add the `onDesktopNotification` implementation after the existing `onBell` method (around line 211):
   ```java
   @Override
   public void onDesktopNotification(TerminalSession session, String body) {
       if (body == null || body.isEmpty()) return;

       // Rate limiting: max 1 notification per 3 seconds per session
       long now = System.currentTimeMillis();
       Long lastTime = mLastNotificationTime.get(session);
       if (lastTime != null && (now - lastTime) < NOTIFICATION_RATE_LIMIT_MS) {
           return;
       }
       mLastNotificationTime.put(session, now);

       // Ensure notification channel exists (idempotent)
       if (!mNotificationChannelCreated) {
           NotificationUtils.setupNotificationChannel(
               mActivity,
               TermuxConstants.TERMUX_TERMINAL_NOTIFICATION_CHANNEL_ID,
               TermuxConstants.TERMUX_TERMINAL_NOTIFICATION_CHANNEL_NAME,
               NotificationManager.IMPORTANCE_DEFAULT
           );
           mNotificationChannelCreated = true;
       }

       // Determine session name and index
       String sessionName = session.mSessionName;
       if (sessionName == null || sessionName.isEmpty()) {
           sessionName = "Terminal";
       }

       // Build notification
       int sessionIndex = 0;
       if (mActivity.getTermuxService() != null) {
           java.util.List<com.termux.app.TermuxService.TermuxSession> sessions = mActivity.getTermuxService().getTermuxSessions();
           for (int i = 0; i < sessions.size(); i++) {
               if (sessions.get(i).getTerminalSession() == session) {
                   sessionIndex = i;
                   break;
               }
           }
       }

       int notificationId = TermuxConstants.TERMUX_TERMINAL_NOTIFICATION_ID_BASE + sessionIndex;

       // PendingIntent to open app
       Intent intent = TermuxActivity.newInstance(mActivity);
       intent.putExtra("session_index", sessionIndex);
       PendingIntent pendingIntent = PendingIntent.getActivity(
           mActivity, notificationId, intent,
           PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
       );

       android.app.Notification.Builder builder = new android.app.Notification.Builder(mActivity, TermuxConstants.TERMUX_TERMINAL_NOTIFICATION_CHANNEL_ID)
           .setSmallIcon(android.R.drawable.ic_dialog_info)
           .setContentTitle(sessionName)
           .setContentText(body)
           .setContentIntent(pendingIntent)
           .setAutoCancel(true)
           .setGroup("terminal_osc9_" + sessionIndex);

       NotificationManager manager = (NotificationManager) mActivity.getSystemService(android.content.Context.NOTIFICATION_SERVICE);
       if (manager != null) {
           manager.notify(notificationId, builder.build());
       }
   }
   ```

4. Also add cleanup: when `removeFinishedSession` is called or in the activity's `onDestroy`, clean up the rate limiting map entries. Add in the existing `removeFinishedSession` method (if it exists) or add a helper:
   ```java
   // In removeFinishedSession or equivalent:
   mLastNotificationTime.remove(session);
   ```
</action>
<acceptance_criteria>
- TermuxTerminalSessionClient.java contains `public void onDesktopNotification(TerminalSession session, String body)`
- TermuxTerminalSessionClient.java contains `NOTIFICATION_RATE_LIMIT_MS = 3000`
- TermuxTerminalSessionClient.java contains `ConcurrentHashMap<TerminalSession, Long> mLastNotificationTime`
- TermuxTerminalSessionClient.java contains `TERMUX_TERMINAL_NOTIFICATION_CHANNEL_ID`
- TermuxTerminalSessionClient.java contains `setGroup("terminal_osc9_"`
- TermuxTerminalSessionClient.java contains `manager.notify(notificationId, builder.build())`
</acceptance_criteria>
</task>

</tasks>

<verification>
1. Build via GitHub Actions — `./gradlew assembleDebug` must succeed
2. Install APK and open a terminal session
3. Run `printf '\033]9;Build complete!\007'` — an Android notification should appear with title "Terminal" and body "Build complete!"
4. Tap the notification — the app should come to foreground
5. Rate limiting test: `for i in $(seq 1 10); do printf '\033]9;Spam $i\007'; done` — at most ~3-4 notifications should appear, not 10
6. Multi-session test: open a second session, send OSC9 from each — notifications should have different titles and group separately
7. Normal terminal usage (no OSC9 sequences) must show no notifications
</verification>

<must_haves>
- OSC 9 escape sequence `\033]9;body\007` triggers an Android notification
- Rate limiting of max 1 notification per 3 seconds per session
- Notification channel "Terminal Notifications" created for user control
- Tapping a notification opens the app
- The callback chain follows the established pattern: TerminalEmulator -> TerminalOutput -> TerminalSession -> TerminalSessionClient -> TermuxTerminalSessionClient
- No compilation errors from interface changes (all implementations updated)
</must_haves>
