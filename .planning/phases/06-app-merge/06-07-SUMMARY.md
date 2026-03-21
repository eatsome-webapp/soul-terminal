---
phase: 06-app-merge
plan: 07
subsystem: infra
tags: [ci-cd, github-actions, build_runner, dart-defines, proguard, flutter]

requires:
  - phase: 06-06
    provides: main.dart met SOUL init-flow en SoulBridgeApi, AndroidManifest permissions

provides:
  - build_runner codegen stap in debug en release CI workflows
  - dart-defines voor VOYAGE_API_KEY en SENTRY_DSN via EXTRA_DART_DEFINES
  - Fix voor NDK build dependency volgorde (bootstrap download voor NDK)
  - ProGuard rules voor Flutter ReLinker
  - Werkende debug CI build (GROEN, APK met versie+commit hash)

affects: [fase-07, fase-08, alle toekomstige CI builds]

tech-stack:
  added: []
  patterns: [EXTRA_DART_DEFINES voor flutter dart-defines in add-to-app context]

key-files:
  created: []
  modified:
    - .github/workflows/debug_build.yml
    - .github/workflows/release_build.yml
    - app/build.gradle
    - app/proguard-rules.pro

key-decisions:
  - "EXTRA_DART_DEFINES env var i.p.v. --dart-define flags: add-to-app module gebruikt EXTRA_DART_DEFINES Gradle property"
  - "downloadBootstraps dependency toevoegen aan NDK build tasks: release build startte NDK build voor bootstrap download"
  - "ReLinker dontwarn + keep in ProGuard: Flutter FlutterJNI refereert ReLinker optioneel maar R8 faalt zonder rule"
  - "Release build signing faalt door lege/corrupt KEYSTORE_BASE64 secret — buiten scope, gedocumenteerd"

patterns-established:
  - "build_runner stap altijd NA flutter pub get en VOOR Gradle build stap"
  - "Secrets via env vars op de build stap, niet als workflow-level env"

requirements-completed: ["MERG-08"]

duration: 27min
completed: 2026-03-21
---

# Phase 6 Plan 07: CI/CD pipeline updaten + finale verificatie

**debug_build.yml en release_build.yml uitgebreid met build_runner codegen, dart-defines voor VOYAGE_API_KEY/SENTRY_DSN, en fixes voor bootstrap/ProGuard; debug CI build succesvol GROEN**

## Performance

- **Duration:** 27 min
- **Started:** 2026-03-21T06:00:56Z
- **Completed:** 2026-03-21T06:28:37Z
- **Tasks:** 5 (07.3 = groen debug build, 07.4 = release build faalt op signing secret, 07.5 = ADB niet verbonden)
- **Files modified:** 4

## Accomplishments
- debug_build.yml en release_build.yml bevatten nu `Flutter codegen (build_runner)` stap NA pub get en VOOR Gradle build
- EXTRA_DART_DEFINES met VOYAGE_API_KEY en SENTRY_DSN toegevoegd aan beide workflows
- Debug CI build geslaagd: alle 7 stappen groen, APK artifact `soul-terminal_v1.0.0+047fa33-soul-terminal-github-debug_arm64-v8a.apk` geüpload
- Release build bootstrap-volgorde bug opgelost (NDK build had bootstrap nodig)
- Release build ProGuard issue opgelost (ReLinker keep rule)

## Task Commits

1. **Task 07.1: debug_build.yml update** - `2f22c5de` (feat)
2. **Task 07.2: release_build.yml update** - `ea43ffac` (feat)
3. **Task 07.3: CI debug build triggered en GROEN** - geen aparte commit (CI verificatie)
4. **Task 07.4 fix 1: NDK build dependency** - `17b38cca` (fix)
5. **Task 07.4 fix 2: ProGuard ReLinker rule** - `93e2c6c8` (fix)

