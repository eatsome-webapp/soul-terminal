---
phase: 06-app-merge
plan: 02
subsystem: ui
tags: [flutter, riverpod, core, providers, router, theme, sentry, dart]

# Dependency graph
requires:
  - phase: 06-01
    provides: flutter_module pubspec.yaml met alle SOUL dependencies
provides:
  - flutter_module/lib/core/ directory structuur (6 source files)
  - providers.dart met 60+ Riverpod provider definities
  - app_router.dart met GoRouter configuratie
  - sentry_config.dart met PII filtering
  - soul_theme.dart met SOUL kleurenschema
  - constants.dart en utils/logger.dart
affects: [06-03, 06-04, 06-05, 06-06, 06-07]

# Tech tracking
tech-stack:
  added: []
  patterns: [relatieve imports voor core bestanden, geen package:soul_app/ imports]

key-files:
  created:
    - flutter_module/lib/core/di/providers.dart
    - flutter_module/lib/core/router/app_router.dart
    - flutter_module/lib/core/sentry_config.dart
    - flutter_module/lib/core/theme/soul_theme.dart
    - flutter_module/lib/core/constants.dart
    - flutter_module/lib/core/utils/logger.dart
    - flutter_module/assets/config/default_intervention_config.yaml
    - flutter_module/lib/objectbox-model.json
  modified: []

key-decisions:
  - "Core files gekopieerd zonder imports te wijzigen — alle imports waren al relatief of package:-namen zonder soul_app prefix"
  - "main.dart ongewijzigd gelaten — core files worden pas geïmporteerd na plan 03-05"
  - "assets/config/default_intervention_config.yaml gecommit want al in pubspec.yaml assets: sectie"
  - "objectbox-model.json gecommit conform ObjectBox aanbeveling (KEEP THIS FILE!)"

patterns-established:
  - "Kopieer alleen source files, nooit .g.dart of .freezed.dart"
  - "Relatieve imports in SOUL app zijn direct bruikbaar in flutter_module (identieke directory structuur)"

requirements-completed: ["MERG-01", "MERG-04"]

# Metrics
duration: 14min
completed: 2026-03-21
---

# Phase 06 Plan 02: Core layer + providers kopiëren Summary

**Core/ directory (6 source files + assets) gekopieerd naar flutter_module met correcte relatieve imports, CI Build groen**

## Performance

- **Duration:** 14 min
- **Started:** 2026-03-21T05:23:59Z
- **Completed:** 2026-03-21T05:38:01Z
- **Tasks:** 4
- **Files modified:** 8

## Accomplishments
- providers.dart (60+ Riverpod providers) gekopieerd naar flutter_module/lib/core/di/
- app_router.dart, sentry_config.dart, soul_theme.dart, constants.dart, utils/logger.dart gekopieerd
- Alle imports waren al correct (relatief, geen package:soul_app/ aanwezig)
- main.dart ongewijzigd — CI Build slaagt (BridgeTestScreen nog actief)

## Task Commits

Each task was committed atomically:

1. **Task 02.1: Kopieer core/ directory (6 source files)** - `b6bf2246` (feat)
2. **Task 02.2: Controleer en fix imports** - geen aparte commit nodig (geen wijzigingen vereist)
3. **Task 02.3: Kopieer soul_core inline** - geen actie (geen package:soul_core/ imports gevonden)
4. **Task 02.4: Stub main.dart / CI verificatie** - `dd2779b9` (chore — untracked assets gecommit)

**Plan metadata:** `[zie docs commit]` (docs: complete plan)

## Files Created/Modified
- `flutter_module/lib/core/di/providers.dart` — 60+ Riverpod providers (alle services en DAOs)
- `flutter_module/lib/core/router/app_router.dart` — GoRouter met StatefulShellRoute
- `flutter_module/lib/core/sentry_config.dart` — Sentry met PII filtering
- `flutter_module/lib/core/theme/soul_theme.dart` — SOUL kleurenschema
- `flutter_module/lib/core/constants.dart` — App constants
- `flutter_module/lib/core/utils/logger.dart` — Logger utility
- `flutter_module/assets/config/default_intervention_config.yaml` — Intervention config asset
- `flutter_module/lib/objectbox-model.json` — ObjectBox schema (VCS verplicht)

## Decisions Made
- Imports niet gewijzigd — SOUL app gebruikt al relatieve imports die direct werken in flutter_module (identieke directory structuur)
- soul_core overgeslagen — geen imports van `package:soul_core/` in de SOUL app
- objectbox-model.json en assets/config/ gecommit als source artifacts (niet generated output)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Untracked source files van vorige plan runs**
- **Found during:** Task 02.4 (CI verificatie)
- **Issue:** assets/config/default_intervention_config.yaml en objectbox-model.json stonden untracked — pubspec.yaml verwijst er al naar
- **Fix:** Beide bestanden gecommit als source artifacts
- **Files modified:** flutter_module/assets/config/default_intervention_config.yaml, flutter_module/lib/objectbox-model.json
- **Verification:** git status clean na commit
- **Committed in:** dd2779b9

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Geen scope creep — alleen vergeten source files gecommit.

## Issues Encountered
- Eerste CI build gefaald omdat commit `dd2779b9` nog `pigeon: ^22.7.0` had. Commit `805d3422` (van plan 06-01 fixrun) had pigeon al gerepareerd naar `^26.2.3`. Na pull was HEAD al op de correcte versie.
- CI Build run voor HEAD (`754807ed` → `4662ddd6`) was groen.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Core/ directory structuur klaar voor plan 06-04 (services/) en 06-05 (UI)
- providers.dart importeert services/models die pas bij plan 06-04/05 gekopieerd worden — dit is verwacht
- Plan 06-03 (database layer) al voltooid door eerdere sessie

---
*Phase: 06-app-merge*
*Completed: 2026-03-21*
