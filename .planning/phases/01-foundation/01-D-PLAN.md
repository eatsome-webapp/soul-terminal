---
phase: 1
plan: 01-D
name: "Import Termux Source Code"
wave: 1
depends_on: []
files_modified:
  - app/build.gradle
  - gradle.properties
  - settings.gradle
  - build.gradle
  - gradlew
  - gradlew.bat
  - gradle/wrapper/gradle-wrapper.jar
  - gradle/wrapper/gradle-wrapper.properties
  - app/src/main/AndroidManifest.xml
  - app/src/main/java/com/termux/app/TermuxActivity.java
  - app/src/main/java/com/termux/app/TermuxService.java
  - app/src/main/res/values/strings.xml
  - app/src/main/res/xml/shortcuts.xml
  - termux-shared/build.gradle
  - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
  - termux-shared/src/main/res/values/strings.xml
autonomous: true
requirements_addressed: [REBR-01, REBR-02, REBR-05, REBR-06]
---

# Plan 01-D: Import Termux Source Code

<objective>
Import the complete termux-app v0.118.1 source code into the soul-terminal repository. This is the critical gap: the repo currently contains only resource overlays (icons, colors, styles) and CI workflows, but no actual Android source code, Gradle build files, or Java sources. Without this, nothing compiles.
</objective>

<must_haves>
- Complete Gradle project structure present: settings.gradle, build.gradle, gradlew, gradle/wrapper/
- app/build.gradle exists with a valid Android application plugin configuration
- app/src/main/AndroidManifest.xml exists
- app/src/main/java/com/termux/app/ directory contains TermuxActivity.java and TermuxService.java
- termux-shared/ module exists with its own build.gradle and TermuxConstants.java
- gradle.properties exists with SDK version properties
- app/src/main/res/values/strings.xml exists (the Termux original, not just the SOUL overlay)
- Existing SOUL resource files (colors.xml, styles.xml, ic_foreground.xml, mipmap PNGs, adaptive icon XMLs) are preserved — NOT overwritten
- Existing .github/workflows/ are preserved — NOT overwritten
- Existing .planning/ directory is preserved
- The project structure matches what the CI workflows (debug_build.yml, release_build.yml) expect: ./gradlew assembleDebug works from repo root
</must_haves>

## Tasks

<task id="01-D-T1">
<name>Clone termux-app v0.118.1 source into temp directory</name>
<read_first>
- .github/workflows/debug_build.yml
</read_first>
<action>
Clone the termux-app repository at the v0.118.1 tag (the last stable release, matching the versionCode 118 referenced in Plan A) into a temporary directory. This gives us the complete source tree to import.

```bash
cd /data/data/com.termux/files/home
git clone --depth 1 --branch v0.118.1 https://github.com/termux/termux-app.git termux-app-upstream
```

If v0.118.1 tag does not exist, try v0.118.0. If neither exists, clone the default branch and check `app/build.gradle` for `versionCode 118` or the closest recent version.

After cloning, verify the expected structure exists:
```bash
test -f termux-app-upstream/app/build.gradle && echo "OK: app/build.gradle"
test -f termux-app-upstream/settings.gradle && echo "OK: settings.gradle"
test -f termux-app-upstream/gradlew && echo "OK: gradlew"
test -f termux-app-upstream/gradle.properties && echo "OK: gradle.properties"
test -f termux-app-upstream/app/src/main/AndroidManifest.xml && echo "OK: AndroidManifest"
test -f termux-app-upstream/termux-shared/build.gradle && echo "OK: termux-shared/build.gradle"
```
</action>
<acceptance_criteria>
- File /data/data/com.termux/files/home/termux-app-upstream/app/build.gradle exists
- File /data/data/com.termux/files/home/termux-app-upstream/settings.gradle exists
- File /data/data/com.termux/files/home/termux-app-upstream/gradlew exists
- File /data/data/com.termux/files/home/termux-app-upstream/gradle.properties exists
- File /data/data/com.termux/files/home/termux-app-upstream/app/src/main/AndroidManifest.xml exists
- File /data/data/com.termux/files/home/termux-app-upstream/termux-shared/build.gradle exists
- File /data/data/com.termux/files/home/termux-app-upstream/termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java exists
</acceptance_criteria>
</task>

<task id="01-D-T2">
<name>Backup existing SOUL overlay files</name>
<read_first>
- app/src/main/res/values/colors.xml
- app/src/main/res/values/styles.xml
- app/src/main/res/drawable/ic_foreground.xml
- app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
</read_first>
<action>
Before importing Termux source, back up all SOUL-specific files that must NOT be overwritten by upstream Termux files.

