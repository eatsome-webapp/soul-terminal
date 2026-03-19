---
phase: 1
plan: 01-E
name: "Apply SOUL Rebranding to Imported Source"
wave: 2
depends_on: [01-D]
files_modified:
  - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
  - app/build.gradle
  - gradle.properties
  - app/src/main/res/values/strings.xml
  - termux-shared/src/main/res/values/strings.xml
  - app/src/main/res/xml/shortcuts.xml
  - app/src/main/AndroidManifest.xml
  - app/src/main/java/com/termux/app/TermuxService.java
autonomous: true
requirements_addressed: [REBR-01, REBR-02, REBR-05, REBR-06]
---

# Plan 01-E: Apply SOUL Rebranding to Imported Source

<objective>
Apply all SOUL Terminal rebranding changes to the now-present Termux source code. This re-executes Plan A's intent on actual files: change applicationId to com.soul.terminal, app name to "SOUL Terminal", remove sharedUserId, raise SDK to 34/24, add foregroundServiceType, fix PendingIntent flags, and configure release signing.
</objective>

<must_haves>
- applicationId is com.soul.terminal (via manifestPlaceholders in app/build.gradle)
- App name is "SOUL Terminal" in TermuxConstants.java, both strings.xml files, and build.gradle manifestPlaceholders
- Java namespace com.termux is UNCHANGED in all build.gradle namespace fields
- sharedUserId and sharedUserLabel completely removed from AndroidManifest.xml
- targetSdkVersion=34 and minSdkVersion=24 in gradle.properties
- foregroundServiceType="specialUse" on TermuxService in AndroidManifest.xml
- FOREGROUND_SERVICE_SPECIAL_USE and POST_NOTIFICATIONS permissions declared in AndroidManifest.xml
- All PendingIntent calls in TermuxService.java use FLAG_IMMUTABLE instead of bare 0
- APK output filenames use "soul-terminal_" prefix instead of "termux-app_"
- versionName "1.0.0" and versionCode 1
- Release signing config present in app/build.gradle
- desugar_jdk_libs version is 2.1.3
- shortcuts.xml targetPackage attributes changed to com.soul.terminal
</must_haves>

## Tasks

<task id="01-E-T1">
<name>Update TermuxConstants.java — app name and package name</name>
<read_first>
- termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
</read_first>
<action>
In the file termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java, find and change these two constants:

1. Find the line containing `TERMUX_APP_NAME = "Termux"` and change to `TERMUX_APP_NAME = "SOUL Terminal"`
2. Find the line containing `TERMUX_PACKAGE_NAME = "com.termux"` and change to `TERMUX_PACKAGE_NAME = "com.soul.terminal"`

Do NOT change any other constants. The TERMUX_API_*, TERMUX_BOOT_*, TERMUX_FLOAT_*, etc. package names should stay as-is (they reference separate Termux plugin apps).

Commit with message: `feat(01-E): rebrand TermuxConstants — SOUL Terminal / com.soul.terminal`
</action>
<acceptance_criteria>
- grep -q 'TERMUX_APP_NAME = "SOUL Terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
- grep -q 'TERMUX_PACKAGE_NAME = "com.soul.terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
- grep -q 'TERMUX_API_PACKAGE_NAME' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java (plugin constants untouched)
</acceptance_criteria>
</task>

<task id="01-E-T2">
<name>Update app/build.gradle — applicationId, version, APK names, signing, desugar</name>
<read_first>
- app/build.gradle
</read_first>
<action>
In app/build.gradle, make these changes:

