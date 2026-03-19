---
phase: 01-foundation
plan: 01-E
subsystem: infra
tags: [android, rebranding, soul-terminal, gradle, manifest]

requires:
  - phase: 01-D
    provides: Complete Termux source tree to apply rebranding to
provides:
  - Fully rebranded SOUL Terminal with com.soul.terminal applicationId
  - targetSdk 34 / compileSdk 34 compliance (foregroundServiceType, PendingIntent flags, permissions)
  - Release signing config for CI/CD pipeline
affects: [02-build-verification]

tech-stack:
  added: [desugar_jdk_libs-2.1.3]
  patterns: [manifestPlaceholders-for-package-name]

key-files:
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
  - "Java namespace com.termux preserved — only applicationId changes to com.soul.terminal"
  - "foregroundServiceType=specialUse for terminal emulator service on API 34+"
  - "desugar_jdk_libs 2.1.3 added (was missing from upstream v0.118.1)"
  - "compileSdkVersion raised to 34 alongside targetSdkVersion"

patterns-established:
  - "Package rebranding via manifestPlaceholders + TermuxConstants + XML entities — Java package unchanged"

requirements-completed: [REBR-01, REBR-02, REBR-05, REBR-06]

duration: 8min
completed: 2026-03-19
---

# Plan 01-E: Apply SOUL Rebranding Summary

**Rebranded Termux to SOUL Terminal — com.soul.terminal applicationId, targetSdk 34, PendingIntent flags, release signing**

## Performance

- **Duration:** 8 min
- **Completed:** 2026-03-19
- **Tasks:** 9 (8 with commits, 1 verify-only)
- **Files modified:** 8

## Accomplishments
- applicationId changed to com.soul.terminal throughout (TermuxConstants, build.gradle, strings.xml, shortcuts.xml)
- sharedUserId removed from AndroidManifest
- targetSdk/compileSdk raised to 34 with required permissions (FOREGROUND_SERVICE_SPECIAL_USE, POST_NOTIFICATIONS)
- All 3 PendingIntent calls fixed with FLAG_IMMUTABLE
- Release signing config added for CI/CD
- APK output filenames use soul-terminal_ prefix
- Version reset to 1.0.0 (versionCode 1)

## Task Commits

1. **T1: TermuxConstants** - `3035afc` (feat)
2. **T2: build.gradle** - `5ed0cc0` (feat)
3. **T3: gradle.properties** - `79d5c74` (feat)
4. **T4: app strings.xml** - `960c682` (feat)
5. **T5: termux-shared strings.xml** - `e998467` (feat)
6. **T6: shortcuts.xml** - `b29ac6e` (feat)
7. **T7: AndroidManifest** - `917f713` (feat)
8. **T8: PendingIntent flags** - `0b84e1f` (feat)
9. **T9: SOUL colors verify** - no commit needed (already correct)

## Decisions Made
- Java namespace com.termux preserved in AndroidManifest package attribute and all class references
- compileSdkVersion also raised to 34 (was 30) to match targetSdkVersion
- desugar_jdk_libs added as new dependency (wasn't in upstream)

## Deviations from Plan
- Upstream build.gradle uses `package="com.termux"` in AndroidManifest instead of `namespace` in build.gradle — this is the older Gradle DSL style, functionally identical
- versionCode was 1000 not 118 as Plan A assumed

## Issues Encountered
None.

## Next Phase Readiness
- All rebranding complete — ready for CI build verification
- Push to GitHub and run debug_build.yml to verify compilation

---
*Phase: 01-foundation*
*Completed: 2026-03-19*