## Files Created/Modified
- `.github/workflows/debug_build.yml` - build_runner stap + EXTRA_DART_DEFINES toegevoegd
- `.github/workflows/release_build.yml` - build_runner stap + EXTRA_DART_DEFINES toegevoegd
- `app/build.gradle` - downloadBootstraps dependency voor NDK build tasks
- `app/proguard-rules.pro` - dontwarn + keep voor com.getkeepsafe.relinker en io.flutter

## Decisions Made
- `EXTRA_DART_DEFINES` env var i.p.v. `--dart-define` flags: in een add-to-app context worden dart-defines aan de host Gradle build doorgegeven via de `EXTRA_DART_DEFINES` property die Flutter's Gradle plugin automatisch verwerkt.
- NDK build tasks moeten expliciet afhangen van downloadBootstraps: in release mode worden NDK build tasks vóór javaCompile uitgevoerd, waardoor de bootstrap zip nog niet beschikbaar was.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] NDK build startte voor bootstrap download in release mode**
- **Found during:** Task 07.4 (release build verifiëren)
- **Issue:** `termux-bootstrap-zip.S:10:14: error: Could not find incbin file 'bootstrap-aarch64.zip'` — NDK build task startte vóór downloadBootstraps task
- **Fix:** `afterEvaluate` block uitgebreid: tasks met naam `buildNdkBuild*` en `configureNdkBuild*` krijgen `dependsOn downloadBootstraps`
- **Files modified:** `app/build.gradle`
- **Verification:** Volgende release build run geen bootstrap error meer
- **Committed in:** `17b38cca`

**2. [Rule 1 - Bug] ProGuard/R8 minification faalde door missing ReLinker classes**
- **Found during:** Task 07.4 (release build, tweede poging)
- **Issue:** `Missing class com.getkeepsafe.relinker.ReLinker` — FlutterJNI refereert ReLinker optioneel, maar R8 vereist keep/dontwarn rule
- **Fix:** `-dontwarn com.getkeepsafe.relinker.**` + `-keep class com.getkeepsafe.relinker.** { *; }` + Flutter keep rules toegevoegd
- **Files modified:** `app/proguard-rules.pro`
- **Verification:** Volgende release build run geen R8 error meer (faalt nu op signing)
- **Committed in:** `93e2c6c8`

---

**Total deviations:** 2 auto-fixed (2 bugs)
**Impact on plan:** Beide fixes noodzakelijk voor release build. De fixes zijn correcte technische oplossingen.

## Issues Encountered

**Release build signing (KEYSTORE_BASE64 secret):** Na het oplossen van de bootstrap en ProGuard issues faalt de release build op `packageRelease` met `KeytoolException: Failed to read key from store: Tag number over 30 is not supported`. Dit wijst op een lege of ongeldige `KEYSTORE_BASE64` GitHub secret. Dit is een CI secrets configuratie issue buiten scope van deze plan — de keystore moet handmatig aangemaakt en als secret geconfigureerd worden.

**Device verificatie (task 07.5):** ADB wireless debugging was niet verbonden tijdens uitvoering. De debug APK is beschikbaar in CI artifacts. Device verificatie kan handmatig worden gedaan via: `gh run download 23373499590 --repo eatsome-webapp/soul-terminal --name "soul-terminal_v1.0.0+047fa33-soul-terminal-github-debug_arm64-v8a"`.

## User Setup Required

**Release signing keystore:** De release build vereist een Android keystore. Maak aan met:
```bash
keytool -genkey -v -keystore soul-terminal.jks -keyalg RSA -keysize 2048 -validity 10000 -alias soul-terminal
base64 soul-terminal.jks > soul-terminal.jks.b64
```
Configureer GitHub secrets: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`.

## Next Phase Readiness
- Debug CI build is GROEN met build_runner codegen en dart-defines
- APK artifact bevat correcte versie+commit hash bestandsnaam
- Release build werkt tot aan signing stap — fix vereist keystore secrets configuratie
- Phase 6 merge is technisch compleet voor debug builds; release vereist signing setup

---
*Phase: 06-app-merge*
*Completed: 2026-03-21*
