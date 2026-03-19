---
phase: 1
plan: A
wave: 1
depends_on: []
autonomous: true
requirements: [REBR-01, REBR-02, REBR-05, REBR-06]
files_modified:
  - termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
  - app/build.gradle
  - app/src/main/res/values/strings.xml
  - termux-shared/src/main/res/values/strings.xml
  - app/src/main/res/xml/shortcuts.xml
  - app/src/main/AndroidManifest.xml
  - gradle.properties
  - termux-shared/build.gradle
  - app/src/main/java/com/termux/app/TermuxService.java
---

# Plan 01-A: Rebranding & SDK Migration

<objective>
Rebrand the app from Termux to SOUL Terminal (package name, app name, versioning), remove sharedUserId, raise targetSdk to 34 and minSdk to 24, and fix all API 31-34 breaking changes (foregroundServiceType, POST_NOTIFICATIONS, PendingIntent mutability flags).
</objective>

<tasks>

<task id="1">
<title>Update TermuxConstants.java — single source of truth</title>
<read_first>
- termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
</read_first>
<action>
Change line 350:
  `TERMUX_APP_NAME = "Termux"` → `TERMUX_APP_NAME = "SOUL Terminal"`

Change line 352:
  `TERMUX_PACKAGE_NAME = "com.termux"` → `TERMUX_PACKAGE_NAME = "com.soul.terminal"`
</action>
<acceptance_criteria>
- [ ] grep -q 'TERMUX_APP_NAME = "SOUL Terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
- [ ] grep -q 'TERMUX_PACKAGE_NAME = "com.soul.terminal"' termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java
- [ ] No other occurrences of `= "com.termux"` on the TERMUX_PACKAGE_NAME line
</acceptance_criteria>
</task>

<task id="2">
<title>Update app/build.gradle — applicationId, versioning, APK names</title>
<read_first>
- app/build.gradle
</read_first>
<action>
1. Change line 46: `versionCode 118` → `versionCode 1`
2. Change line 47: `versionName "0.118.0"` → `versionName "1.0.0"`
3. Change line 54: `manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.termux"` → `"com.soul.terminal"`
4. Change line 55: `manifestPlaceholders.TERMUX_APP_NAME = "Termux"` → `"SOUL Terminal"`
5. Change lines 135 and 138: `"termux-app_"` → `"soul-terminal_"` (both debug and release outputFileName)
6. DO NOT change `namespace "com.termux"` on line 16
7. Add release signing config after the debug signing config (line 87):
```groovy
release {
    storeFile file('release.jks')
    keyAlias System.getenv('KEY_ALIAS') ?: ''
    storePassword System.getenv('STORE_PASSWORD') ?: ''
    keyPassword System.getenv('KEY_PASSWORD') ?: ''
}
```
8. In buildTypes.release block (line 90-94), add: `signingConfig signingConfigs.release`
9. Update desugar_jdk_libs dependency (line 151): `1.1.5` → `2.1.3`
</action>
<acceptance_criteria>
- [ ] grep -qP 'versionCode 1\s*$' app/build.gradle (exact match, not 118)
- [ ] grep -q 'versionName "1.0.0"' app/build.gradle
- [ ] grep -q 'TERMUX_PACKAGE_NAME = "com.soul.terminal"' app/build.gradle
- [ ] grep -q 'TERMUX_APP_NAME = "SOUL Terminal"' app/build.gradle
- [ ] grep -q 'soul-terminal_' app/build.gradle
- [ ] ! grep -q 'termux-app_' app/build.gradle (no old APK prefix remaining)
- [ ] grep -q 'namespace "com.termux"' app/build.gradle (namespace unchanged)
- [ ] grep -q 'signingConfigs.release' app/build.gradle
- [ ] grep -q 'desugar_jdk_libs:2.1.3' app/build.gradle
</acceptance_criteria>
</task>

<task id="3">
<title>Update gradle.properties — SDK versions</title>
<read_first>
- gradle.properties
</read_first>
<action>
1. Change `minSdkVersion=21` → `minSdkVersion=24`
2. Change `targetSdkVersion=28` → `targetSdkVersion=34`
</action>
<acceptance_criteria>
- [ ] grep -q 'minSdkVersion=24' gradle.properties
- [ ] grep -q 'targetSdkVersion=34' gradle.properties
</acceptance_criteria>
</task>

