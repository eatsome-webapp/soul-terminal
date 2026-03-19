---
phase: 3
plan: "03-A"
title: "Gradle/AGP Upgrade + Kotlin Plugin"
wave: 1
depends_on: []
files_modified:
  - build.gradle
  - app/build.gradle
  - gradle/wrapper/gradle-wrapper.properties
  - gradle.properties
  - app/src/main/res/values/styles.xml
requirements_addressed: []  # Infrastructure prerequisite — enables FLUT-02..05 (covered by 03-C)
autonomous: true
---

# Plan 03-A: Gradle/AGP Upgrade + Kotlin Plugin

<objective>
Upgrade AGP from 4.2.2 to 8.3.2, Gradle from 7.2 to 8.5, add Kotlin Gradle plugin, migrate deprecated Gradle DSL, upgrade to Java 17 source compatibility, and define AppCompat-based Theme.Termux styles — all prerequisites for Flutter embedding.
</objective>

<task id="03-A-01">
<title>Upgrade Gradle wrapper to 8.5</title>
<read_first>
- gradle/wrapper/gradle-wrapper.properties
</read_first>
<action>
In `gradle/wrapper/gradle-wrapper.properties`, change:
```
distributionUrl=https\://services.gradle.org/distributions/gradle-7.2-all.zip
```
to:
```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
```
</action>
<acceptance_criteria>
- File `gradle/wrapper/gradle-wrapper.properties` contains the string `gradle-8.5-all.zip`
- File does NOT contain `gradle-7.2`
</acceptance_criteria>
</task>

<task id="03-A-02">
<title>Upgrade AGP to 8.3.2 and add Kotlin plugin in root build.gradle</title>
<read_first>
- build.gradle
</read_first>
<action>
In `build.gradle` (root), change the `buildscript.dependencies` block:

Replace:
```groovy
classpath 'com.android.tools.build:gradle:4.2.2'
```
With:
```groovy
classpath 'com.android.tools.build:gradle:8.3.2'
classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22'
```
</action>
<acceptance_criteria>
- `build.gradle` contains the string `com.android.tools.build:gradle:8.3.2`
- `build.gradle` contains the string `org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22`
- `build.gradle` does NOT contain `gradle:4.2.2`
</acceptance_criteria>
</task>

<task id="03-A-03">
<title>Add Kotlin Android plugin to app/build.gradle</title>
<read_first>
- app/build.gradle
</read_first>
<action>
In `app/build.gradle`, add the Kotlin plugin to the `plugins` block:

Replace:
```groovy
plugins {
    id "com.android.application"
}
```
With:
```groovy
plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
}
```
</action>
<acceptance_criteria>
- `app/build.gradle` contains the line `id "org.jetbrains.kotlin.android"`
</acceptance_criteria>
</task>

<task id="03-A-04">
<title>Upgrade Java source/target compatibility to 17</title>
<read_first>
- app/build.gradle
</read_first>
<action>
In `app/build.gradle`, inside the `compileOptions` block, replace:
```groovy
sourceCompatibility JavaVersion.VERSION_1_8
targetCompatibility JavaVersion.VERSION_1_8
```
With:
```groovy
sourceCompatibility JavaVersion.VERSION_17
targetCompatibility JavaVersion.VERSION_17
```
</action>
<acceptance_criteria>
- `app/build.gradle` contains the string `JavaVersion.VERSION_17` (at least twice — source and target)
- `app/build.gradle` does NOT contain `VERSION_1_8`
</acceptance_criteria>
</task>

<task id="03-A-05">
<title>Migrate deprecated lintOptions to lint block</title>
<read_first>
- app/build.gradle
</read_first>
<action>
In `app/build.gradle`, inside the `android` block, replace:
```groovy
lintOptions {
    disable 'ProtectedPermissions'
}
```
With:
```groovy
lint {
    disable 'ProtectedPermissions'
}
```
</action>
<acceptance_criteria>
- `app/build.gradle` contains the block `lint {` followed by `disable 'ProtectedPermissions'`
- `app/build.gradle` does NOT contain `lintOptions`
</acceptance_criteria>
</task>

<task id="03-A-06">
<title>Migrate deprecated packagingOptions to packaging block</title>
<read_first>
- app/build.gradle
</read_first>
<action>
In `app/build.gradle`, inside the `android` block, replace:
```groovy
packagingOptions {
    jniLibs {
        useLegacyPackaging true
    }
}
```
With:
```groovy
packaging {
    jniLibs {
        useLegacyPackaging true
    }
}
```
</action>
<acceptance_criteria>
- `app/build.gradle` contains `packaging {` followed by `jniLibs {`
- `app/build.gradle` does NOT contain `packagingOptions`
</acceptance_criteria>
</task>

<task id="03-A-07">
<title>Add namespace to android block in app/build.gradle</title>
<read_first>
- app/build.gradle
- app/src/main/AndroidManifest.xml
</read_first>
<action>
AGP 8.x requires the `namespace` property in the `android` block instead of the `package` attribute in AndroidManifest.xml.

In `app/build.gradle`, add `namespace` as the first line inside the `android` block:
```groovy
android {
    namespace "com.termux"
    compileSdkVersion project.properties.compileSdkVersion.toInteger()
    ...
```

Then in `app/src/main/AndroidManifest.xml`, remove the `package="com.termux"` attribute from the `<manifest>` tag (if present). The `package` attribute is now determined by the `namespace` in build.gradle.

Also check `termux-shared/build.gradle`, `terminal-emulator/build.gradle`, and `terminal-view/build.gradle` — each needs a `namespace` property matching their manifest package. Add:
- `termux-shared/build.gradle`: `namespace "com.termux.shared"`
- `terminal-emulator/build.gradle`: `namespace "com.termux.terminal"`
- `terminal-view/build.gradle`: `namespace "com.termux.view"`