1. **versionCode**: Find `versionCode 118` (or similar) and change to `versionCode 1`
2. **versionName**: Find `versionName "0.118.0"` (or similar) and change to `versionName "1.0.0"`
3. **manifestPlaceholders package**: Find `manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.termux"` and change the value to `"com.soul.terminal"`
4. **manifestPlaceholders app name**: Find `manifestPlaceholders.TERMUX_APP_NAME = "Termux"` and change the value to `"SOUL Terminal"`
5. **APK output prefix**: Find all occurrences of `"termux-app_"` and replace with `"soul-terminal_"` (should be in outputFileName lines for debug and release)
6. **DO NOT change** `namespace "com.termux"` — this must remain as-is
7. **Release signing config**: Add a release signing config block inside the `signingConfigs` block (after the existing debug config):
```groovy
        release {
            storeFile file('release.jks')
            keyAlias System.getenv('KEY_ALIAS') ?: ''
            storePassword System.getenv('STORE_PASSWORD') ?: ''
            keyPassword System.getenv('KEY_PASSWORD') ?: ''
        }
```
8. **Apply signing to release buildType**: In the `buildTypes { release { ... } }` block, add `signingConfig signingConfigs.release`
9. **desugar_jdk_libs**: Find the desugar_jdk_libs dependency version (likely `1.1.5` or `1.2.2`) and change to `2.1.3`

Commit with message: `feat(01-E): rebrand build.gradle — com.soul.terminal, v1.0.0, signing config`
</action>
<acceptance_criteria>
- grep -q 'versionName "1.0.0"' app/build.gradle
- grep -qP 'versionCode 1\b' app/build.gradle
- grep -q 'TERMUX_PACKAGE_NAME = "com.soul.terminal"' app/build.gradle
- grep -q 'TERMUX_APP_NAME = "SOUL Terminal"' app/build.gradle
- grep -q 'soul-terminal_' app/build.gradle
- grep -qv 'termux-app_' app/build.gradle (old prefix gone — note: there may be comments, check outputFileName lines specifically)
- grep -q 'namespace "com.termux"' app/build.gradle (namespace unchanged)
- grep -q 'signingConfigs.release' app/build.gradle
- grep -q 'release.jks' app/build.gradle
- grep -q 'desugar_jdk_libs:2.1.3' app/build.gradle
</acceptance_criteria>
</task>

<task id="01-E-T3">
<name>Update gradle.properties — SDK versions</name>
<read_first>
- gradle.properties
</read_first>
<action>
In gradle.properties:

1. Find `minSdkVersion=21` and change to `minSdkVersion=24`
2. Find `targetSdkVersion=28` and change to `targetSdkVersion=34`

If the property names are slightly different (e.g., `TERMUX_MIN_SDK_VERSION`), change those instead to 24 and 34 respectively.

Commit with message: `feat(01-E): raise SDK — minSdk 24, targetSdk 34`
</action>
<acceptance_criteria>
- grep -qE '(min|MIN).*[Ss]dk.*=\s*24' gradle.properties
- grep -qE '(target|TARGET).*[Ss]dk.*=\s*34' gradle.properties
</acceptance_criteria>
</task>

<task id="01-E-T4">
<name>Update app/src/main/res/values/strings.xml — XML entities</name>
<read_first>
- app/src/main/res/values/strings.xml
</read_first>
<action>
In app/src/main/res/values/strings.xml, find the DOCTYPE entity declarations and change:

1. `<!ENTITY TERMUX_PACKAGE_NAME "com.termux">` to `<!ENTITY TERMUX_PACKAGE_NAME "com.soul.terminal">`
2. `<!ENTITY TERMUX_APP_NAME "Termux">` to `<!ENTITY TERMUX_APP_NAME "SOUL Terminal">`

If the file uses a different format for these strings (e.g., `<string name="app_name">Termux</string>`), change accordingly to "SOUL Terminal" and "com.soul.terminal".

Commit with message: `feat(01-E): rebrand app strings.xml entities`
</action>
<acceptance_criteria>
- grep -q 'com.soul.terminal' app/src/main/res/values/strings.xml
- grep -q 'SOUL Terminal' app/src/main/res/values/strings.xml
- grep -cv 'com.termux' app/src/main/res/values/strings.xml is not required (there may be other references), but the TERMUX_PACKAGE_NAME entity must be com.soul.terminal
</acceptance_criteria>
</task>

<task id="01-E-T5">
<name>Update termux-shared/src/main/res/values/strings.xml — XML entities + prefix path</name>
<read_first>
- termux-shared/src/main/res/values/strings.xml
</read_first>
<action>
In termux-shared/src/main/res/values/strings.xml, find and change:

