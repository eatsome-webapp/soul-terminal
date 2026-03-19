---
phase: 3
plan: "03-E"
title: "CI/CD Two-Stage Build"
wave: 1
depends_on: []
files_modified:
  - .github/workflows/debug_build.yml
  - .github/workflows/release_build.yml
requirements_addressed: [CICD-03]
autonomous: true
---

# Plan 03-E: CI/CD Two-Stage Build

<objective>
Update both GitHub Actions workflows (debug and release) to install the Flutter SDK, run `flutter pub get` in the Flutter module, so Gradle can build the terminal app with the embedded Flutter module.
</objective>

<task id="03-E-01">
<title>Add Flutter SDK setup and pub get to debug_build.yml</title>
<read_first>
- .github/workflows/debug_build.yml
- .planning/phases/03-flutter-integration/03-RESEARCH.md (CI/CD Two-Stage Build section)
</read_first>
<action>
In `.github/workflows/debug_build.yml`, add two steps between "Setup java 17" and "Build debug APK":

After the "Setup java 17" step, add:

```yaml
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
          channel: 'stable'
          cache: true

      - name: Flutter pub get
        run: |
          cd flutter_module
          flutter pub get
```

These steps:
1. Install Flutter 3.41.4 with caching enabled (caches Flutter SDK and pub cache)
2. Run `flutter pub get` in flutter_module/ which generates the `.android/` directory containing `include_flutter.groovy` — required by `settings.gradle`

The Gradle build step (`./gradlew assembleDebug`) remains unchanged — it automatically builds the Flutter module via source inclusion.
</action>
<acceptance_criteria>
- `.github/workflows/debug_build.yml` contains `uses: subosito/flutter-action@v2`
- `.github/workflows/debug_build.yml` contains `flutter-version: '3.41.4'`
- `.github/workflows/debug_build.yml` contains `cache: true` under flutter-action
- `.github/workflows/debug_build.yml` contains `flutter pub get` after Flutter setup
- `.github/workflows/debug_build.yml` contains `cd flutter_module` before `flutter pub get`
- The Flutter setup steps appear BEFORE the "Build debug APK" step
- The Flutter setup steps appear AFTER the "Setup java 17" step
</acceptance_criteria>
</task>

<task id="03-E-02">
<title>Add Flutter SDK setup and pub get to release_build.yml</title>
<read_first>
- .github/workflows/release_build.yml
</read_first>
<action>
In `.github/workflows/release_build.yml`, add two steps between "Setup java 17" and "Decode keystore":

After the "Setup java 17" step, add:

```yaml
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
          channel: 'stable'
          cache: true

      - name: Flutter pub get
        run: |
          cd flutter_module
          flutter pub get
```

These steps must appear BEFORE "Decode keystore" and "Build release APK" — the Flutter SDK and generated `.android/` directory are needed by the Gradle build.
</action>
<acceptance_criteria>
- `.github/workflows/release_build.yml` contains `uses: subosito/flutter-action@v2`
- `.github/workflows/release_build.yml` contains `flutter-version: '3.41.4'`
- `.github/workflows/release_build.yml` contains `cache: true` under flutter-action
- `.github/workflows/release_build.yml` contains `flutter pub get` after Flutter setup
- `.github/workflows/release_build.yml` contains `cd flutter_module` before `flutter pub get`
- The Flutter setup steps appear AFTER "Setup java 17" and BEFORE "Decode keystore"
</acceptance_criteria>
</task>

<task id="03-E-03">
<title>Add Gradle caching to both workflows</title>
<read_first>
- .github/workflows/debug_build.yml
- .github/workflows/release_build.yml
</read_first>
<action>
Add Gradle caching to both workflows to speed up builds. In both `debug_build.yml` and `release_build.yml`, add this step after the "Flutter pub get" step and before the build step:

```yaml
      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: |
            gradle-
```

This caches the Gradle wrapper download and dependency resolution between builds.
</action>
<acceptance_criteria>
- `.github/workflows/debug_build.yml` contains `uses: actions/cache@v4`
- `.github/workflows/debug_build.yml` contains `~/.gradle/caches` in the cache path
- `.github/workflows/release_build.yml` contains `uses: actions/cache@v4`
- `.github/workflows/release_build.yml` contains `~/.gradle/caches` in the cache path
</acceptance_criteria>
</task>

<task id="03-E-04">
<title>Update workflow branch triggers for main branch</title>
<read_first>
- .github/workflows/debug_build.yml (lines 3-8 for trigger config)
</read_first>
<action>
The current `debug_build.yml` triggers on `master` branch. The repository uses `main` as the default branch. Update the triggers:

In `.github/workflows/debug_build.yml`, change:
```yaml
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  workflow_dispatch:
```
To:
```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
```
</action>
<acceptance_criteria>
- `.github/workflows/debug_build.yml` contains `branches: [ main ]` (not `master`)
- `.github/workflows/debug_build.yml` does NOT contain `branches: [ master ]`
</acceptance_criteria>
</task>

<verification>
## Verification Criteria
- Both workflows include Flutter SDK 3.41.4 setup via `subosito/flutter-action@v2`
- Both workflows run `flutter pub get` in `flutter_module/` before the Gradle build
- Gradle caching is enabled in both workflows
- Debug build triggers on `main` branch (not `master`)
- A push to main triggers the debug build workflow and it succeeds with Flutter + Gradle two-stage build
- Release build triggers on tag push and succeeds with Flutter + Gradle two-stage build
</verification>

<must_haves>
- Flutter SDK 3.41.4 installed in CI via subosito/flutter-action@v2 with caching (CICD-03)
- `flutter pub get` runs in flutter_module/ to generate .android/ directory (CICD-03)
- Gradle build succeeds with Flutter module source inclusion (CICD-03)
- Both debug and release workflows updated with identical Flutter setup steps (CICD-03)
</must_haves>