```bash
cd /data/data/com.termux/files/home/soul-terminal
mkdir -p /data/data/com.termux/files/home/soul-backup

# Backup SOUL resource overlays
cp -r app/src/main/res/values/colors.xml /data/data/com.termux/files/home/soul-backup/colors.xml
cp -r app/src/main/res/values/styles.xml /data/data/com.termux/files/home/soul-backup/styles.xml
cp -r app/src/main/res/drawable/ic_foreground.xml /data/data/com.termux/files/home/soul-backup/ic_foreground.xml
cp -r app/src/main/res/mipmap-anydpi-v26/ /data/data/com.termux/files/home/soul-backup/mipmap-anydpi-v26/
cp -r app/src/main/res/mipmap-mdpi/ /data/data/com.termux/files/home/soul-backup/mipmap-mdpi/
cp -r app/src/main/res/mipmap-hdpi/ /data/data/com.termux/files/home/soul-backup/mipmap-hdpi/
cp -r app/src/main/res/mipmap-xhdpi/ /data/data/com.termux/files/home/soul-backup/mipmap-xhdpi/
cp -r app/src/main/res/mipmap-xxhdpi/ /data/data/com.termux/files/home/soul-backup/mipmap-xxhdpi/
cp -r app/src/main/res/mipmap-xxxhdpi/ /data/data/com.termux/files/home/soul-backup/mipmap-xxxhdpi/

# Backup CI workflows
cp -r .github/ /data/data/com.termux/files/home/soul-backup/.github/

# Backup planning
cp -r .planning/ /data/data/com.termux/files/home/soul-backup/.planning/
```
</action>
<acceptance_criteria>
- File /data/data/com.termux/files/home/soul-backup/colors.xml exists
- File /data/data/com.termux/files/home/soul-backup/styles.xml exists
- File /data/data/com.termux/files/home/soul-backup/ic_foreground.xml exists
- Directory /data/data/com.termux/files/home/soul-backup/mipmap-anydpi-v26/ exists
- Directory /data/data/com.termux/files/home/soul-backup/.github/ exists
- Directory /data/data/com.termux/files/home/soul-backup/.planning/ exists
</acceptance_criteria>
</task>

<task id="01-D-T3">
<name>Copy Termux source into soul-terminal repo</name>
<read_first>
- /data/data/com.termux/files/home/termux-app-upstream/settings.gradle
</read_first>
<action>
Copy the entire Termux source tree into the soul-terminal repo, excluding the .git directory and any files we want to keep as SOUL versions.

```bash
cd /data/data/com.termux/files/home

# Copy all Termux source files, excluding .git
rsync -av --exclude='.git' --exclude='.github' termux-app-upstream/ soul-terminal/

# If rsync is not available, use:
# cd termux-app-upstream
# find . -not -path './.git/*' -not -path './.git' -not -path './.github/*' -not -path './.github' | while read f; do
#   if [ -f "$f" ]; then
#     mkdir -p "/data/data/com.termux/files/home/soul-terminal/$(dirname "$f")"
#     cp "$f" "/data/data/com.termux/files/home/soul-terminal/$f"
#   fi
# done
```

This will import:
- Root build files: settings.gradle, build.gradle, gradlew, gradlew.bat, gradle.properties, gradle/wrapper/
- app/ module: build.gradle, proguard, AndroidManifest.xml, all Java sources, all resources
- termux-shared/ module: build.gradle, all Java sources, all resources
- terminal-view/ module (terminal rendering library)
- terminal-emulator/ module (terminal emulation logic)
- Any other modules referenced in settings.gradle

The existing app/src/main/res/ SOUL files will be OVERWRITTEN by Termux originals — this is intentional, we restore them in the next task.
</action>
<acceptance_criteria>
- File /data/data/com.termux/files/home/soul-terminal/settings.gradle exists
- File /data/data/com.termux/files/home/soul-terminal/build.gradle exists
- File /data/data/com.termux/files/home/soul-terminal/gradlew exists and is executable
- File /data/data/com.termux/files/home/soul-terminal/gradle.properties exists
- File /data/data/com.termux/files/home/soul-terminal/gradle/wrapper/gradle-wrapper.jar exists
- File /data/data/com.termux/files/home/soul-terminal/app/build.gradle exists
- File /data/data/com.termux/files/home/soul-terminal/app/src/main/AndroidManifest.xml exists
- File /data/data/com.termux/files/home/soul-terminal/app/src/main/java/com/termux/app/TermuxActivity.java exists
- File /data/data/com.termux/files/home/soul-terminal/app/src/main/java/com/termux/app/TermuxService.java exists
- File /data/data/com.termux/files/home/soul-terminal/termux-shared/build.gradle exists
- File /data/data/com.termux/files/home/soul-terminal/termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java exists
- File /data/data/com.termux/files/home/soul-terminal/app/src/main/res/values/strings.xml exists
- Directory /data/data/com.termux/files/home/soul-terminal/.github/ still exists (not overwritten)
</acceptance_criteria>
</task>

<task id="01-D-T4">
<name>Restore SOUL overlay files over Termux originals</name>
<read_first>
- /data/data/com.termux/files/home/soul-backup/colors.xml
- /data/data/com.termux/files/home/soul-backup/styles.xml
</read_first>
<action>
Restore the SOUL-branded resource files that were backed up in T2, overwriting the Termux originals that were imported in T3.

