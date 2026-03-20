---
phase: 06-app-merge
plan: 05
subsystem: infra
tags: [github-actions, ci-cd, build_runner, flutter, dart-define, secrets]

# Dependency graph
requires:
  - phase: 06-app-merge
    provides: merged flutter_module with 239 Dart files, 52 deps, build_runner codegen required
provides:
  - CI/CD pipeline updated with build_runner codegen step
  - dart-define secrets (VOYAGE_API_KEY, SENTRY_DSN) passed to Flutter module
  - Working APK artifact produced by CI with all SOUL code embedded
affects: [07-bottom-sheet-layout, 08-session-management]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "EXTRA_DART_DEFINES env var (base64-encoded, comma-separated) for add-to-app dart-define passthrough"
    - "build_runner step after flutter pub get in all CI workflows"

key-files:
  created: []
  modified:
    - .github/workflows/debug_build.yml
    - .github/workflows/release_build.yml

key-decisions:
  - "EXTRA_DART_DEFINES via base64 encoding: add-to-app modules receive dart-defines via this env var, not --dart-define flag"
  - "Graceful fallback: build succeeds when VOYAGE_API_KEY/SENTRY_DSN secrets not configured (empty string fallback)"

patterns-established:
  - "build_runner always runs after flutter pub get in CI, before Gradle build"
  - "Secrets passed via GitHub secrets → env vars → EXTRA_DART_DEFINES (never hardcoded)"

requirements-completed: [MERG-08]

# Metrics
duration: 9min
completed: 2026-03-20
---

# Phase 6 Plan 05: CI/CD Pipeline Update & Final Build Validation Summary

**GitHub Actions CI updated met build_runner codegen en dart-define secrets; volledige APK build slaagt in 4m4s**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-20T22:43:10Z
- **Completed:** 2026-03-20T22:52:43Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments
- `debug_build.yml` en `release_build.yml` beide bijgewerkt met build_runner codegen stap
- VOYAGE_API_KEY en SENTRY_DSN secrets worden via EXTRA_DART_DEFINES doorgegeven aan Flutter module
- CI build volledig geslaagd: alle stappen groen, APK artifacts geproduceerd (universal + arm64-v8a)
- build_runner codegen (Freezed, Riverpod, Drift, ObjectBox) draait succesvol in CI

## Task Commits

Elke taak atomisch gecommit:

1. **Task 06-05-01: build_runner codegen aan debug_build.yml** - `ded27b8c` (chore)
2. **Task 06-05-02: dart-define secrets in debug_build.yml** - `682fc4cb` (chore)
3. **Task 06-05-03: release_build.yml updaten + CI trigger** - `bb85bddb` (chore)

**Plan metadata:** wordt gecommit in docs commit

## Files Created/Modified
- `.github/workflows/debug_build.yml` — build_runner stap + VOYAGE_API_KEY/SENTRY_DSN env vars + EXTRA_DART_DEFINES setup
- `.github/workflows/release_build.yml` — zelfde wijzigingen als debug workflow

## Decisions Made
- EXTRA_DART_DEFINES via base64-encoding: add-to-app Flutter modules ontvangen dart-defines niet via `--dart-define` CLI flag maar via deze env var die de Flutter toolchain leest
- Graceful fallback: indien secrets niet geconfigureerd in de repo, bouwt de APK alsnog (VOYAGE_API_KEY en SENTRY_DSN zijn empty strings, app handelt dit af)
- release_build.yml gebruikt dezelfde aanpak als debug_build.yml voor consistentie

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. CI build slaagde direct op eerste poging in 4m4s.

## User Setup Required

None - geen externe service configuratie vereist. Secrets (VOYAGE_API_KEY, SENTRY_DSN) zijn optioneel; build werkt zonder.

## Next Phase Readiness

Phase 06 (app-merge) volledig afgerond:
- 5/5 plannen uitgevoerd
- CI bouwt werkende APK met SOUL Flutter module embedded
- Klaar voor Phase 07: Bottom Sheet Layout (LAYT-01..06)

---
*Phase: 06-app-merge*
*Completed: 2026-03-20*

## Self-Check: PASSED

- `grep "build_runner" .github/workflows/debug_build.yml` → match aanwezig
- `grep "build_runner" .github/workflows/release_build.yml` → match aanwezig
- `grep "VOYAGE_API_KEY" .github/workflows/debug_build.yml` → match aanwezig
- `gh run view 23365631882` → status: success, alle stappen groen
- APK artifacts geüpload: universal + arm64-v8a
