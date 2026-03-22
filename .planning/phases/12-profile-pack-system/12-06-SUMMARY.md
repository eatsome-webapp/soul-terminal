---
phase: 12-profile-pack-system
plan: "12-06"
subsystem: profile-pack
tags: [flutter, dart, background-service, settings-ui, profile-pack, update-checker]

# Dependency graph
requires:
  - phase: 12-02
    provides: ProfilePackService.fetchManifest, cacheManifest, readInstalledVersionFromFile, ProfileEntry.isNewer
  - phase: 12-04
    provides: installPack, downloadPack
provides:
  - Background profile update checker with daily/weekly/never frequency
  - profileUpdateAvailable flag stored in SettingsDao, readable by main isolate
  - Settings UI section with frequency dropdown and "Nu updaten" update banner
  - ProfilePackService.performUpdate() convenience method for full update flow
affects: [ui-settings, background-handler, phase-13]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Background isolate reads version markers via File I/O (no Pigeon) for isolate safety
    - Outer hourly guard + inner daily/weekly gate pattern for background rate-limiting
    - "Failed check does not update lastCheck timestamp — auto-retry next cycle"

key-files:
  created: []
  modified:
    - flutter_module/lib/services/database/daos/settings_dao.dart
    - flutter_module/lib/services/platform/soul_background_handler.dart
    - flutter_module/lib/ui/settings/background_service_settings.dart
    - flutter_module/lib/services/profile_pack/profile_pack_service.dart

key-decisions:
  - "Outer hourly check + inner daily/weekly gate: avoids reading settings every 15min while staying responsive"
  - "Only first found update is reported to avoid notification spam; subsequent updates picked up next cycle"
  - "performUpdate() returns String? (null=success) instead of throwing — cleaner for UI callers"

patterns-established:
  - "Background isolate update pattern: File I/O for version markers, SettingsDao for flags, sendDataToMain for notifications"

requirements-completed: [PROF-05, PROF-06, PROF-09, PROF-10]

# Metrics
duration: 2min
completed: 2026-03-22
---

# Phase 12 Plan 06: Background Update Checker & Update Flow Summary

**Background profile update checker with configurable daily/weekly/never schedule, SettingsDao flag storage, and settings UI with "Nu updaten" banner that triggers safe $PREFIX-only extraction**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-22T13:04:01Z
- **Completed:** 2026-03-22T13:06:05Z
- **Tasks:** 4
- **Files modified:** 4

## Accomplishments
- SettingsDao extended with 5 profile update keys (frequency, lastCheck, available, remoteVersion, profileId)
- SoulBackgroundHandler._checkProfileUpdates(): reads frequency pref, compares installed vs remote via File I/O, stores update flag, notifies main isolate
- BackgroundServiceSettings UI: frequency dropdown (Dagelijks/Wekelijks/Nooit) + conditional update banner with "Nu updaten" FilledButton
- ProfilePackService.performUpdate(): convenience wrapper returning null on success, error string on failure

## Task Commits

Each task was committed atomically:

1. **Task 1: Add profile update settings keys to SettingsDao** - `2d7056f8` (feat)
2. **Task 2: Add profile update check to SoulBackgroundHandler** - `11a3c7a7` (feat)
3. **Task 3: Add profile update section to BackgroundServiceSettings UI** - `fe4ffd24` (feat)
4. **Task 4: Add performUpdate method to ProfilePackService** - `5bf5856f` (feat)

**Plan metadata:** `[docs commit hash]` (docs: complete plan)

## Files Created/Modified
- `flutter_module/lib/services/database/daos/settings_dao.dart` - 5 new SettingsKeys constants for profile update tracking
- `flutter_module/lib/services/platform/soul_background_handler.dart` - _checkProfileUpdates() method + _lastProfileUpdateCheck field + onRepeatEvent hook
- `flutter_module/lib/ui/settings/background_service_settings.dart` - Profile Updates UI section with frequency dropdown and update banner
- `flutter_module/lib/services/profile_pack/profile_pack_service.dart` - performUpdate() convenience method

## Decisions Made
- Outer hourly rate-limit wraps inner daily/weekly check to avoid reading SettingsDao every 15 minutes while still being responsive when the window elapses
- Only the first installed profile with an update is reported per cycle to avoid multiple simultaneous notifications; subsequent updates are picked up next check
- performUpdate() returns `String?` (null = success, error message = failure) instead of throwing — cleaner interface for UI callers that show SnackBars

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 12 is now complete (all 6 plans executed)
- All PROF requirements delivered: manifest fetch/cache, install with SHA-256 verify, crash recovery, wizard integration with fallback, lazy install (CNF), background update checker
- Ready for phase summary / next milestone step

---
*Phase: 12-profile-pack-system*
*Completed: 2026-03-22*
