# Stack Research: SOUL Terminal

*Research date: 2026-03-19*
*Context: Termux fork (Java/Android) with Flutter module embedding via FlutterFragment*

## Current State (Baseline from Fork)

| Component | Current | Notes |
|-----------|---------|-------|
| AGP | 8.13.2 | Already recent |
| Gradle | 9.2.1 | Already recent |
| compileSdk | 36 | Current |
| targetSdk | 28 | **Must raise** — Play Store requires 34+ |
| minSdk | 21 | Keep for now (Termux compatibility) |
| NDK | 29.0.14206865 | Latest stable (r29) |
| Java compat | 1.8 | Keep — Termux codebase is Java, not Kotlin |
| desugar_jdk_libs | 1.1.5 | **Outdated** — upgrade to 2.1.x |

## Recommended Stack

### Build System

| Component | Version | Rationale | Confidence |
|-----------|---------|-----------|------------|
| **AGP** | 8.13.2 (keep) | Already in use. AGP 9.x exists (9.1.0, March 2026) but requires Gradle 9.3.1 and introduces breaking changes. Upgrade later when stable and Flutter add-to-app supports it. | **High** |
| **Gradle** | 9.2.1 (keep) | Compatible with AGP 8.13.2. AGP 9.x would need 9.3.1+, defer that upgrade. | **High** |
| **compileSdk** | 36 (keep) | Current API level, already set. | **High** |
| **targetSdk** | 34 (raise from 28) | Play Store requires targetSdk 34+ since Aug 2024. Termux upstream stays at 28 intentionally (to avoid restricted file access), but SOUL Terminal needs Play Store distribution. Raise to 34, handle scoped storage. | **High** |
| **minSdk** | 24 (raise from 21) | Flutter requires minSdk 21, but raising to 24 enables Java 8+ desugaring without workarounds and drops <1% device share. Also aligns with Material Components 1.13+ which raised minSdk to 23. | **Medium** |
| **NDK** | 29.0.14206865 (keep) | Latest stable r29 (Oct 2025). Already set correctly. | **High** |
| **desugar_jdk_libs** | 2.1.3 | Current is 1.1.5 — ancient. 2.1.x adds java.time, java.util.stream support. Required if raising targetSdk. | **High** |

### Flutter Module Embedding

| Component | Version | Rationale | Confidence |
|-----------|---------|-----------|------------|
| **Flutter SDK** | 3.41.4 | Already chosen. Latest stable (March 2026). Has mature add-to-app support. | **High** |
| **Dart SDK** | 3.11.1 | Bundled with Flutter 3.41.4. | **High** |
| **Embedding pattern** | FlutterFragment (add-to-app) | Correct choice per PROJECT.md. FlutterFragment sits inside existing Activity, coexists with terminal View. No need for FlutterActivity (takes over full screen) or FlutterView (requires manual lifecycle bridging). | **High** |
| **Flutter module type** | `flutter create --template module` | Standard add-to-app pattern. Creates `.android/` directory with AAR build support. Host app includes via `settings.gradle` source dependency or AAR. | **High** |
| **Integration method** | Source dependency (settings.gradle) | Preferred over AAR for development — enables hot reload. AAR for CI release builds. Add `include ':flutter'` + `apply from: '../soul_flutter_module/.android/include_flutter.groovy'` to settings.gradle. | **High** |
| **FlutterEngine caching** | Pre-warmed FlutterEngine in Application class | Start FlutterEngine in `TermuxApplication.onCreate()`, cache via `FlutterEngineCache`. Eliminates cold-start delay when opening Flutter UI. | **High** |
| **Pigeon** | 26.2.x | Type-safe Flutter <-> Kotlin/Java bridge. Replaces manual MethodChannel boilerplate. Current latest is 26.2.3. Generates Kotlin/Java host API + Dart client API. | **High** |

### Android Dependencies (app/build.gradle)

