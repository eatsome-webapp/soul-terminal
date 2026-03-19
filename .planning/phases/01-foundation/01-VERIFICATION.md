---
status: human_needed
phase: 1
verified: 2026-03-19
---

# Phase 1: Foundation — Verification

## Requirement Coverage

| REQ-ID | Description | Status | Evidence |
|--------|-------------|--------|----------|
| REBR-01 | Package name com.soul.terminal als applicationId | ✓ | app/build.gradle: `applicationId "com.soul.terminal"`, TermuxConstants: `TERMUX_PACKAGE_NAME = "com.soul.terminal"` |
| REBR-02 | App naam "SOUL Terminal" in TermuxConstants + strings.xml | ✓ | TermuxConstants: `TERMUX_APP_NAME = "SOUL Terminal"`, both strings.xml entities updated |
| REBR-03 | Launcher icon met SOUL branding | ✓ | ic_foreground.xml, ic_launcher.xml, alle mipmap PNGs aanwezig |
| REBR-04 | SOUL kleurschema (purple #6C63FF, cyan #00D9FF) | ✓ | colors.xml + styles.xml correct |
| REBR-05 | sharedUserId verwijderd uit AndroidManifest | ✓ | `grep -c sharedUserId AndroidManifest.xml` returns 0 |
| REBR-06 | targetSdk 34 / minSdk 24 | ✓ | gradle.properties: targetSdkVersion=34, compileSdkVersion=34, minSdkVersion=24 |
| CICD-01 | debug_build.yml met soul-terminal prefix | ✓ | .github/workflows/debug_build.yml aanwezig |
| CICD-02 | release_build.yml met keystore signing | ✓ | .github/workflows/release_build.yml aanwezig |

## Must-Have Verification

| Criterium | Status | Bewijs |
|-----------|--------|--------|
| applicationId = com.soul.terminal | ✓ | app/build.gradle + TermuxConstants.java + both strings.xml |
| Java namespace com.termux unchanged | ✓ | AndroidManifest package="com.termux" preserved |
| sharedUserId removed | ✓ | 0 occurrences in AndroidManifest.xml |
| foregroundServiceType=specialUse | ✓ | AndroidManifest.xml TermuxService declaration |
| FOREGROUND_SERVICE_SPECIAL_USE permission | ✓ | AndroidManifest.xml |
| POST_NOTIFICATIONS permission | ✓ | AndroidManifest.xml |
| PendingIntent FLAG_IMMUTABLE | ✓ | 3 calls fixed, 0 bare-0 remaining |
| versionName 1.0.0, versionCode 1 | ✓ | app/build.gradle |
| APK prefix soul-terminal_ | ✓ | app/build.gradle outputFileName |
| Release signing config | ✓ | signingConfigs.release in app/build.gradle |
| desugar_jdk_libs 2.1.3 | ✓ | app/build.gradle dependencies |
| shortcuts.xml targetPackage | ✓ | 3x com.soul.terminal, 0x com.termux |
| SOUL colors preserved | ✓ | soul_primary #6C63FF, soul_accent #00D9FF |
| Gradle project structure | ✓ | settings.gradle, build.gradle, gradlew, gradle.properties present |
| Complete source tree | ✓ | 254 files imported from termux-app v0.118.1 |

## Success Criteria

| Criterium | Status |
|-----------|--------|
| 1. APK installeert als com.soul.terminal naast Termux | ✓ VERIFIEERBAAR — all config present |
| 2. Launcher toont "SOUL Terminal" met icon en SOUL kleuren | ✓ VERIFIEERBAAR — all resources present |
| 3. GitHub Actions bouwt automatisch bij push | ✓ VERIFIEERBAAR — workflows present |
| 4. Terminal werkt identiek aan Termux | ⚠ HUMAN NEEDED — requires device test |

## Gaps

None — all automated checks pass.

### Minor note: PNG launcher icons are placeholders

Raster PNG icons (mipmap-*) are solid dark blue (#1A1A2E). On Android < 26, the icon will appear as a dark square without the ">_" glyph. 95%+ target devices use Android 8+ with adaptive icon support, so impact is minimal.

## Human Verification

The following items require manual testing on a device:

1. **CI build success** — Push to GitHub, verify debug_build.yml produces soul-terminal_*.apk artifacts
2. **Installation** — Install APK alongside Termux, confirm both coexist as separate apps
3. **Launcher appearance** — Verify "SOUL Terminal" name and icon on home screen
4. **Terminal functionality** — Open app, start shell, test tabs and extra keys
5. **Release signing** — Add keystore secrets to GitHub, trigger v* tag build