<task id="4">
<title>Update app/src/main/res/values/strings.xml entities</title>
<read_first>
- app/src/main/res/values/strings.xml
</read_first>
<action>
1. Change line 4: `<!ENTITY TERMUX_PACKAGE_NAME "com.termux">` → `<!ENTITY TERMUX_PACKAGE_NAME "com.soul.terminal">`
2. Change line 5: `<!ENTITY TERMUX_APP_NAME "Termux">` → `<!ENTITY TERMUX_APP_NAME "SOUL Terminal">`
</action>
<acceptance_criteria>
- [ ] grep -q 'TERMUX_PACKAGE_NAME "com.soul.terminal"' app/src/main/res/values/strings.xml
- [ ] grep -q 'TERMUX_APP_NAME "SOUL Terminal"' app/src/main/res/values/strings.xml
</acceptance_criteria>
</task>

<task id="5">
<title>Update termux-shared/src/main/res/values/strings.xml entities</title>
<read_first>
- termux-shared/src/main/res/values/strings.xml
</read_first>
<action>
1. Change line 4: `<!ENTITY TERMUX_PACKAGE_NAME "com.termux">` → `<!ENTITY TERMUX_PACKAGE_NAME "com.soul.terminal">`
2. Change line 5: `<!ENTITY TERMUX_APP_NAME "Termux">` → `<!ENTITY TERMUX_APP_NAME "SOUL Terminal">`
3. Change line 12: `<!ENTITY TERMUX_PREFIX_DIR_PATH "/data/data/com.termux/files/usr">` → `<!ENTITY TERMUX_PREFIX_DIR_PATH "/data/data/com.soul.terminal/files/usr">`
</action>
<acceptance_criteria>
- [ ] grep -q 'TERMUX_PACKAGE_NAME "com.soul.terminal"' termux-shared/src/main/res/values/strings.xml
- [ ] grep -q 'TERMUX_APP_NAME "SOUL Terminal"' termux-shared/src/main/res/values/strings.xml
- [ ] grep -q 'TERMUX_PREFIX_DIR_PATH "/data/data/com.soul.terminal/files/usr"' termux-shared/src/main/res/values/strings.xml
</acceptance_criteria>
</task>

<task id="6">
<title>Update shortcuts.xml targetPackage</title>
<read_first>
- app/src/main/res/xml/shortcuts.xml
</read_first>
<action>
Replace all 3 occurrences of `android:targetPackage="com.termux"` with `android:targetPackage="com.soul.terminal"` (lines 21, 35, 49).
DO NOT change `android:targetClass` values — those are Java class names.
</action>
<acceptance_criteria>
- [ ] grep -c 'targetPackage="com.soul.terminal"' app/src/main/res/xml/shortcuts.xml returns 3
- [ ] grep -c 'targetPackage="com.termux"' app/src/main/res/xml/shortcuts.xml returns 0
- [ ] grep -q 'targetClass="com.termux.app.TermuxActivity"' app/src/main/res/xml/shortcuts.xml (class names unchanged)
</acceptance_criteria>
</task>

<task id="7">
<title>Remove sharedUserId from AndroidManifest.xml</title>
<read_first>
- app/src/main/AndroidManifest.xml
</read_first>
<action>
1. Remove `android:sharedUserId="${TERMUX_PACKAGE_NAME}"` from line 5 of the `<manifest>` tag
2. Remove `android:sharedUserLabel="@string/shared_user_label"` from line 6 of the `<manifest>` tag
</action>
<acceptance_criteria>
- [ ] grep -c 'sharedUserId' app/src/main/AndroidManifest.xml returns 0
- [ ] grep -c 'sharedUserLabel' app/src/main/AndroidManifest.xml returns 0
</acceptance_criteria>
</task>

<task id="8">
<title>Add foregroundServiceType to TermuxService in manifest</title>
<read_first>
- app/src/main/AndroidManifest.xml
</read_first>
<action>
1. Change the TermuxService declaration (around line 196-198) from:
```xml
<service
    android:name=".app.TermuxService"
    android:exported="false" />
```
to:
```xml
<service
    android:name=".app.TermuxService"
    android:exported="false"
    android:foregroundServiceType="specialUse" />
```

