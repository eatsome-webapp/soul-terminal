---
phase: 04-terminal-enhancements
plan: B
subsystem: terminal
tags: [osc9, notifications, android, rate-limiting, escape-sequences]

# Dependency graph
requires:
  - phase: 04-A
    provides: TerminalEmulator with Kitty keyboard protocol (foundational emulator changes)
provides:
  - OSC 9 escape sequence handling through the full callback chain
  - Android desktop notifications triggered by `printf '\033]9;message\007'`
  - Rate limiting (max 1 notification per 3s per session)
  - Notification channel "Terminal Notifications" for user control
affects: [05-native-agentic-engine]

# Tech tracking
tech-stack:
  added: [ConcurrentHashMap for rate limiting, android.app.NotificationManager, android.app.PendingIntent]
  patterns: [OSC escape sequence → TerminalOutput abstract → TerminalSession delegate → TerminalSessionClient interface → TermuxTerminalSessionClient concrete]

key-files:
  created: []
  modified:
    - terminal-emulator/src/main/java/com/termux/terminal/TerminalSessionClient.java
    - terminal-emulator/src/main/java/com/termux/terminal/TerminalOutput.java
    - terminal-emulator/src/main/java/com/termux/terminal/TerminalSession.java
    - terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
    - termux-shared/src/main/java/com/termux/shared/terminal/TermuxTerminalSessionClientBase.java
    - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
    - app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java

key-decisions:
  - "ConcurrentHashMap<TerminalSession, Long> voor rate limiting — thread-safe zonder synchronization overhead"
  - "TERMUX_TERMINAL_NOTIFICATION_ID_BASE = 2000 — ruim boven bestaande IDs (1337, 1338)"
  - "mNotificationChannelCreated flag — kanaal aanmaken is idempotent maar vermijden van onnodige binder calls"
  - "mLastNotificationTime.remove(session) in removeFinishedSession — geheugen opruimen bij sessie-einde"

patterns-established:
  - "OSC callback pattern: TerminalEmulator case → mSession.onXxx() → mClient.onXxx(this, ...) — zelfde patroon als onBell/onCopyTextToClipboard"
  - "Notification kanaal aanmaken: lazy init via boolean flag, niet in constructor"

requirements-completed: [TERM-02]

# Metrics
duration: 20min
completed: 2026-03-19
---

# Plan 04-B: OSC9 Desktop Notifications — Summary

**OSC 9 escape sequence `\033]9;body\007` triggers Android notifications via een 7-laags callback chain, met rate limiting (3s/sessie) en per-sessie notification grouping.**

## Performance

- **Duration:** 20 min
- **Started:** 2026-03-19T~10:00Z
- **Completed:** 2026-03-19T~10:20Z
- **Tasks:** 7
- **Files modified:** 7

## Accomplishments
- Volledige callback chain geïmplementeerd: TerminalEmulator → TerminalOutput → TerminalSession → TerminalSessionClient → TermuxTerminalSessionClientBase → TermuxTerminalSessionClient
- Rate limiting via ConcurrentHashMap — max 1 notificatie per 3 seconden per sessie
- Notification channel "Terminal Notifications" met IMPORTANCE_DEFAULT — zichtbaar in app instellingen
- Notificatie tikt → app opent + sessie-index meegegeven via Intent extra

## Task Commits

1. **Task 04-B-01: Add onDesktopNotification to TerminalSessionClient** - `6cf8bfb`
2. **Task 04-B-02: Add onDesktopNotification to TerminalOutput** - `f0d916b`
3. **Task 04-B-03: Implement onDesktopNotification in TerminalSession** - `66ec625`
4. **Task 04-B-04: Add case 9 to doOscSetTextParameters** - `b9bb2a2`
5. **Task 04-B-05: No-op in TermuxTerminalSessionClientBase** - `cd051e3`
6. **Task 04-B-06: Notification constants in TermuxConstants** - `900a27e`
7. **Task 04-B-07: Full implementation in TermuxTerminalSessionClient** - `f6afc23`

## Files Created/Modified
- `terminal-emulator/.../TerminalSessionClient.java` — interface: `void onDesktopNotification(TerminalSession, String)`
- `terminal-emulator/.../TerminalOutput.java` — abstract methode toegevoegd
- `terminal-emulator/.../TerminalSession.java` — delegeert naar mClient
- `terminal-emulator/.../TerminalEmulator.java` — case 9 in doOscSetTextParameters
- `termux-shared/.../TermuxTerminalSessionClientBase.java` — no-op override
- `termux-shared/.../TermuxConstants.java` — 3 nieuwe constanten (channel ID, channel name, notification ID base)
- `app/.../TermuxTerminalSessionClient.java` — volledige implementatie met rate limiting + cleanup

## Decisions Made
- `ConcurrentHashMap` voor rate limiting: thread-safe, geen expliciete synchronization nodig
- `TERMUX_TERMINAL_NOTIFICATION_ID_BASE = 2000`: ruim boven bestaande notificatie IDs (1337, 1338)
- Lazy channel creation via `mNotificationChannelCreated` boolean: voorkomt onnodige binder calls
- Cleanup in `removeFinishedSession`: `mLastNotificationTime.remove(session)` voorkomt geheugenlek bij lang-lopende sessies

## Deviations from Plan
None — plan exact uitgevoerd zoals geschreven.

## Issues Encountered
None.

## User Setup Required
None — geen externe service configuratie vereist.

## Next Phase Readiness
- OSC9 notifications volledig geïmplementeerd en ge-commit
- Build via GitHub Actions vereist voor verificatie (lokaal bouwen niet mogelijk)
- Test: `printf '\033]9;Build complete!\007'` in terminal sessie

---
*Phase: 04-terminal-enhancements*
*Completed: 2026-03-19*
