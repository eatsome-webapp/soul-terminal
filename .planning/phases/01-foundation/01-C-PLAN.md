---
phase: 1
plan: C
wave: 2
depends_on: [01-A, 01-B]
autonomous: true
requirements: [CICD-01, CICD-02]
files_modified:
  - .github/workflows/debug_build.yml
  - .github/workflows/release_build.yml
---

# Plan 01-C: CI/CD Pipeline

<objective>
Update the existing debug build workflow for SOUL Terminal (simplified matrix, ARM64 focus, new APK names) and create a new release build workflow with keystore signing via GitHub Secrets.
</objective>

<tasks>

<task id="1">
<title>Update debug_build.yml for SOUL Terminal</title>
<read_first>
- .github/workflows/debug_build.yml
</read_first>
<action>
Rewrite `.github/workflows/debug_build.yml` with these changes:

1. Keep `name: Build` (or change to `name: Debug Build`)
2. Keep triggers: push to master, PRs to master. Remove `github-releases/**` branch trigger.
3. Remove the matrix strategy — only build `apt-android-7` (hardcode TERMUX_PACKAGE_VARIANT)
4. Change APK_BASENAME_PREFIX from `"termux-app_$APK_VERSION_TAG"` to `"soul-terminal_$APK_VERSION_TAG"`
5. Simplify ABI validation: only validate `universal` and `arm64-v8a` APKs (remove armeabi-v7a, x86_64, x86)
6. Remove upload-artifact steps for armeabi-v7a, x86_64, x86
7. Keep upload-artifact steps for universal and arm64-v8a
8. Update sha256sums to only include universal and arm64-v8a
9. Add `workflow_dispatch:` trigger for manual builds
</action>
<acceptance_criteria>
- [ ] grep -q 'soul-terminal_' .github/workflows/debug_build.yml
- [ ] ! grep -q 'termux-app_' .github/workflows/debug_build.yml (old prefix removed)
- [ ] grep -q 'workflow_dispatch' .github/workflows/debug_build.yml
- [ ] grep -qv 'apt-android-5' .github/workflows/debug_build.yml (old variant removed)
- [ ] grep -c 'armeabi-v7a' .github/workflows/debug_build.yml returns 0
- [ ] grep -c 'x86' .github/workflows/debug_build.yml returns 0
- [ ] grep -q 'arm64-v8a' .github/workflows/debug_build.yml
- [ ] grep -q 'universal' .github/workflows/debug_build.yml
</acceptance_criteria>
</task>

<task id="2">
<title>Create release_build.yml workflow</title>
<read_first>
- .github/workflows/debug_build.yml
- app/build.gradle
</read_first>
<action>
Create `.github/workflows/release_build.yml` with this content:

```yaml
name: Release Build

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Clone repository
        uses: actions/checkout@v4

      - name: Setup java 17
        uses: actions/setup-java@v5
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > app/release.jks

      - name: Build release APK
        shell: bash {0}
        env:
          TERMUX_PACKAGE_VARIANT: apt-android-7
          STORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
        run: |
          exit_on_error() { echo "$1"; exit 1; }

          CURRENT_VERSION_NAME_REGEX='\s+versionName "([^"]+)"$'
          CURRENT_VERSION_NAME="$(grep -m 1 -E "$CURRENT_VERSION_NAME_REGEX" ./app/build.gradle | sed -r "s/$CURRENT_VERSION_NAME_REGEX/\1/")"
          RELEASE_VERSION_NAME="v$CURRENT_VERSION_NAME+${GITHUB_SHA:0:7}"

          APK_DIR_PATH="./app/build/outputs/apk/release"
          APK_VERSION_TAG="$RELEASE_VERSION_NAME-apt-android-7-release"
          APK_BASENAME_PREFIX="soul-terminal_$APK_VERSION_TAG"

          echo "APK_DIR_PATH=$APK_DIR_PATH" >> $GITHUB_ENV
          echo "APK_VERSION_TAG=$APK_VERSION_TAG" >> $GITHUB_ENV
          echo "APK_BASENAME_PREFIX=$APK_BASENAME_PREFIX" >> $GITHUB_ENV

          export TERMUX_APP_VERSION_NAME="${RELEASE_VERSION_NAME/v/}"
          export TERMUX_APK_VERSION_TAG="$APK_VERSION_TAG"

          if ! ./gradlew assembleRelease; then
            exit_on_error "Build failed for '$APK_VERSION_TAG' build."
          fi

          echo "Validating APKs"
          if ! test -f "$APK_DIR_PATH/${APK_BASENAME_PREFIX}_universal.apk"; then
            files_found="$(ls "$APK_DIR_PATH")"
            exit_on_error "Failed to find built APK. Files found: "$'\n'"$files_found"
          fi

          echo "Generating sha256sums"
          (cd "$APK_DIR_PATH"; sha256sum "${APK_BASENAME_PREFIX}_universal.apk" > "${APK_BASENAME_PREFIX}_sha256sums")

      - name: Attach universal APK
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.APK_BASENAME_PREFIX }}_universal
          path: |
            ${{ env.APK_DIR_PATH }}/${{ env.APK_BASENAME_PREFIX }}_universal.apk

      - name: Attach sha256sums
        uses: actions/upload-artifact@v4
        with:
          name: ${{ env.APK_BASENAME_PREFIX }}_sha256sums
          path: |
            ${{ env.APK_DIR_PATH }}/${{ env.APK_BASENAME_PREFIX }}_sha256sums
```

Note: The release build uses `assembleRelease` which picks up `signingConfigs.release` from build.gradle (added in Plan 01-A task 2). ABI splits are disabled for release builds by default (`splitAPKsForReleaseBuilds = "0"`), so only a universal APK is produced.
</action>
<acceptance_criteria>
- [ ] File .github/workflows/release_build.yml exists
- [ ] grep -q 'Release Build' .github/workflows/release_build.yml
- [ ] grep -q 'KEYSTORE_BASE64' .github/workflows/release_build.yml
- [ ] grep -q 'KEYSTORE_PASSWORD' .github/workflows/release_build.yml
- [ ] grep -q 'KEY_ALIAS' .github/workflows/release_build.yml
- [ ] grep -q 'assembleRelease' .github/workflows/release_build.yml
- [ ] grep -q 'soul-terminal_' .github/workflows/release_build.yml
- [ ] grep -q "tags:" .github/workflows/release_build.yml
</acceptance_criteria>
</task>

</tasks>

<verification>
1. `debug_build.yml` builds only apt-android-7, produces soul-terminal_* APKs, only universal + arm64-v8a
2. `release_build.yml` triggers on tags and workflow_dispatch, uses GitHub Secrets for signing
3. Both workflows use Java 17, checkout@v4, upload-artifact@v4
4. Push to master triggers debug build successfully in GitHub Actions
</verification>

<must_haves>
- Debug build workflow produces `soul-terminal_*` APKs (not `termux-app_*`)
- Debug build only builds apt-android-7 variant (no apt-android-5)
- Debug build only produces universal + arm64-v8a APKs
- Release build workflow exists with keystore signing via GitHub Secrets
- Release build triggers on version tags (`v*`) and manual dispatch
- Both workflows are valid YAML and reference correct action versions
</must_haves>
