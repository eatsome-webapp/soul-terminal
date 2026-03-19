---
phase: 01-foundation
plan: A
subsystem: infra
tags: [android, gradle, java, rebranding, sdk-migration, pendingintent]

# Dependency graph
requires: []
provides:
  - Correct package name com.soul.terminal in all build artifacts
  - App name "SOUL Terminal" in all resource and code constants
  - targetSdk 34 / minSdk 24 compliance
  - PendingIntent FLAG_IMMUTABLE fixes for API 31+
  - foregroundServiceType=specialUse for Android 14 foreground service rules
  - Release signing config in build.gradle

affects: [02-bootstrap, 03-flutter-integration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "All branding constants flow from TermuxConstants.java as single source of truth"
    - "manifestPlaceholders in build.gradle drive AndroidManifest package references"

key-files:
  created: []
  modified:
    - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
    - app/build.gradle
    - gradle.properties
    - app/src/main/res/values/strings.xml
    - termux-shared/src/main/res/values/strings.xml
    - app/src/main/res/xml/shortcuts.xml
    - app/src/main/AndroidManifest.xml
    - app/src/main/java/com/termux/app/TermuxService.java

key-decisions:
  - "Java namespace com.termux preserved in all build.gradle files — only applicationId changes to com.soul.terminal"
  - "sharedUserId removed completely — SOUL Terminal does not need plugin compatibility with Termux"
  - "foregroundServiceType=specialUse chosen — terminal emulator fits this category without a more specific type"
  - "desugar_jdk_libs bumped to 2.1.3 to match targetSdk 34 requirements"

patterns-established:
  - "Task 10 (termux-shared PendingIntent): already used FLAG_UPDATE_CURRENT, no changes needed — verified before editing"

requirements-completed: [REBR-01, REBR-02, REBR-05, REBR-06]

# Metrics
duration: 25 min
completed: 2026-03-19
---

# Phase 1 Plan A: Rebranding & SDK Migration Summary

**Termux fork rebranded to SOUL Terminal (com.soul.terminal, version 1.0.0) with targetSdk 34, foregroundServiceType, and FLAG_IMMUTABLE PendingIntent fixes across app module**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-03-19T04:50:00Z
- **Completed:** 2026-03-19T05:10:00Z
- **Tasks:** 10 (9 with code changes, 1 pre-verified)
- **Files modified:** 8

## Accomplishments
- Package name changed to `com.soul.terminal` across all resource files, constants, and build config
- App name "SOUL Terminal" propagated to TermuxConstants, manifestPlaceholders, and all strings.xml entities
- SDK raised to minSdk 24 / targetSdk 34 with desugar_jdk_libs 2.1.3
- sharedUserId removed from AndroidManifest — clean install, no plugin shared UID dependency
- foregroundServiceType="specialUse" added to TermuxService with FOREGROUND_SERVICE_SPECIAL_USE and POST_NOTIFICATIONS permissions
- All 3 PendingIntent calls in TermuxService.java updated from flag `0` to `FLAG_IMMUTABLE`
- Release signing config skeleton added to build.gradle (env-var driven)
- APK output files renamed from `termux-app_*` to `soul-terminal_*`
- Version set to 1.0.0 (code 1)

## Task Commits

Each task committed atomically:

1. **Task 1: TermuxConstants.java** - `919429e` (rebrand)
2. **Task 2: app/build.gradle** - `908f371` (rebrand)
3. **Task 3: gradle.properties** - `d94660c` (sdk)
4. **Task 4: app strings.xml** - `6b96f14` (rebrand)
5. **Task 5: termux-shared strings.xml** - `6af0de2` (rebrand)
6. **Task 6: shortcuts.xml** - `12e3fbd` (rebrand)
7. **Tasks 7+8: AndroidManifest** - `b866f09` (fix — both applied in single file, committed together)
8. **Task 9: TermuxService.java** - `a8d5fe3` (fix)
9. **Task 10: termux-shared PendingIntent** - no commit needed (already compliant)

## Files Created/Modified
- `termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java` — TERMUX_APP_NAME, TERMUX_PACKAGE_NAME
- `app/build.gradle` — applicationId, version, APK names, signing config, desugar version
- `gradle.properties` — minSdkVersion=24, targetSdkVersion=34
- `app/src/main/res/values/strings.xml` — TERMUX_PACKAGE_NAME, TERMUX_APP_NAME entities
- `termux-shared/src/main/res/values/strings.xml` — entities + TERMUX_PREFIX_DIR_PATH
- `app/src/main/res/xml/shortcuts.xml` — all 3 targetPackage attributes
- `app/src/main/AndroidManifest.xml` — sharedUserId removed, permissions added, foregroundServiceType
- `app/src/main/java/com/termux/app/TermuxService.java` — 3x PendingIntent FLAG_IMMUTABLE

## Decisions Made
- Java namespace `com.termux` kept unchanged in all build.gradle `namespace` fields — changing this would break Java imports across the entire codebase with no benefit
- `sharedUserId` removed — SOUL Terminal is a standalone app, not part of a Termux plugin ecosystem
- `foregroundServiceType="specialUse"` — appropriate category for a terminal emulator on Android 14+
- Tasks 7 and 8 both modified AndroidManifest.xml; changes were applied together and committed in one atomic commit (T7 hash covers both)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 10 — termux-shared already compliant**
- **Found during:** Task 10 (Fix PendingIntent in termux-shared)
- **Issue:** Plan specified replacing flag `0` in 5 termux-shared files. Pre-check showed all files already used `FLAG_UPDATE_CURRENT`, not `0`.
- **Fix:** Verified with grep before editing. No changes made. No commit needed.
- **Files modified:** none
- **Verification:** `grep -rn 'PendingIntent.get.*,\s*0)' termux-shared/` returned 0 results
- **Committed in:** N/A

---

**Total deviations:** 1 auto-verified (pre-existing compliance)
**Impact on plan:** No scope change. termux-shared was already partially compliant; task 9 still required for the app module.

## Issues Encountered
None

## Next Phase Readiness
- Plan A complete — branding and SDK foundation in place
- Plan B (CI/CD) and Plan C (GitHub Actions workflow) can proceed
- `release.jks` keystore must be provisioned before release builds work — this is CI/CD setup territory (Plan B/C)
- No blockers for next plan

---
*Phase: 01-foundation*
*Completed: 2026-03-19*