| Library | Current | Recommended | Rationale | Confidence |
|---------|---------|-------------|-----------|------------|
| `androidx.core:core` | 1.13.1 | **1.18.0** | Released March 2026. Bug fixes, new APIs for Android 15+. | **High** |
| `androidx.annotation` | 1.9.0 | **1.9.0** (keep) | Stable, no urgent update. | **High** |
| `androidx.drawerlayout` | 1.2.0 | **1.2.0** (keep) | Stable, unchanged. | **High** |
| `androidx.preference` | 1.2.1 | **1.2.1** (keep) | Stable. | **High** |
| `androidx.viewpager` | 1.0.0 | **1.0.0** (keep) | Only if still used. Consider ViewPager2 if rebuilding UI. | **Low** |
| `material` | 1.12.0 | **1.12.0** (keep) | Latest stable. 1.13.x requires minSdk 23, 1.14.x is alpha. Stick with 1.12.0 until 1.13 is stable and minSdk is raised. | **High** |
| `markwon` | 4.6.2 | **4.6.2** (keep) | Last release, project is unmaintained but stable. | **High** |
| `guava` | 24.1-jre | **33.4.0-android** | Current is 8 years old. Use `-android` variant, not `-jre`, for Android projects. Fixes security issues. | **Medium** |
| `desugar_jdk_libs` | 1.1.5 | **2.1.3** | Major upgrade. Enables modern java.time, streams on older devices. | **High** |
| `robolectric` | 4.10 | **4.14.x** | If running local tests. Latest stable. | **Low** |
| `junit` | 4.13.2 | **4.13.2** (keep) | Stable, no update needed. | **High** |

### Flutter Module Dependencies (pubspec.yaml — to be created)

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| `flutter_riverpod` | ^2.6.x | State management, consistent with SOUL app | **High** |
| `riverpod_annotation` | ^2.6.x | Code generation for Riverpod | **High** |
| `pigeon` | ^26.2.x | Type-safe platform channel generation (dev dependency) | **High** |
| `logger` | ^2.5.x | Structured logging, no print() | **High** |
| `drift` | ^2.24.x | SQLite ORM (if sharing DB with terminal) | **Medium** |
| `freezed` | ^3.0.x | Immutable data classes (dev dependency) | **Medium** |
| `build_runner` | ^2.4.x | Code generation runner (dev dependency) | **High** |

## CI/CD Pipeline

| Component | Choice | Rationale | Confidence |
|-----------|--------|-----------|------------|
| **CI runner** | GitHub Actions (ubuntu-latest) | Already established. Free for public repos. | **High** |
| **Flutter in CI** | `subosito/flutter-action@v2` | Standard GH Action for Flutter, supports specifying version. | **High** |
| **Combined build** | Two-stage: build Flutter module AAR first, then Gradle assembleRelease | Flutter module must produce AAR before host app compiles. Use `flutter build aar` then `./gradlew assembleRelease`. | **High** |
| **Signing** | GitHub Secrets for keystore | Never commit real keystore. Use base64-encoded keystore in secrets. | **High** |

## What NOT to Use

| Technology | Why Not |
|------------|---------|
| **AGP 9.x** | Too new (March 2026). Breaking changes, requires Gradle 9.3.1+. Flutter add-to-app compatibility not yet verified. Wait 6+ months. |
| **Kotlin for host app** | Termux codebase is 100% Java. Converting to Kotlin adds massive merge-conflict risk with upstream. Flutter module can be Kotlin, but host stays Java. |
| **Jetpack Compose** | Host app uses Android Views (XML). Adding Compose to a View-based terminal app adds 3MB+ to APK for no gain. Flutter handles the modern UI layer. |
| **FlutterActivity** | Takes over full Activity — can't coexist with terminal View in same screen. FlutterFragment is correct. |
| **FlutterView (raw)** | Requires manual lifecycle bridging (onResume, onPause, onDestroy, back press). FlutterFragment handles all this automatically. |
| **PlatformView for terminal** | Performance killer. Terminal rendering must be native Android View, not a Flutter widget wrapping a native view. Decided in PROJECT.md. |
| **MethodChannel (manual)** | Pigeon generates type-safe code, eliminates string-based channel names and manual serialization. No reason for manual MethodChannel. |
| **Material 1.13+/1.14** | 1.13 raised minSdk to 23, 1.14 is alpha. No benefit for a terminal app that barely uses Material components. |
| **AccessibilityService** | Banned from Play Store since Jan 2026. Explicitly forbidden in CLAUDE.md. |
| **WebView for UI** | Adds overhead, no offline guarantee, bad UX for a terminal companion. Flutter is the better choice. |
| **Room (for Flutter module)** | Use Drift — already chosen for SOUL ecosystem. Room is Java/Kotlin only. |