Read each of these 3 build.gradle files and their AndroidManifest.xml files first to confirm the correct package names, then add the `namespace` line inside the `android` block of each.
</action>
<acceptance_criteria>
- `app/build.gradle` contains the string `namespace "com.termux"`
- `termux-shared/build.gradle` contains a `namespace` declaration
- `terminal-emulator/build.gradle` contains a `namespace` declaration
- `terminal-view/build.gradle` contains a `namespace` declaration
</acceptance_criteria>
</task>

<task id="03-A-08">
<title>Define Theme.Termux and Theme.Termux_Black as AppCompat styles</title>
<read_first>
- app/src/main/res/values/styles.xml
- app/src/main/res/values/colors.xml
- app/src/main/java/com/termux/app/TermuxActivity.java (lines 407-413 for setActivityTheme)
</read_first>
<action>
TermuxActivity references `R.style.Theme_Termux` and `R.style.Theme_Termux_Black` in `setActivityTheme()`. AndroidManifest.xml references `@style/Theme.Termux`. These styles must exist and be AppCompat-based for FragmentActivity to work.

In `app/src/main/res/values/styles.xml`, add two new styles (keep the existing `AppTheme`):

```xml
<!-- Terminal activity themes (must be AppCompat-based for FragmentActivity) -->
<style name="Theme.Termux" parent="Theme.AppCompat.NoActionBar">
    <item name="colorPrimary">@color/soul_primary</item>
    <item name="colorPrimaryDark">@color/soul_primary_dark</item>
    <item name="colorAccent">@color/soul_accent</item>
    <item name="android:windowBackground">@color/soul_background</item>
    <item name="android:statusBarColor">@color/soul_primary_dark</item>
    <item name="android:navigationBarColor">@color/soul_background</item>
</style>

<style name="Theme.Termux_Black" parent="Theme.AppCompat.NoActionBar">
    <item name="colorPrimary">@color/soul_primary</item>
    <item name="colorPrimaryDark">@android:color/black</item>
    <item name="colorAccent">@color/soul_accent</item>
    <item name="android:windowBackground">@android:color/black</item>
    <item name="android:statusBarColor">@android:color/black</item>
    <item name="android:navigationBarColor">@android:color/black</item>
</style>
```

Note: In XML resources the dot-notation `Theme.Termux` maps to `R.style.Theme_Termux` in Java. The style name in XML must be `Theme.Termux` (with dot), not `Theme_Termux`.
</action>
<acceptance_criteria>
- `app/src/main/res/values/styles.xml` contains `<style name="Theme.Termux" parent="Theme.AppCompat.NoActionBar">`
- `app/src/main/res/values/styles.xml` contains `<style name="Theme.Termux_Black" parent="Theme.AppCompat.NoActionBar">`
- Both styles contain `colorPrimary`, `colorAccent`, `android:windowBackground` items
</acceptance_criteria>
</task>

<task id="03-A-09">
<title>Add AndroidX fragment and appcompat dependencies</title>
<read_first>
- app/build.gradle
</read_first>
<action>
In `app/build.gradle`, inside the `android { dependencies { ... } }` block, add these two dependencies (needed for FragmentActivity in Plan 03-C, but adding now so the AGP upgrade build can validate them):

```groovy
implementation "androidx.appcompat:appcompat:1.6.1"
implementation "androidx.fragment:fragment:1.6.2"
```

Add them after the existing `androidx.viewpager:viewpager:1.0.0` line.
</action>
<acceptance_criteria>
- `app/build.gradle` contains the string `androidx.appcompat:appcompat:1.6.1`
- `app/build.gradle` contains the string `androidx.fragment:fragment:1.6.2`
</acceptance_criteria>
</task>

<task id="03-A-10">
<title>Add android.nonTransitiveRClass=true to gradle.properties</title>
<read_first>
- gradle.properties
</read_first>
<action>
AGP 8.x defaults to non-transitive R classes. Add this property to `gradle.properties` to make the setting explicit and avoid build warnings:

```
android.nonTransitiveRClass=false
```

Set to `false` because the existing code uses `com.termux.R` to access resources from submodules (e.g., `com.termux.R.style.Theme_Termux` in the app module references styles that may be in termux-shared). Setting to `true` would require updating all R class imports across the codebase.

Also add:
```
android.defaults.buildfeatures.buildconfig=true
```

This preserves the BuildConfig generation behavior that AGP 8.x disables by default.
</action>
<acceptance_criteria>
- `gradle.properties` contains the string `android.nonTransitiveRClass=false`
- `gradle.properties` contains the string `android.defaults.buildfeatures.buildconfig=true`
</acceptance_criteria>
</task>

<verification>
## Verification Criteria
- CI build (`./gradlew assembleDebug`) succeeds with AGP 8.3.2 + Gradle 8.5
- No `lintOptions` or `packagingOptions` deprecation errors
- Java 17 source compatibility compiles without errors
- `Theme.Termux` and `Theme.Termux_Black` are defined as AppCompat descendants
- Kotlin Gradle plugin is present (no Kotlin source files needed yet, just the plugin for Flutter embedding)
- All 4 modules (app, termux-shared, terminal-emulator, terminal-view) have `namespace` set
</verification>

<must_haves>
- AGP upgraded from 4.2.2 to 8.3.2
- Gradle wrapper upgraded from 7.2 to 8.5
- Kotlin Gradle plugin 1.9.22 added
- Java 17 source/target compatibility
- Deprecated Gradle DSL migrated (lint, packaging)
- Namespace set in all module build.gradle files
- Theme.Termux and Theme.Termux_Black defined as AppCompat.NoActionBar descendants
- AndroidX appcompat and fragment dependencies added
</must_haves>
