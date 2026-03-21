---
phase: 08-session-management
plan: "02"
subsystem: ui
tags: [android, java, session-management, popup-menu, drawer]

requires:
  - phase: 08-session-management plan 01
    provides: TabLayout tab bar met session_tab_layout en updateSessionTabs()

provides:
  - Long-press context menu op sessie-tabs (Hernoemen / Sluiten)
  - Sessie hernoemen via AlertDialog + EditText
  - Sessie sluiten via finishIfRunning() met guard voor laatste sessie
  - Drawer opgeschoond: alleen settings, keyboard toggle en SOUL toggle resten
  - Settings knop in tab bar area voor directe toegang

affects: [08-03-session-management, 09-soul-terminal-awareness]

tech-stack:
  added: []
  patterns:
    - "Tab long-click via ((ViewGroup) tabStrip.getChildAt(0)).getChildAt(i)"
    - "Session close via finishIfRunning() — laat onSessionFinished callback de cleanup doen"
    - "Null-safe guards voor verwijderde UI elementen (geen crash bij herontwikkeling)"

key-files:
  created: []
  modified:
    - app/src/main/java/com/termux/app/TermuxActivity.java
    - app/src/main/res/layout/activity_termux.xml
    - app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java

key-decisions:
  - "showRenameSessionDialog() schrijft direct naar terminalSession.mSessionName (zelfde patroon als bestaande renameSession() in client)"
  - "checkAndScrollToSession() volledig gestript — ListView weg, tab bar doet selectie al in setCurrentSession()"
  - "setTermuxSessionsListView() en setNewSessionButtonView() null-safe gemaakt ipv verwijderd — backward compat"

requirements-completed: [SESS-04]

duration: 15min
completed: 2026-03-21
---

# Phase 08 Plan 02: Session actions (rename, close) and drawer cleanup Summary

**Long-press context menu op tab bar tabs met Hernoemen/Sluiten, drawer gestript van session list en new session button, settings knop toegevoegd aan tab bar**

## Performance

- **Duration:** 15 min
- **Started:** 2026-03-21T10:31:31Z
- **Completed:** 2026-03-21T10:47:13Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Long-press op sessie-tab toont PopupMenu met "Hernoemen" en "Sluiten" opties
- Hernoemen opent AlertDialog met EditText, pre-gevuld met huidige naam
- Sluiten roept `finishIfRunning()` aan — existerende `onSessionFinished` callback handelt removal af
- Laatste sessie kan niet worden gesloten (toast feedback)
- Drawer heeft nu alleen settings button, keyboard toggle en SOUL toggle
- Settings knop direct beschikbaar in tab bar (drawer is immers gelocked)

## Task Commits

1. **Task 1: Add long-press context menu on tabs** - `8a9831c7` (feat)
2. **Task 2: Clean up drawer: remove session list and new session button** - `ceae629b` (feat)
3. **Task 3: Add settings overflow button to tab bar area** - `de7f5f92` (feat)

## Files Created/Modified
- `app/src/main/java/com/termux/app/TermuxActivity.java` — showSessionContextMenu, showRenameSessionDialog, closeSessionAtIndex, long-click listeners op tab views, settings_tab_button wiring, null-safe guards
- `app/src/main/res/layout/activity_termux.xml` — terminal_sessions_list en new_session_button verwijderd, settings_tab_button toegevoegd
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` — checkAndScrollToSession gestript, ListView import verwijderd

## Decisions Made
- `showRenameSessionDialog()` schrijft direct naar `terminalSession.mSessionName` en roept `termuxSessionListNotifyUpdated()` aan (update tab labels). Geen aparte renameSession() call in de client nodig.
- `checkAndScrollToSession()` volledig gestript: de ListView was al null-safe maar de code was dode code na plan 01. Tab bar doet selectie al via `setCurrentSession()`.
- `setTermuxSessionsListView()` en `setNewSessionButtonView()` null-safe bewaard (niet verwijderd) — defensief, maakt toekomstige refactoring makkelijker.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- SESS-04 compleet: rename en close acties via long-press op tabs
- Drawer is opgeschoond, settings toegankelijk via tab bar
- Klaar voor Plan 08-03

---
*Phase: 08-session-management*
*Completed: 2026-03-21*