## Architecture: How the Pieces Fit Together

```
┌─────────────────────────────────────────────┐
│ SOUL Terminal APK                            │
│                                             │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │ Termux Host App │  │ Flutter Module   │  │
│  │ (Java, Android) │  │ (Dart, Riverpod) │  │
│  │                 │  │                  │  │
│  │ • Terminal emu  │  │ • SOUL AI brain  │  │
│  │ • Shell/PTY     │◄─►  • Chat UI       │  │
│  │ • File system   │  │ • Memory layer   │  │
│  │ • Bootstrap     │  │ • Decision log   │  │
│  │                 │  │                  │  │
│  └────────┬────────┘  └────────┬─────────┘  │
│           │      Pigeon        │            │
│           └────────────────────┘            │
│                                             │
│  FlutterFragment in TermuxActivity          │
│  (drawer, tab, or overlay — TBD)            │
└─────────────────────────────────────────────┘
```

## Key Decisions Still Needed

1. **targetSdk 34 vs 35**: 34 is minimum for Play Store. 35 adds edge-to-edge enforcement. Recommendation: start with 34, upgrade to 35 when UI is ready.
2. **minSdk 21 vs 24**: Raising to 24 simplifies desugaring and drops negligible device share, but diverges from Termux upstream. Decision required.
3. **Flutter module location**: Sibling directory (`../soul_flutter_module/`) or subdirectory (`flutter_module/`)? Sibling is standard for add-to-app, subdirectory is simpler for mono-repo.
4. **Material 1.12 vs 1.13**: Depends on minSdk decision. If minSdk goes to 24, Material 1.13 becomes viable.
5. **Guava upgrade**: Low priority but 24.1-jre is ancient. Schedule for a separate PR to avoid blast radius.

## Confidence Summary

| Category | Confidence |
|----------|------------|
| Build system (AGP, Gradle, SDK versions) | **High** — verified against official release notes |
| Flutter embedding pattern (FlutterFragment + Pigeon) | **High** — official docs, proven pattern |
| AndroidX dependency versions | **High** — verified against Maven Central |
| Flutter module dependencies | **Medium** — versions depend on Flutter 3.41 pub resolution |
| CI/CD pipeline | **High** — established pattern |
| targetSdk/minSdk recommendations | **Medium** — trade-offs with Termux upstream compatibility |

---

# Stack Research: v1.1 New Features

**Domain:** Android terminal emulator with embedded Flutter AI interface
**Researched:** 2026-03-20
**Confidence:** HIGH

This section covers only the NEW stack additions required for v1.1 features. Existing validated capabilities (Termux fork, FlutterFragment, Pigeon, CI/CD, Kitty protocol, AGP/Java/Kotlin versions) are NOT repeated.