```bash
cd /data/data/com.termux/files/home/soul-terminal

# Restore SOUL colors.xml (contains soul_primary, soul_accent, soul_icon_background, etc.)
cp /data/data/com.termux/files/home/soul-backup/colors.xml app/src/main/res/values/colors.xml

# Restore SOUL styles.xml (contains AppTheme with SOUL colors)
cp /data/data/com.termux/files/home/soul-backup/styles.xml app/src/main/res/values/styles.xml

# Restore SOUL icon foreground (">_" vector drawable)
cp /data/data/com.termux/files/home/soul-backup/ic_foreground.xml app/src/main/res/drawable/ic_foreground.xml

# Restore SOUL adaptive icon configs
cp -r /data/data/com.termux/files/home/soul-backup/mipmap-anydpi-v26/* app/src/main/res/mipmap-anydpi-v26/

# Restore SOUL raster icon fallbacks (all densities)
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp -r /data/data/com.termux/files/home/soul-backup/mipmap-${density}/* app/src/main/res/mipmap-${density}/
done

# Restore CI workflows (should not have been touched, but be safe)
cp -r /data/data/com.termux/files/home/soul-backup/.github/* .github/

# Restore planning
cp -r /data/data/com.termux/files/home/soul-backup/.planning/* .planning/
```

After restoring, verify SOUL-specific content is present:
```bash
grep -q 'soul_primary' app/src/main/res/values/colors.xml && echo "OK: SOUL colors"
grep -q 'soul_icon_background' app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml && echo "OK: SOUL adaptive icon"
grep -q 'viewportWidth="108"' app/src/main/res/drawable/ic_foreground.xml && echo "OK: SOUL foreground icon"
```
</action>
<acceptance_criteria>
- grep -q 'soul_primary' app/src/main/res/values/colors.xml returns 0
- grep -q '#6C63FF' app/src/main/res/values/colors.xml returns 0
- grep -q 'soul_icon_background' app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml returns 0
- grep -q 'viewportWidth="108"' app/src/main/res/drawable/ic_foreground.xml returns 0
- grep -q '@color/soul_primary' app/src/main/res/values/styles.xml returns 0
- File .github/workflows/debug_build.yml exists and contains 'soul-terminal_'
- File .github/workflows/release_build.yml exists and contains 'KEYSTORE_BASE64'
</acceptance_criteria>
</task>

<task id="01-D-T5">
<name>Commit imported Termux source as single atomic commit</name>
<read_first>
- app/build.gradle
- settings.gradle
</read_first>
<action>
Stage and commit all imported Termux source files. This should be a single large commit that establishes the project baseline.

```bash
cd /data/data/com.termux/files/home/soul-terminal
git add -A
git commit -m "feat(01-D): import termux-app v0.118.1 source code

Import complete Termux source tree as foundation for SOUL Terminal.
This provides the missing Android project structure, Gradle build
files, Java sources, and resources that Plans A-C assumed were present.

Source: https://github.com/termux/termux-app tag v0.118.1
SOUL overlay files (icons, colors, styles, CI workflows) preserved."
```

Then verify key files are tracked:
```bash
git ls-files app/build.gradle settings.gradle gradlew gradle.properties
git ls-files app/src/main/AndroidManifest.xml
git ls-files termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
```
</action>
<acceptance_criteria>
- git log --oneline -1 contains "import termux-app"
- git ls-files app/build.gradle returns app/build.gradle (file is tracked)
- git ls-files settings.gradle returns settings.gradle (file is tracked)
- git ls-files gradlew returns gradlew (file is tracked)
- git ls-files app/src/main/AndroidManifest.xml returns the file (tracked)
- git ls-files termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java returns the file (tracked)
</acceptance_criteria>
</task>

<task id="01-D-T6">
<name>Clean up temp directories</name>
<read_first>
- /data/data/com.termux/files/home/soul-terminal/app/build.gradle
</read_first>
<action>
Remove the temporary upstream clone and backup directory now that everything is committed.

```bash
rm -rf /data/data/com.termux/files/home/termux-app-upstream
rm -rf /data/data/com.termux/files/home/soul-backup
```
</action>
<acceptance_criteria>
- Directory /data/data/com.termux/files/home/termux-app-upstream does not exist
- Directory /data/data/com.termux/files/home/soul-backup does not exist
</acceptance_criteria>
</task>

## Verification
- `test -f app/build.gradle && echo PASS` returns PASS
- `test -f settings.gradle && echo PASS` returns PASS
- `test -x gradlew && echo PASS` returns PASS (executable)
- `test -f app/src/main/AndroidManifest.xml && echo PASS` returns PASS
- `test -f termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java && echo PASS` returns PASS
- `grep -q 'soul_primary' app/src/main/res/values/colors.xml && echo PASS` returns PASS (SOUL overlay preserved)
- `grep -q 'soul-terminal_' .github/workflows/debug_build.yml && echo PASS` returns PASS (CI preserved)
- `git status` shows clean working tree
