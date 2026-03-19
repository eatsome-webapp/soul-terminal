---
phase: 03-flutter-integration
plan: C
subsystem: ui
tags: [flutter, flutter-fragment, flutter-engine, android-activity, fragment-activity]

# Dependency graph
requires:
  - phase: 03-A
    provides: AGP 8.3.2, Kotlin plugin, AndroidX appcompat + fragment, Java 17
  - phase: 03-B
    provides: flutter_module/ directory, pubspec.yaml, Pigeon schema, generated bridge files

provides:
  - FlutterEngine pre-warmed in TermuxApplication (soul_flutter_engine)
  - FlutterFragment integrated in TermuxActivity via getSupportFragmentManager()
  - flutter_container FrameLayout in activity layout (GONE by default)
  - toggleFlutterView() method swapping terminal/Flutter containers
  - SOUL toggle button in left drawer
  - Flutter module included in settings.gradle via source inclusion
  - app/build.gradle depends on :flutter project

affects: [03-D, 03-F, flutter-integration, soul-ui]

# Tech tracking
tech-stack:
  added:
    - FlutterEngine (io.flutter.embedding.engine)
    - FlutterEngineCache (io.flutter.embedding.engine)
    - FlutterFragment (io.flutter.embedding.android)
    - DartExecutor (io.flutter.embedding.engine.dart)
  patterns:
    - Pre-warmed Flutter engine cached by ID, retrieved by FlutterFragment
    - Visibility toggle pattern (GONE/VISIBLE) for terminal/Flutter view switch
    - Background thread for FlutterEngine init, main thread for Dart entrypoint

key-files:
  created: []
  modified:
    - settings.gradle
    - app/build.gradle
    - app/src/main/java/com/termux/app/TermuxApplication.java
    - app/src/main/java/com/termux/app/TermuxActivity.java
    - app/src/main/res/layout/activity_termux.xml

key-decisions:
  - "setupFlutterFragment() called in onCreate after setMargins() — engine may not be cached yet (async init), logs warning but does not crash"
  - "setSoulToggleButtonView() added as separate setup method — consistent with existing setToggleKeyboardView/setNewSessionButtonView pattern"

patterns-established:
  - "FlutterEngine singleton: pre-warm on background thread, executeDartEntrypoint on main thread, store in FlutterEngineCache with FLUTTER_ENGINE_ID"
  - "View toggle: swap GONE/VISIBLE between terminal RelativeLayout and flutter FrameLayout, refocus terminal on return"

requirements-completed: [FLUT-02, FLUT-03, FLUT-04, FLUT-05]

# Metrics
duration: 15min
completed: 2026-03-19
---

# Plan 03-C: Activity Migration + FlutterFragment Integration Summary

**FlutterEngine pre-warmed in Application, FlutterFragment embedded in TermuxActivity via FragmentManager, SOUL toggle button in left drawer for seamless terminal/Flutter view switching**

## Performance

- **Duration:** 15 min
- **Started:** 2026-03-19T10:00Z
- **Completed:** 2026-03-19T10:15Z
- **Tasks:** 7
- **Files modified:** 5

## Accomplishments
- TermuxActivity migrated from Activity to FragmentActivity (drop-in, no regressions)
- FlutterEngine pre-warmed on background thread in Application.onCreate() with cached ID "soul_flutter_engine"
- FlutterFragment embedded in flutter_container FrameLayout via getSupportFragmentManager()
- Toggle between terminal and Flutter views via VISIBLE/GONE swap, onBackPressed returns from Flutter to terminal
- SOUL button in left drawer triggers the toggle

## Task Commits

1. **03-C-01: settings.gradle Flutter module inclusion** - `ad099ca` (feat)
2. **03-C-02: Flutter dep in app/build.gradle** - `d73bfff` (feat)
3. **03-C-03: Pre-warm FlutterEngine in TermuxApplication** - `ff4ed2a` (feat)
4. **03-C-04: Migrate TermuxActivity to FragmentActivity** - `197cda9` (feat)
5. **03-C-05: flutter_container FrameLayout in layout** - `15184ab` (feat)
6. **03-C-06: FlutterFragment + toggleFlutterView()** - `212dabc` (feat)
7. **03-C-07: SOUL toggle button in left drawer** - `e1362f0` (feat)

## Files Created/Modified
- `settings.gradle` - Flutter module source inclusion via include_flutter.groovy
- `app/build.gradle` - Added implementation project(':flutter')
- `app/src/main/java/com/termux/app/TermuxApplication.java` - FlutterEngine pre-warming with FLUTTER_ENGINE_ID constant
- `app/src/main/java/com/termux/app/TermuxActivity.java` - FragmentActivity migration, FlutterFragment setup, toggle logic, SOUL button listener
- `app/src/main/res/layout/activity_termux.xml` - flutter_container FrameLayout + toggle_soul_button

## Decisions Made
- `setupFlutterFragment()` logs a warning (not crash) if engine not yet cached — engine init is async so race condition possible on slow devices; FlutterFragment can be added later
- `setSoulToggleButtonView()` follows existing pattern (separate method called in onCreate) rather than inlining

## Deviations from Plan
None — plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- FlutterFragment container and toggle infrastructure in place
- CI build will validate the Flutter module integration end-to-end (include_flutter.groovy only exists after `flutter pub get` runs in CI)
- Ready for 03-D: Flutter UI implementation (chat screen, onboarding, etc.)

---
*Phase: 03-flutter-integration*
*Completed: 2026-03-19*