## Recommended Stack — v1.1 Additions

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| `BottomSheetBehavior` (Material) | included in `material:1.12.0` | Persistent bottom sheet for terminal-as-sheet pattern | Part of existing Material dependency — zero added cost. Handles three states: collapsed (peek), half-expanded, and fully expanded. `BottomSheetCallback` exposes slide offset for animations. |
| `CoordinatorLayout` (AndroidX) | included in `material:1.12.0` | Container that orchestrates BottomSheetBehavior with FlutterFragment | Already transitively included via Material. The FlutterFragment goes above, terminal container is the sheet child with `app:layout_behavior="@string/bottom_sheet_behavior"`. |
| `EventChannel` (Flutter embedding) | bundled with Flutter engine | High-throughput terminal output streaming from Java to Dart | Native Flutter platform channel. One active stream per channel. For terminal output: Java side calls `eventSink.success(chunk)` from the PTY read loop. Dart side listens via `receiveBroadcastStream()`. No extra dependency. |
| `ViewPager2` + `TabLayoutMediator` | `androidx.viewpager2:viewpager2:1.1.0` + included in `material:1.12.0` | Session tab bar in bottom sheet | ViewPager2 supersedes ViewPager (RecyclerView-backed, fixes diffing and lifecycle). `TabLayoutMediator` is the correct 2025 API — `setupWithViewPager()` is deprecated. Already have `viewpager:1.0.0`; upgrade to ViewPager2. |
| Android Keystore + DataStore | `androidx.datastore:datastore-preferences:1.1.5` (stable, March 2025) | Secure API key storage | `EncryptedSharedPreferences` is deprecated as of security-crypto 1.1.0-alpha07 (2025). Modern pattern: DataStore Preferences for persistence + Android Keystore for AES-GCM encryption of sensitive values. No extra Tink dependency needed for simple key-value API key storage — raw Keystore AES-GCM via `KeyGenerator` + `Cipher` is sufficient. |
| `HapticFeedbackConstants` | Android SDK (no dependency) | Haptic feedback on key press, sheet drag, confirmations | `view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)` is API 3+, no library needed. For richer patterns: `VibrationEffect.createPredefined(EFFECT_CLICK)` via `Vibrator` service is API 29+. Use predefined effects — they adapt per device. |
| `RenderEffect` (blur) | Android SDK API 31+ (no dependency) | Frosted-glass effect on bottom sheet handle or Flutter overlay | `view.setRenderEffect(RenderEffect.createBlurEffect(radius, radius, TileMode.CLAMP))`. Hardware-accelerated. minSdk 24, but `RenderEffect` requires API 31 — guard with `Build.VERSION.SDK_INT >= Build.VERSION_CODES.S`. For pre-API-31: semi-transparent background (alpha) as fallback. |
| `AccessibilityNodeInfoCompat` | included in `androidx.core:core:1.18.0` | TalkBack support for custom terminal View | Terminal view is a custom canvas-rendered `View`. Must override `onInitializeAccessibilityNodeInfo()` and set content descriptions. `ViewCompat.setAccessibilityDelegate()` is the compat path. No extra dependency beyond already-present `core`. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `androidx.viewpager2:viewpager2` | `1.1.0` | Session management tab bar | Add when implementing session tabs. Replaces existing `androidx.viewpager:viewpager:1.0.0` — keep both during transition, remove old once migrated. |
| `androidx.datastore:datastore-preferences` | `1.1.5` | API key + preferences persistence | Add when implementing onboarding (first-run detection) and API key entry. Stable release (March 2025). DataStore 1.2.x is alpha — stay on 1.1.5. |
| Google Tink (optional) | `com.google.crypto.tink:tink-android:1.20.0` | AES-GCM encryption wrapper for DataStore | Only needed if encrypting the entire DataStore file. For simple API key storage, raw Android Keystore is sufficient and adds no dependency. Add Tink only if the stored data volume warrants full-file encryption. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `AccessibilityScanner` (Google app) | Test TalkBack node info on device | Install from Play Store to validate content descriptions without running full TalkBack. Faster iteration than enabling TalkBack manually. |
| `Layout Inspector` (Android Studio) | Debug CoordinatorLayout + BottomSheetBehavior hierarchy | Verify FlutterFragment and BottomSheetBehavior child are correctly positioned. |
| Android Emulator API 31+ | Test `RenderEffect` blur | `RenderEffect` is API 31+. Pixel 6 emulator (API 33) is the minimum for realistic blur testing. Xiaomi 17 Ultra is API 35 — primary test device. |

## Installation (Gradle)