1. `<!ENTITY TERMUX_PACKAGE_NAME "com.termux">` to `<!ENTITY TERMUX_PACKAGE_NAME "com.soul.terminal">`
2. `<!ENTITY TERMUX_APP_NAME "Termux">` to `<!ENTITY TERMUX_APP_NAME "SOUL Terminal">`
3. Find the line with `TERMUX_PREFIX_DIR_PATH` containing `/data/data/com.termux/files/usr` and change `com.termux` to `com.soul.terminal` so it reads `/data/data/com.soul.terminal/files/usr`
4. Similarly update any other path constants that reference `/data/data/com.termux/` to use `/data/data/com.soul.terminal/`

Commit with message: `feat(01-E): rebrand termux-shared strings.xml entities and paths`
</action>
<acceptance_criteria>
- grep -q 'com.soul.terminal' termux-shared/src/main/res/values/strings.xml
- grep -q 'SOUL Terminal' termux-shared/src/main/res/values/strings.xml
- grep -q '/data/data/com.soul.terminal/' termux-shared/src/main/res/values/strings.xml
- grep -cv 'TERMUX_PACKAGE_NAME "com.termux"' termux-shared/src/main/res/values/strings.xml (the old entity value must be gone)
</acceptance_criteria>
</task>

<task id="01-E-T6">
<name>Update shortcuts.xml — targetPackage to com.soul.terminal</name>
<read_first>
- app/src/main/res/xml/shortcuts.xml
</read_first>
<action>
In app/src/main/res/xml/shortcuts.xml, replace ALL occurrences of `android:targetPackage="com.termux"` with `android:targetPackage="com.soul.terminal"`.

There should be 3 occurrences (one per shortcut). Do NOT change `android:targetClass` values — those reference Java class names which remain in the com.termux namespace.

Commit with message: `feat(01-E): rebrand shortcuts.xml targetPackage`
</action>
<acceptance_criteria>
- grep -c 'targetPackage="com.soul.terminal"' app/src/main/res/xml/shortcuts.xml returns 3
- grep -c 'targetPackage="com.termux"' app/src/main/res/xml/shortcuts.xml returns 0
- grep -q 'targetClass="com.termux' app/src/main/res/xml/shortcuts.xml (class names unchanged)
</acceptance_criteria>
</task>

<task id="01-E-T7">
<name>Remove sharedUserId from AndroidManifest.xml and add permissions + foregroundServiceType</name>
<read_first>
- app/src/main/AndroidManifest.xml
</read_first>
<action>
In app/src/main/AndroidManifest.xml:

1. **Remove sharedUserId**: Delete the `android:sharedUserId="${TERMUX_PACKAGE_NAME}"` attribute from the `<manifest>` tag
2. **Remove sharedUserLabel**: Delete the `android:sharedUserLabel="@string/shared_user_label"` attribute from the `<manifest>` tag (if present)
3. **Add FOREGROUND_SERVICE_SPECIAL_USE permission**: Add `<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />` before the existing permission declarations
4. **Add POST_NOTIFICATIONS permission**: Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` alongside the other permissions
5. **Add foregroundServiceType to TermuxService**: Find the `<service android:name=".app.TermuxService"` declaration and add `android:foregroundServiceType="specialUse"` attribute to it

Commit with message: `feat(01-E): remove sharedUserId, add foregroundServiceType + permissions`
</action>
<acceptance_criteria>
- grep -c 'sharedUserId' app/src/main/AndroidManifest.xml returns 0
- grep -c 'sharedUserLabel' app/src/main/AndroidManifest.xml returns 0
- grep -q 'FOREGROUND_SERVICE_SPECIAL_USE' app/src/main/AndroidManifest.xml
- grep -q 'POST_NOTIFICATIONS' app/src/main/AndroidManifest.xml
- grep -q 'foregroundServiceType="specialUse"' app/src/main/AndroidManifest.xml
</acceptance_criteria>
</task>

<task id="01-E-T8">
<name>Fix PendingIntent mutability flags in TermuxService.java</name>
<read_first>
- app/src/main/java/com/termux/app/TermuxService.java
</read_first>
<action>
In app/src/main/java/com/termux/app/TermuxService.java, find all PendingIntent creation calls that use a bare `0` as the flags parameter and replace with `PendingIntent.FLAG_IMMUTABLE`.

Look for patterns like:
- `PendingIntent.getActivity(this, 0, notificationIntent, 0)` — change last `0` to `PendingIntent.FLAG_IMMUTABLE`
- `PendingIntent.getService(this, 0, exitIntent, 0)` — change last `0` to `PendingIntent.FLAG_IMMUTABLE`
- `PendingIntent.getService(this, 0, toggleWakeLockIntent, 0)` — change last `0` to `PendingIntent.FLAG_IMMUTABLE`

There should be approximately 3 such calls. Do NOT change calls that already use FLAG_UPDATE_CURRENT, FLAG_IMMUTABLE, or FLAG_MUTABLE.

Also check termux-shared/ for any bare-0 PendingIntent calls:
```bash
grep -rn 'PendingIntent.get.*,\s*0)' termux-shared/src/main/java/
```
If any are found, fix those too. If all already use FLAG_UPDATE_CURRENT or FLAG_IMMUTABLE, document that and skip.

Commit with message: `feat(01-E): fix PendingIntent FLAG_IMMUTABLE for targetSdk 34`
</action>
<acceptance_criteria>
- grep -c 'FLAG_IMMUTABLE' app/src/main/java/com/termux/app/TermuxService.java returns at least 3
- grep -cP 'PendingIntent\.get.*,\s*0\)' app/src/main/java/com/termux/app/TermuxService.java returns 0
- grep -rcP 'PendingIntent\.get.*,\s*0\)' termux-shared/src/main/java/ returns 0
</acceptance_criteria>
</task>

<task id="01-E-T9">
<name>Merge SOUL colors into Termux colors.xml without breaking resource references</name>
<read_first>
- app/src/main/res/values/colors.xml
- /data/data/com.termux/files/home/soul-terminal/app/src/main/res/values/styles.xml
</read_first>
<action>
The current colors.xml is the SOUL version (restored in Plan D). It may be missing Termux-specific color entries that other resource files reference (e.g., color references in layouts or drawables).

Check if the original Termux colors.xml had entries that are now missing by comparing. The Termux colors.xml typically defines colors like `design_default_color_primary`, etc.

If the SOUL colors.xml is missing Termux-required entries, ADD them (do not remove SOUL entries). The SOUL colors that MUST remain are:
- `soul_primary` (#6C63FF)
- `soul_primary_dark` (#1A1A2E)
- `soul_accent` (#00D9FF)
- `soul_background` (#0F0F23)
- `soul_surface` (#16213E)
- `soul_icon_background` (#1A1A2E)

If there are NO missing Termux color references (i.e., the build compiles fine with just SOUL colors), no changes needed — just verify and skip.

Commit (if changes made): `feat(01-E): merge SOUL + Termux color definitions`
</action>
<acceptance_criteria>
- grep -q 'soul_primary' app/src/main/res/values/colors.xml
- grep -q '#6C63FF' app/src/main/res/values/colors.xml
- grep -q 'soul_accent' app/src/main/res/values/colors.xml
- grep -q 'soul_icon_background' app/src/main/res/values/colors.xml
</acceptance_criteria>
</task>

## Verification
- `grep -q 'TERMUX_APP_NAME = "SOUL Terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java && echo PASS`
- `grep -q 'TERMUX_PACKAGE_NAME = "com.soul.terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java && echo PASS`
- `grep -q 'com.soul.terminal' app/build.gradle && echo PASS`
- `grep -q 'namespace "com.termux"' app/build.gradle && echo PASS` (namespace preserved)
- `grep -c 'sharedUserId' app/src/main/AndroidManifest.xml` returns 0
- `grep -q 'foregroundServiceType="specialUse"' app/src/main/AndroidManifest.xml && echo PASS`
- `grep -q 'versionName "1.0.0"' app/build.gradle && echo PASS`
- `grep -q 'soul-terminal_' app/build.gradle && echo PASS`
- `grep -q 'signingConfigs.release' app/build.gradle && echo PASS`
- `grep -cP 'PendingIntent\.get.*,\s*0\)' app/src/main/java/com/termux/app/TermuxService.java` returns 0
- `grep -q 'soul_primary' app/src/main/res/values/colors.xml && echo PASS`
- Push to GitHub and verify debug_build.yml CI workflow succeeds
