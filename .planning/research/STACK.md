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