```groovy
// app/build.gradle — additions for v1.1
dependencies {
    // Session management — replaces androidx.viewpager:viewpager:1.0.0
    implementation "androidx.viewpager2:viewpager2:1.1.0"
    // TabLayoutMediator is bundled in material:1.12.0 (already present)

    // Secure storage for API keys and onboarding state
    implementation "androidx.datastore:datastore-preferences:1.1.5"

    // Optional: full-file encryption with Tink (only if needed)
    // implementation "com.google.crypto.tink:tink-android:1.20.0"

    // EventChannel, BottomSheetBehavior, CoordinatorLayout, HapticFeedback,
    // AccessibilityNodeInfoCompat, RenderEffect — all bundled in existing deps:
    //   material:1.12.0, androidx.core:core:1.18.0, Flutter engine JAR
    // No additional dependencies needed.
}
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|------------|------------------------|
| `BottomSheetBehavior` (persistent) | `BottomSheetDialogFragment` (modal) | Modal variant if terminal must block the Flutter UI when open. For terminal-as-sheet-alongside-Flutter, persistent is correct. |
| `EventChannel` | Pigeon `@FlutterApi` (streaming via Pigeon) | Pigeon-generated streaming is cleaner type-safe but adds codegen overhead. `EventChannel` is lower-level but directly supports high-throughput `byte[]` streams without serialization cost. For raw terminal output, `EventChannel` wins on throughput. |
| `ViewPager2` + `TabLayoutMediator` | Custom `RecyclerView` tab strip | Use custom strip if tab design deviates significantly from Material or requires terminal-specific drag-to-close gestures. Adds implementation complexity. |
| Android Keystore (raw) | `EncryptedSharedPreferences` | Do not use — officially deprecated in security-crypto 1.1.0-alpha07 (2025). |
| Android Keystore (raw) | `DataStore` + Tink `AeadSerializer` | Use Tink only for full Proto DataStore file encryption. For simple key-value API key storage, raw Keystore is 50 lines and zero extra dependency. |
| `RenderEffect` (API 31+) + alpha fallback | `BlurView` third-party library | Use BlurView only if supporting API < 31 is critical and a blur effect (not alpha) is non-negotiable. Adds 100KB+, causes jank on older hardware. Not worth it for a dev terminal app. |
| `performHapticFeedback()` | `VibrationEffect.compose()` | Use VibrationEffect.compose() only for custom multi-primitive haptic sequences (API 30+). For terminal key feedback, `KEYBOARD_TAP` via `performHapticFeedback` is sufficient and respects user's haptic settings automatically. |
| `/proc/PID/cmdline` (direct file read) | `ActivityManager.getRunningAppProcesses()` | Use ActivityManager only to list own app's processes. For detecting which shell/program is running inside a Termux session, `/proc/PID/cmdline` is the only option — ActivityManager can't see child processes of the terminal PTY. Read via `new FileInputStream("/proc/" + pid + "/cmdline")`, split on null bytes. Works on all API levels for own child processes without root. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|------------|
| `EncryptedSharedPreferences` | Deprecated in AndroidX Security Crypto 1.1.0-alpha07 (2025). Google explicitly recommends migration away. | DataStore + Android Keystore AES-GCM |
| `RenderScript` (blur) | Deprecated since Android 12 (API 31). Removed in Android 14+ on some OEMs. | `RenderEffect.createBlurEffect()` (API 31+) with alpha fallback |
| `ViewPager` (v1) | Deprecated. No DiffUtil support, fragment lifecycle issues. Already present as `viewpager:1.0.0` — migrate away. | `ViewPager2:1.1.0` |
| `FLAG_IGNORE_GLOBAL_SETTING` (haptics) | Deprecated in API 33. Privileged apps only. Overriding user's haptic settings is bad UX for a terminal. | `performHapticFeedback(constant)` without flags |
| `setupWithViewPager()` | Deprecated API for linking TabLayout to ViewPager. | `TabLayoutMediator` |
| `AccessibilityService` | Banned from Play Store since January 2026. | `ViewCompat.setAccessibilityDelegate()` + `AccessibilityNodeInfoCompat` |
| Third-party blur libraries (BlurView, haze) | Compatibility shims that predate `RenderEffect`. Add APK weight, cause jank on low-end devices. | `RenderEffect` (API 31+) + semi-transparent background fallback |
| `Window.setBackgroundBlurRadius()` | Cross-window blur — blurs content of other apps behind the window. Not appropriate for blurring the terminal behind a sheet. | `view.setRenderEffect()` for in-window blur on the bottom sheet handle |

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|----------------|-------|
| `viewpager2:1.1.0` | `material:1.12.0` | `TabLayoutMediator` is in Material, not in viewpager2. Both required. |
| `datastore-preferences:1.1.5` | minSdk 21+ | Kotlin coroutines required in calling code — Flutter module uses Dart, so DataStore is on the Java/Kotlin host side only. |
| `RenderEffect` | API 31+ (Android 12) | Xiaomi 17 Ultra = API 35. Production safe with `Build.VERSION.SDK_INT >= 31` guard. |
| `VibrationEffect.createPredefined()` | API 29+ (Android 10) | All modern devices. Guard with `Build.VERSION.SDK_INT >= 29`. |
| `HapticFeedbackConstants.KEYBOARD_TAP` | API 3+ | No guard needed. |
| `EventChannel` | Flutter engine (any version) | Already bundled. EventChannel requires `FlutterPlugin.FlutterPluginBinding` context or `BinaryMessenger` from `FlutterEngine`. |
| `BottomSheetBehavior` | `CoordinatorLayout` required as parent | The FlutterFragment container view must be a direct child of `CoordinatorLayout`, not nested inside `LinearLayout` or `FrameLayout`. |
| `androidx.core:core:1.18.0` | compileSdk 36, minSdk 21+ | Contains `ViewCompat` for accessibility compat path. |

## Integration Notes

### BottomSheetBehavior + FlutterFragment

The layout structure for terminal-as-sheet:

```xml
<androidx.coordinatorlayout.widget.CoordinatorLayout>
    <!-- Flutter UI fills the top area -->
    <FrameLayout android:id="@+id/flutter_container"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <!-- Terminal is the persistent bottom sheet -->
    <FrameLayout android:id="@+id/terminal_container"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:layout_behavior="@string/bottom_sheet_behavior"
        app:behavior_peekHeight="56dp"
        app:behavior_hideable="false" />
