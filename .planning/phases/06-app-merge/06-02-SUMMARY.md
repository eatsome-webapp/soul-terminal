---
phase: 06-app-merge
plan: 02
subsystem: infra
tags: [android, manifest, permissions, foreground-service, notification-listener]

requires:
  - phase: 06-app-merge
    provides: plan 01 base context (gradle deps, build config)
provides:
  - READ_CONTACTS and READ_CALENDAR permissions in soul-terminal manifest
  - ForegroundService declaration for flutter_foreground_task plugin
  - NotificationListenerService declaration for notification_listener_service plugin
affects: [07-bottom-sheet, 09-soul-terminal-awareness]

tech-stack:
  added: []
  patterns: []

key-files:
  created: []
  modified:
    - app/src/main/AndroidManifest.xml

key-decisions:
  - "Inserted permissions after SET_ALARM (line 39) — keeps existing permission block intact"
  - "Inserted service declarations after RunCommandService closing tag — coexists safely with Termux services via different class names and FGS subtypes"

patterns-established: []

requirements-completed: [MERG-03]

duration: 1min
completed: 2026-03-20
---

# Phase 06 Plan 02: AndroidManifest Merge Summary

**SOUL permissions (READ_CONTACTS, READ_CALENDAR) and service declarations (ForegroundService, NotificationListenerService) merged into soul-terminal AndroidManifest.xml without disturbing existing Termux entries.**

## Performance

- **Duration:** 1 min
- **Started:** 2026-03-20T22:22:02Z
- **Completed:** 2026-03-20T22:23:02Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- READ_CONTACTS en READ_CALENDAR permissions toegevoegd
- ForegroundService voor flutter_foreground_task plugin gedeclareerd (specialUse, AI assistant subtype)
- NotificationListenerService voor notification_listener_service plugin gedeclareerd
- Bestaande TermuxService, RunCommandService, SystemEventReceiver ongewijzigd

## Task Commits

Each task was committed atomically:

1. **Task 1: Add SOUL permissions** - `e92ba720` (feat)
2. **Task 2: Add SOUL service declarations** - `c050916e` (feat)

## Files Created/Modified
- `app/src/main/AndroidManifest.xml` — 2 permissions + 2 service declarations toegevoegd (23 regels netto)

## Decisions Made
- Permissions ingevoegd na SET_ALARM (laatste bestaande permission), voor `<application>` tag — consistent met bestaande volgorde
- Services ingevoegd na RunCommandService, voor Samsung DeX meta-data — logisch einde van de service-sectie
- Coexistentie gewaarborgd: andere Java classnamen, andere FGS subtypes, andere notification channels

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- AndroidManifest ondersteunt nu alle SOUL features naast bestaande Termux services
- Klaar voor plan 03 (volgende app-merge stap)

---
*Phase: 06-app-merge*
*Completed: 2026-03-20*
