---
phase: 12-profile-pack-system
plan: "12-01"
subsystem: infra
tags: [github-actions, docker, qemu, aarch64, profile-packs, dart, flutter]

requires:
  - phase: 10-onboarding-flow
    provides: ProfilePackInstaller.java with SYMLINKS.txt zip format
provides:
  - GitHub Actions workflow to build profile packs via QEMU aarch64 + Docker
  - profile-packs/build-profile-pack.sh for delta extraction + SHA-256
  - manifest.json schemaVersion 2 with maintainer/repository community fields
  - ProfileManifest Dart model parsing manifestUrl, maintainer, repository
affects:
  - 12-profile-pack-system (remaining plans)
  - flutter onboarding profile selection

tech-stack:
  added: [docker/setup-qemu-action@v3, softprops/action-gh-release@v2]
  patterns: [delta-based profile pack build (snapshot before/after install), metadata.json sidecar for workflow outputs]

key-files:
  created:
    - profile-packs/build-profile-pack.sh
    - .github/workflows/profile_pack_build.yml
  modified:
    - profile-packs/manifest.json
    - flutter_module/lib/services/profile_pack/profile_manifest.dart

key-decisions:
  - "Replaced existing profile_pack_build.yml stub with full QEMU aarch64 implementation — existing file lacked required qemu, softprops/action-gh-release, auto-manifest-commit"
  - "Delta approach: snapshot base $PREFIX via timestamp marker, capture only new/modified files after apt-get install"
  - "metadata.json sidecar written by build script, read by workflow steps via jq — avoids shell output parsing fragility"
  - "manifestUrl added to ProfileManifest as top-level field for future remote manifest fetching"
  - "maintainer + repository fields use optional defaults ('') — backward compatible with v1 manifests"

patterns-established:
  - "Profile pack build: timestamp marker → install packages → delta capture → zip with SYMLINKS.txt → metadata.json"
  - "Workflow reads build outputs from metadata.json sidecar file, not stdout parsing"

requirements-completed: [PROF-01, PROF-08]

duration: 2min
completed: 2026-03-22
---

# Phase 12 Plan 01: GitHub Actions Profile Pack Build Workflow Summary

**GitHub Actions workflow + build script for aarch64 profile packs via QEMU Docker, with SHA-256 checksums, GitHub Release publishing, and auto-commit of manifest.json**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-22T12:51:51Z
- **Completed:** 2026-03-22T12:54:17Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- Created `build-profile-pack.sh` — builds a delta profile pack zip (SYMLINKS.txt + new files) matching ProfilePackInstaller.java expectations
- Created `profile_pack_build.yml` — full GitHub Actions workflow with QEMU aarch64 emulation, GitHub Release creation, and auto-commit of manifest.json
- Upgraded manifest.json to schemaVersion 2 with `manifestUrl`, `maintainer`, and `repository` fields for community-contributed profiles
- Updated `ProfileManifest` and `ProfileEntry` Dart models to parse the three new fields with backward-compatible defaults

## Task Commits

1. **Task 1: Create profile pack build script** — `bc31275d` (feat)
2. **Task 2: Create GitHub Actions workflow** — `8319bdf1` (feat)
3. **Task 3: Upgrade manifest schemaVersion 2 + Dart model** — `4d2e0686` (feat)

## Files Created/Modified

- `profile-packs/build-profile-pack.sh` — Delta-based build script: timestamp snapshot, apt-get install, delta extraction, SYMLINKS.txt generation, zip creation, SHA-256, metadata.json output
- `.github/workflows/profile_pack_build.yml` — GitHub Actions workflow: QEMU setup, bootstrap download, Docker build, GitHub Release, manifest auto-commit
- `profile-packs/manifest.json` — Upgraded to schemaVersion 2; added manifestUrl, maintainer, repository fields
- `flutter_module/lib/services/profile_pack/profile_manifest.dart` — Added manifestUrl to ProfileManifest; added maintainer/repository to ProfileEntry with optional defaults

## Decisions Made

- Replaced existing `profile_pack_build.yml` stub — it existed but lacked QEMU, `softprops/action-gh-release@v2`, and manifest auto-commit required by the plan
- Delta approach via timestamp marker is simpler and more reliable than comm-based file comparison in the existing stub
- metadata.json sidecar avoids brittle stdout parsing between Docker container and outer workflow steps

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Existing profile_pack_build.yml was a stub missing required features**
- **Found during:** Task 2 (Create GitHub Actions workflow)
- **Issue:** File already existed with a different approach (no QEMU, no `setup-qemu-action`, no `softprops/action-gh-release@v2`, no manifest auto-commit)
- **Fix:** Replaced entirely with plan specification
- **Files modified:** `.github/workflows/profile_pack_build.yml`
- **Verification:** All 7 acceptance criteria pass
- **Committed in:** `8319bdf1` (Task 2 commit)

**2. [Rule 1 - Bug] ProfileManifest.dart had additional compareVersions method not in initial read**
- **Found during:** Task 3 (Dart model update)
- **Issue:** File had `compareVersions` and `isNewer` static methods beyond the initial 61-line read — file was modified after read attempt failed
- **Fix:** Used Edit tool with targeted replacements to add new fields while preserving existing methods
- **Files modified:** `flutter_module/lib/services/profile_pack/profile_manifest.dart`
- **Verification:** All 7 acceptance criteria pass, compareVersions preserved
- **Committed in:** `4d2e0686` (Task 3 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both necessary for correct implementation. No scope creep.

## Issues Encountered

None — all acceptance criteria met for all 3 tasks.

## User Setup Required

None — no external service configuration required. Workflow uses `GITHUB_TOKEN` which is automatically available in GitHub Actions.

## Next Phase Readiness

- Profile pack build infrastructure is complete — workflow can be triggered manually via GitHub Actions UI
- manifest.json has schemaVersion 2 schema ready for when real builds populate url/sha256/sizeBytes
- Ready for plan 12-02 (profile pack installation flow in Flutter onboarding)

---
*Phase: 12-profile-pack-system*
*Completed: 2026-03-22*
