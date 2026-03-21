---
phase: 06-app-merge
plan: 01
subsystem: infra
tags: [flutter, pubspec, dependencies, drift, riverpod, objectbox, pigeon]

# Dependency graph
requires: []
provides:
  - flutter_module/pubspec.yaml with all 41 SOUL runtime dependencies merged
  - flutter_module/pubspec.lock resolved for 156 packages
  - assets/config/default_intervention_config.yaml copied to flutter_module
affects: [06-app-merge]

# Tech tracking
tech-stack:
  added: [flutter_riverpod, anthropic_sdk_dart, drift, mcp_dart, objectbox, sentry_flutter, xterm, and 35 more]
  patterns: [add-to-app dependency alignment between soul-app and flutter_module]

key-files:
  created:
    - flutter_module/assets/config/default_intervention_config.yaml
  modified:
    - flutter_module/pubspec.yaml
    - flutter_module/pubspec.lock
    - flutter_module/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
    - flutter_module/ios/Runner/GeneratedPluginRegistrant.m
    - flutter_module/.flutter-plugins-dependencies

key-decisions:
  - "Upgraded pigeon ^22.7.0 -> ^26.2.3 to resolve analyzer version conflict with drift_dev ^2.31.0"

patterns-established:
  - "Pigeon version must be ^26.x for compatibility with drift_dev ^2.31.0 (analyzer constraint)"

requirements-completed: ["MERG-02"]

# Metrics
duration: 6min
completed: 2026-03-21
---

# Phase 6 Plan 01: Pubspec.yaml merge — alle dependencies toevoegen Summary

**Alle 41 SOUL runtime + 9 dev dependencies toegevoegd aan flutter_module/pubspec.yaml, pigeon upgraded naar ^26.2.3 om analyzer-conflict met drift_dev op te lossen, flutter pub get slaagt met 156 resolved packages**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-21T05:23:59Z
- **Completed:** 2026-03-21T05:30:20Z
- **Tasks:** 3
- **Files modified:** 6

## Accomplishments
- flutter_module/pubspec.yaml bevat nu alle SOUL dependencies + pigeon
- SDK constraint bijgewerkt naar ^3.11.1
- assets/config/default_intervention_config.yaml gekopieerd naar flutter_module
- `flutter pub get` succeeds lokaal (exit 0, 156 dependencies resolved)
- module: sectie ongewijzigd behouden

## Task Commits

Elke taak atomisch gecommit:

1. **Task 01.1 + 01.2: Merge runtime + dev dependencies** - `843531c1` (feat)
2. **Task 01.3: Asset kopiëren en pub get validatie** - `805d3422` (feat)

## Files Created/Modified
- `flutter_module/pubspec.yaml` - 41 runtime deps + 9 dev deps + SDK constraint + assets sectie
- `flutter_module/pubspec.lock` - 156 resolved packages
- `flutter_module/assets/config/default_intervention_config.yaml` - Gekopieerd van soul-app
- `flutter_module/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` - Gegenereerd door pub get
- `flutter_module/ios/Runner/GeneratedPluginRegistrant.m` - Gegenereerd door pub get
- `flutter_module/.flutter-plugins-dependencies` - Gegenereerd door pub get

## Decisions Made
- Pigeon ge-upgraded van ^22.7.0 naar ^26.2.3 omdat drift_dev ^2.31.0 `analyzer >=8.1.0` vereist en pigeon <26.x max `analyzer <8.0.0` ondersteunt

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Pigeon versie conflict met drift_dev**
- **Found during:** Task 01.3 (flutter pub get)
- **Issue:** `pigeon ^22.7.0` vereist `analyzer <8.0.0`, maar `drift_dev ^2.31.0` vereist `analyzer >=8.1.0` — version solving failed
- **Fix:** Pigeon upgraded naar `^26.2.3` zoals gesuggereerd door pub solver
- **Files modified:** flutter_module/pubspec.yaml
- **Verification:** flutter pub get exit 0, 156 dependencies resolved
- **Committed in:** 805d3422

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Noodzakelijke fix. Pigeon 26.x is backward compatible. Geen scope creep.

## Issues Encountered
None - na pigeon versie fix alles soepel verlopen.

## User Setup Required
None - geen externe services vereist.

## Next Phase Readiness
- Pubspec merge volledig, flutter pub get slaagt lokaal
- CI validatie volgt na push (plan 06-01 vereist CI groen voor "Flutter pub get" stap)
- Klaar voor 06-02 (core/ directory structuur merge)

---
*Phase: 06-app-merge*
*Completed: 2026-03-21*