2. Add these permissions before the existing `<permission>` block (around line 15):
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```
</action>
<acceptance_criteria>
- [ ] grep -q 'foregroundServiceType="specialUse"' app/src/main/AndroidManifest.xml
- [ ] grep -q 'FOREGROUND_SERVICE_SPECIAL_USE' app/src/main/AndroidManifest.xml
- [ ] grep -q 'POST_NOTIFICATIONS' app/src/main/AndroidManifest.xml
</acceptance_criteria>
</task>

<task id="9">
<title>Fix PendingIntent mutability flags in TermuxService.java</title>
<read_first>
- app/src/main/java/com/termux/app/TermuxService.java
</read_first>
<action>
In TermuxService.java, find lines 787, 830, and 838 which create PendingIntents with flag `0`:
- `PendingIntent.getActivity(this, 0, notificationIntent, 0)` → `PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)`
- `PendingIntent.getService(this, 0, exitIntent, 0)` → `PendingIntent.getService(this, 0, exitIntent, PendingIntent.FLAG_IMMUTABLE)`
- `PendingIntent.getService(this, 0, toggleWakeLockIntent, 0)` → `PendingIntent.getService(this, 0, toggleWakeLockIntent, PendingIntent.FLAG_IMMUTABLE)`
</action>
<acceptance_criteria>
- [ ] grep -c 'FLAG_IMMUTABLE' app/src/main/java/com/termux/app/TermuxService.java returns at least 3
- [ ] grep -c 'PendingIntent.get.*\, 0)' app/src/main/java/com/termux/app/TermuxService.java returns 0
</acceptance_criteria>
</task>

<task id="10">
<title>Fix PendingIntent mutability flags in termux-shared library</title>
<read_first>
- termux-shared/src/main/java/com/termux/shared/activities/ReportActivity.java
- termux-shared/src/main/java/com/termux/shared/shell/command/result/ResultConfig.java
- termux-shared/src/main/java/com/termux/shared/shell/command/result/ResultSender.java
- termux-shared/src/main/java/com/termux/shared/termux/crash/TermuxCrashUtils.java
- termux-shared/src/main/java/com/termux/shared/termux/plugins/TermuxPluginUtils.java
</read_first>
<action>
In each file listed above, find all `PendingIntent.get*()` calls that use flag `0` and replace with `PendingIntent.FLAG_IMMUTABLE`. If a call already uses FLAG_IMMUTABLE or FLAG_MUTABLE, leave it unchanged.
</action>
<acceptance_criteria>
- [ ] grep -rn 'PendingIntent.get.*\, 0)' termux-shared/src/main/java/ returns no results
- [ ] test $(grep -c 'FLAG_IMMUTABLE' termux-shared/src/main/java/com/termux/shared/activities/ReportActivity.java) -ge 1
- [ ] test $(grep -c 'FLAG_IMMUTABLE' termux-shared/src/main/java/com/termux/shared/shell/command/result/ResultConfig.java) -ge 1
- [ ] test $(grep -c 'FLAG_IMMUTABLE' termux-shared/src/main/java/com/termux/shared/shell/command/result/ResultSender.java) -ge 1
- [ ] test $(grep -c 'FLAG_IMMUTABLE' termux-shared/src/main/java/com/termux/shared/termux/crash/TermuxCrashUtils.java) -ge 1
- [ ] test $(grep -c 'FLAG_IMMUTABLE' termux-shared/src/main/java/com/termux/shared/termux/plugins/TermuxPluginUtils.java) -ge 1
</acceptance_criteria>
</task>

</tasks>

<verification>
1. `grep -r 'com\.termux"' app/build.gradle` should only match the `namespace` line, not manifestPlaceholders
2. `grep -r 'com\.termux"' app/src/main/res/xml/shortcuts.xml` should return 0 matches for targetPackage (only targetClass)
3. `grep -rn 'PendingIntent.get.*\, 0)' app/src/main/java/ termux-shared/src/main/java/` should return no results
4. `grep -q 'sharedUserId' app/src/main/AndroidManifest.xml` should fail (exit code 1)
5. CI build should compile successfully with targetSdk 34
</verification>

<must_haves>
- applicationId is `com.soul.terminal` (via manifestPlaceholders)
- App name is "SOUL Terminal" everywhere (TermuxConstants, strings.xml entities, manifestPlaceholders)
- Java namespace `com.termux` is UNCHANGED in all build.gradle files
- sharedUserId is completely removed from AndroidManifest.xml
- targetSdk is 34, minSdk is 24
- foregroundServiceType="specialUse" on TermuxService
- POST_NOTIFICATIONS and FOREGROUND_SERVICE_SPECIAL_USE permissions declared
- All PendingIntent calls use FLAG_IMMUTABLE instead of 0
- APK output files named `soul-terminal_*` instead of `termux-app_*`
- Version is 1.0.0 (code 1)
- Release signing config present in build.gradle
</must_haves>