</androidx.coordinatorlayout.widget.CoordinatorLayout>
```

The `FlutterFragment` is added to `flutter_container`. The existing `TerminalView` lives in `terminal_container`. `BottomSheetBehavior.from(terminalContainer)` retrieves the behavior for programmatic state control.

### EventChannel for Terminal Output

Terminal output volume can be high (Claude Code output, compiles). EventChannel handles this without back-pressure issues because:
- The PTY read loop runs on a background thread and calls `eventSink.success(data)` on the main thread via `Handler`
- Dart's stream buffering absorbs bursts
- For terminal output, send `byte[]` or `String` chunks — avoid sending individual bytes

The Pigeon bridge (`SoulBridge`) covers bidirectional control signals. EventChannel is additive for the output stream specifically — it can be higher throughput than Pigeon because it bypasses serialization overhead.

### /proc/PID/cmdline for Process Detection

Android 7.0+ restricts `/proc` access for other apps' processes. However, reading `/proc/PID/cmdline` for **own child processes** (the shell spawned by Termux's PTY) works without root on all API levels. The terminal session has the PID via `TerminalSession.getPid()`. Read the file, split on null bytes (cmdline uses null as separator), take `args[0]` as the process name.

### Secure API Key Storage Pattern

```java
// Android Keystore — no library needed
KeyGenerator keyGen = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");
keyGen.init(new KeyGenParameterSpec.Builder("soul_key",
    KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
    .build());
SecretKey key = keyGen.generateKey(); // stored in hardware-backed keystore
```

DataStore holds the encrypted blob; Keystore holds the key. The key never leaves secure hardware on supported devices (Xiaomi 17 Ultra has StrongBox).

## Sources

- Android Developers: BottomSheetBehavior API reference (2025-10-28)
- Android Developers: Create a bottom sheet (2025-07-31)
- Android Developers: CoordinatorLayout migration to Compose (explains View-side behavior)
- ProAndroidDev: "Goodbye EncryptedSharedPreferences: A 2026 Migration Guide" (Jay Patel, 2025-12-04)
- Medium: "EncryptedSharedPreferences is Deprecated" (MobileDev NK, 2025-08-29)
- AndroidX DataStore release page: stable 1.1.5 (April 2025), 1.2.1 alpha (March 2026)
- Google Tink setup docs: tink-android 1.20.0 (2025-04-23)
- Android AOSP: Window blurs API (source.android.com, 2025-12-02) — confirmed API 31+
- Medium: "Blurring the Lines — Android RenderEffects #1" (Chet Haase, Google)
- Android Developers: HapticFeedbackConstants API reference
- Android Developers: Haptics API reference (design principles table)
- Android Developers: Make custom views more accessible
- Android Developers: Create swipe views with tabs using ViewPager2
- ViewPager2:1.1.0 — stable (2024, last stable release per AndroidX)
- jaredrummler/AndroidProcesses: deprecated note confirms /proc access restricted for foreign processes since Android 7.0+
- Stack Overflow: "Is there a way to get current process name in Android" — confirmed own child processes readable
