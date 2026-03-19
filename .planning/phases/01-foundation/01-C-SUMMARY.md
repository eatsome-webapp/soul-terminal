---
phase: 01-foundation
plan: C
subsystem: cicd
tags: [github-actions, ci, cd, gradle, signing, apk]
requires: [01-A, 01-B]
provides:
  - Debug build workflow (apt-android-7, soul-terminal_* prefix, universal + arm64-v8a)
  - Release build workflow (v* tag trigger, keystore signing via GitHub Secrets)
affects: [.github/workflows/debug_build.yml, .github/workflows/release_build.yml]
tech-stack:
  added: []
  patterns:
    - "APK prefix soul-terminal_* across both debug and release workflows"
    - "Keystore injected via base64 GitHub Secret — never stored in repo"
key-files:
  created:
    - .github/workflows/debug_build.yml
    - .github/workflows/release_build.yml
  modified: []
key-decisions:
  - "No existing debug_build.yml found — created from scratch matching all plan requirements"
  - "Release build produces universal APK only (splitAPKsForReleaseBuilds=0 is the Termux default)"
requirements-completed: [CICD-01, CICD-02]
duration: "8 min"
completed: "2026-03-19"
---

# Phase 1 Plan C: CI/CD Pipeline Summary

Debug and release GitHub Actions workflows created for SOUL Terminal, producing `soul-terminal_*` APKs via apt-android-7 variant only.

**Duration:** 8 min | **Tasks:** 2 | **Files:** 2 created

## Tasks Completed

| # | Title | Commit |
|---|-------|--------|
| 1 | Create debug_build.yml for SOUL Terminal | aa76eaf |
| 2 | Create release_build.yml workflow | e52d527 |

## What Was Built

- **debug_build.yml**: Triggers on push/PR to master and `workflow_dispatch`. Builds `apt-android-7` variant only. APK prefix `soul-terminal_$APK_VERSION_TAG`. Produces and uploads `universal` + `arm64-v8a` APKs plus sha256sums. Uses `actions/checkout@v4`, `actions/setup-java@v5` (Java 17), `actions/upload-artifact@v4`.

- **release_build.yml**: Triggers on `v*` tags and `workflow_dispatch`. Decodes keystore from `KEYSTORE_BASE64` secret. Builds `assembleRelease` with `STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` from secrets. Produces universal APK only (release builds have ABI splits disabled). APK prefix `soul-terminal_$RELEASE_VERSION_NAME-apt-android-7-release`.

## Deviations from Plan

**[Rule 3 - Blocking] debug_build.yml did not exist** — The plan's task 1 said "Rewrite `.github/workflows/debug_build.yml`", implying a pre-existing file. No workflows directory existed at all in the repo. Fix: Created the file from scratch matching all plan requirements and acceptance criteria. All acceptance criteria pass.

**Total deviations:** 1 auto-fixed. No scope change.

## Issues Encountered

None. All acceptance criteria verified before each commit.

## Next Phase Readiness

Phase 1 complete. All 3 plans done (A: Rebranding, B: Icons/Theme, C: CI/CD).

To use release builds:
1. Add `release.jks` keystore encoded as base64 to GitHub Secret `KEYSTORE_BASE64`
2. Add `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS` GitHub Secrets
3. Push a `v*` tag or trigger `workflow_dispatch` on release_build.yml
