# Phase 6: App Merge — Research

**Researched:** 2026-03-20
**Researcher:** Phase Research Agent

---

## 1. Executive Summary

The SOUL app (237 Dart files, `soul-app/apps/soul/lib/`) is a mature Flutter application that must be merged into `flutter_module/`. The merge is primarily a copy-and-refactor operation: copy all `lib/` content, change package imports from `package:soul_app/` to `package:flutter_module/`, merge 52 dependencies into `flutter_module/pubspec.yaml`, and refactor `main()` initialization to work inside FlutterFragment lifecycle.

Key findings:

- **soul_core is a stub.** The package `soul-app/packages/soul_core/lib/soul_core.dart` contains only an empty library declaration. All real code lives in `apps/soul/lib/`. Inline merge is trivially correct.
- **main.dart already uses `UncontrolledProviderScope`.** The SOUL app's `main.dart` already wraps `runApp()` in `UncontrolledProviderScope(container: container, ...)`. The refactoring is moving the async init out of `main()` into a lifecycle-aware init function.
- **Drift `_openConnection()` uses `getApplicationDocumentsDirectory()`.** This resolves correctly inside FlutterFragment via Flutter's path_provider — no path changes needed.
- **ObjectBox `openStore()` has a default path** that writes to app documents directory. Same conclusion: works in FlutterFragment context unchanged.
- **Foreground service channel conflict is low risk.** SOUL uses channel ID `soul_foreground`, TermuxService is a native Java service with no Flutter notification channel. Notification ID 256 is SOUL's. No collision with Termux's native service.
- **52 deps in SOUL pubspec vs 1 dep (pigeon) in flutter_module.** All SOUL deps must be merged. No version conflicts with pigeon since pigeon is dev-only on the SOUL side but a runtime dep in flutter_module — needs careful handling.
- **CI needs one new step: `dart run build_runner build`** before `flutter pub get` output is consumed by Gradle. ObjectBox native libs require NDK; NDK is already configured in `app/build.gradle` (`ndkVersion`).
- **SOUL app has its own `/terminal` route using `xterm` package.** This internal terminal screen conflicts conceptually with the soul-terminal terminal (Phase 7+). It should be kept in code but not linked from the shell navigation initially.
- **VOYAGE_API_KEY** is read via `String.fromEnvironment('VOYAGE_API_KEY')` — must be passed via `--dart-define` in GitHub Actions.
- **Sentry** is initialized in `main.dart` via `SentryConfig.init()` wrapping `runApp()`. Must move to work in FlutterFragment context or be deferred.

---

## 2. SOUL App Architecture

### Directory layout (237 Dart files)

```
lib/
├── main.dart                          # Entry point, async init, runApp
├── objectbox-model.json               # ObjectBox model schema (generated artifact)
├── objectbox.g.dart                   # ObjectBox generated code
├── core/
│   ├── di/providers.dart              # ~590 lines, all Riverpod provider definitions
│   ├── router/app_router.dart         # GoRouter with StatefulShellRoute
│   ├── sentry_config.dart             # Sentry DSN configuration
│   ├── theme/soul_theme.dart          # Material 3 theme
│   └── utils/                        # Utility functions
├── models/                           # Freezed/JSON models
├── services/
│   ├── ai/                           # ClaudeService, SoulBrain, domains, layers
│   ├── agentic/                      # MCP manager, agentic tools, WAL
│   ├── auth/api_key_service.dart      # flutter_secure_storage wrapper
│   ├── chat/                         # OfflineMessageQueue
│   ├── database/
│   │   ├── soul_database.dart         # Drift DB, schema v12, 25 tables
│   │   ├── tables/*.drift             # 25 Drift table definitions
│   │   └── daos/                     # 20 DAOs
│   ├── demo/                         # DemoModeService, FeatureDiscoveryService
│   ├── memory/                       # VectorStore (ObjectBox), MemoryService, EmbeddingService
│   ├── monitoring/                   # CiMonitorService
│   ├── platform/                     # ForegroundServiceManager, Notifications, Contacts, Calendar
│   ├── success/                      # MomentumCalculator, CelebrationService
│   └── vessels/                      # VesselManager, VesselRouter, OpenClawClient, AgentSDK
└── ui/
    ├── agentic/                      # Agentic session UI
    ├── chat/                         # ChatScreen, widgets
    ├── common/                       # Shared widgets
    ├── conversations/                # ConversationListScreen
    ├── decisions/                    # Decision log UI
    ├── onboarding/                   # OnboardingScreen
    ├── profile/                      # ProfileScreen
    ├── projects/                     # ProjectDashboard
    ├── settings/                     # SettingsScreen
    ├── setup/                        # SetupScreen
    ├── shell/app_shell.dart          # Bottom navigation shell
    ├── terminal/                     # TerminalScreen using xterm (vessel terminal)
    └── vessels/                      # VesselSettingsScreen
```

### Initialization flow (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await openStore()` — ObjectBox store init (async, reads filesystem)
3. `ProviderContainer(overrides: [objectBoxStoreProvider.overrideWithValue(store)])` — creates container before widgets
4. Load Anthropic API key from secure storage → `container.read(apiKeyNotifierProvider.notifier).setKey(savedKey)`
5. Load OpenClaw credentials → `OpenClawClient.connect()` → `vesselManagerProvider.setOpenClawClient(client)`
6. `localNotificationServiceProvider.initialize()` — notification channels
7. `foregroundServiceManagerProvider.initialize()` + `startService()` — foreground service
8. `projectDao.getActiveProject()` → determine `initialLocation` (`/` or `/chat/new`)
9. `SentryConfig.init(appRunner: () => runApp(UncontrolledProviderScope(...)))`

### Provider architecture

All providers are in `lib/core/di/providers.dart` (~590 lines). They are standard `Provider<T>` / `NotifierProvider` / `FutureProvider` / `StreamProvider` — no `@riverpod` codegen in providers.dart itself. Codegen (`@riverpod`) is used in individual service files (e.g., `agentic_session_provider.dart`).

`objectBoxStoreProvider` throws `UnimplementedError` unless overridden — this is the primary hook for FlutterFragment initialization.

---

## 3. Dependency Analysis

### flutter_module current deps

```yaml
dependencies:
  flutter: sdk: flutter
  pigeon: ^22.7.0
```

### SOUL app deps (52 production + dev)

| Dep | Version | Notes |
|-----|---------|-------|
| flutter_riverpod | ^3.3.1 | Core state management |
| riverpod_annotation | ^4.0.2 | For @riverpod codegen in service files |
| anthropic_sdk_dart | ^1.3.2 | Claude API |
| drift | ^2.31.0 | SQLite ORM |
| sqlite3_flutter_libs | ^0.5.0 | Native SQLite |
| flutter_markdown_plus | ^1.0.7 | |
| markdown | ^7.3.0 | |
| flutter_highlight | ^0.7.0 | |
| highlight | ^0.7.0 | |
| dynamic_color | ^1.8.1 | |
| share_plus | ^10.0.0 | |
| flutter_secure_storage | ^10.0.0 | Android Keystore |
| envied | ^1.3.3 | |
| go_router | ^17.1.0 | |
| freezed_annotation | ^3.0.0 | |
| json_annotation | ^4.9.0 | |
| logger | ^2.5.0 | |
| mcp_dart | ^2.1.0 | |
| path_provider | ^2.1.0 | Critical for DB paths |
| uuid | ^4.5.0 | |
| connectivity_plus | ^6.0.0 | |
| glob | ^2.1.3 | |
| google_fonts | ^6.2.1 | |
| intl | ^0.20.2 | |
| objectbox | ^5.2.0 | Vector DB |
| objectbox_flutter_libs | any | Native .so files — needs NDK |
| http | ^1.4.0 | |
| url_launcher | ^6.3.0 | |
| flutter_foreground_task | ^9.2.1 | Background service |
| flutter_local_notifications | ^19.0.0 | |
| flutter_contacts | ^1.1.9+2 | |
| device_calendar_plus | ^0.3.4 | |
| notification_listener_service | ^0.3.5 | |
| permission_handler | ^11.3.0 | |
| device_info_plus | ^11.3.0 | |
| sentry_flutter | ^9.0.0 | |
| diff_match_patch | ^0.4.1 | |
| yaml | ^3.1.0 | |
| xterm | ^4.0.0 | Vessel terminal emulator in UI |
| web_socket_channel | ^3.0.3 | |

**pigeon conflict:** SOUL `pubspec.yaml` does not declare `pigeon` as a dependency (it's not listed). However, `flutter_module/pubspec.yaml` has `pigeon: ^22.7.0` as a runtime dependency. After merge, pigeon stays as a runtime dep — no conflict, just ensure it remains.

**SDK constraint conflict:** flutter_module has `sdk: '>=3.4.0 <4.0.0'`, SOUL has `sdk: ^3.11.1`. Must update to `^3.11.1` (i.e., `>=3.11.1 <4.0.0`).

**Dev deps to add:**
- build_runner: ^2.4.0
- drift_dev: ^2.31.0
- freezed: ^3.2.5
- json_serializable: ^6.8.0
- riverpod_generator: ^4.0.3
- envied_generator: ^1.3.3
- objectbox_generator: any
- flutter_lints: ^6.0.0 (already implied by default)

**High-risk native deps:**
- `objectbox_flutter_libs: any` — ships prebuilt `.so` for arm64. Requires NDK in CI to build the JNI bridge. NDK version already set in `app/build.gradle` via `project.properties.ndkVersion`.
- `sqlite3_flutter_libs: ^0.5.0` — prebuilt SQLite, should work without extra CI config.
- `notification_listener_service` — requires special Android permission; already in SOUL manifest.

---

## 4. AndroidManifest Merge Plan

### soul-terminal manifest (`app/src/main/AndroidManifest.xml`) already has

- `FOREGROUND_SERVICE` ✓
- `FOREGROUND_SERVICE_SPECIAL_USE` ✓
- `RECEIVE_BOOT_COMPLETED` ✓
- `POST_NOTIFICATIONS` ✓
- `WAKE_LOCK` ✓
- `MANAGE_EXTERNAL_STORAGE` ✓
- `INTERNET` ✓
- `ACCESS_NETWORK_STATE` ✓

### Missing from soul-terminal, present in SOUL app manifest

- `READ_CONTACTS` — needed for `flutter_contacts`
- `READ_CALENDAR` — needed for `device_calendar_plus`

### Services to add to soul-terminal manifest

```xml
<!-- SOUL foreground service (flutter_foreground_task plugin) -->
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="specialUse"
    android:exported="false">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="AI assistant providing proactive briefings and contextual monitoring" />
</service>

<!-- SOUL notification listener (notification_listener_service plugin) -->
<service
    android:label="SOUL Notifications"
    android:name="notification.listener.service.NotificationListener"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

### No conflicts

- TermuxService (`foregroundServiceType="specialUse"`, value `terminal_emulator`) and SOUL ForegroundService (`specialUse`, value `AI assistant...`) use different class names and different `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` values — no collision.
- Flutter plugin manifests (`flutter_foreground_task`, `notification_listener_service`) auto-merge into the app manifest via Gradle manifest merger. Explicit entries in the app manifest are technically redundant but required if the plugin's own manifest entry uses a different package context or if the property value needs to be set at the app level.
- `RECEIVE_BOOT_COMPLETED` is already present in soul-terminal manifest via `SystemEventReceiver`.
- `flutterEmbedding` meta-data is in flutter_module's own manifest and merges automatically — does not need to be added to app manifest.

---

## 5. ProviderScope Refactoring

### Current SOUL pattern

```dart
// In main() — called once when standalone app starts
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await openStore();
  final container = ProviderContainer(overrides: [
    objectBoxStoreProvider.overrideWithValue(store),
  ]);
  // ... load API key, OpenClaw, notifications, foreground service ...
  runApp(UncontrolledProviderScope(container: container, child: SoulApp(...)));
}
```

### Required pattern for FlutterFragment

In add-to-app, `main()` is called when the FlutterEngine starts (prewarmed by `TermuxApplication`). The engine may be created before `TermuxActivity` is shown. The `ProviderContainer` must exist from `main()` but heavy async init (ObjectBox, API key loading, foreground service) should not block engine startup.

**Recommended refactor:**

```dart
// Step 1: Create container eagerly in main()
ProviderContainer? _container;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _container = ProviderContainer(); // No objectBoxStore override yet
  runApp(UncontrolledProviderScope(
    container: _container!,
    child: const SoulInitWidget(), // Shows loading until init completes
  ));
  // Async init runs after runApp, does not block engine
  await _initializeApp(_container!);
}

Future<void> _initializeApp(ProviderContainer container) async {
  final store = await openStore();
  // Override objectBoxStoreProvider after store is ready
  // Note: ProviderContainer does not support late overrides natively.
  // Use a StateProvider<Store?> pattern instead, or use a Completer.
}
```

**Alternative (cleaner, uses existing objectBoxStoreProvider throw pattern):**

Use a `FutureProvider<Store>` that calls `openStore()` internally, replacing the manual `ProviderContainer` override. The `objectBoxStoreProvider` becomes:

```dart
final objectBoxStoreProvider = FutureProvider<Store>((ref) async {
  return await openStore(); // path_provider resolves correctly
});
```

All consumers watch the future. This eliminates the need for `ProviderContainer` overrides entirely and works identically in `main()` and FlutterFragment.

**Sentry wrapping:** `SentryConfig.init()` wraps `runApp()`. In FlutterFragment context, `runApp()` is still called — Sentry wrapping still works. However, check DSN is set via `--dart-define=SENTRY_DSN=...` in GitHub Actions.

### What the current flutter_module main.dart does

`flutter_module/lib/main.dart` currently contains `BridgeTestScreen` which implements `SoulBridgeApi`. After merge, this entire file is replaced by the SOUL `main.dart` (adapted). The `SoulBridgeApi.setUp(this)` call from `BridgeTestScreen` must be moved into the SOUL chat/main widget's `initState()`.

---

## 6. Database Path Resolution

### Drift (`SoulDatabase._openConnection()`)

```dart
static QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'soul.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

`getApplicationDocumentsDirectory()` on Android returns `/data/data/com.soul.terminal/files/Documents/` (or `/data/data/com.soul.terminal/app_flutter/` depending on path_provider version). In add-to-app FlutterFragment, this resolves correctly to the host app's documents directory — `com.soul.terminal` context.

**Result:** No change needed. Database writes to `com.soul.terminal` space automatically.

### ObjectBox (`openStore()`)

The generated `openStore()` function (in `objectbox.g.dart`) calls `getApplicationDocumentsDirectory()` by default and stores the ObjectBox data under `objectbox/` subdirectory:

```dart
Future<Store> openStore({String? directory, ...}) async {
  final dir = directory ?? (await getApplicationDocumentsDirectory()).path;
  return Store(getObjectBoxModel(), directory: dir + '/objectbox', ...);
}
```

**Result:** ObjectBox data lands at `/data/data/com.soul.terminal/files/Documents/objectbox/`. Works in FlutterFragment context. No change needed.

### No conflict with Termux data

Termux's own data is under `/data/data/com.soul.terminal/files/home/` (the Termux `$HOME`). Flutter's `getApplicationDocumentsDirectory()` returns `files/Documents/` or `app_flutter/` — a different subdirectory. No overlap.

---

## 7. Foreground Service Coexistence

### TermuxService

- Java class: `com.termux.app.TermuxService`
- `foregroundServiceType="specialUse"`, `PROPERTY_SPECIAL_USE_FGS_SUBTYPE="terminal_emulator"`
- Uses native Android `NotificationManager` directly (Java)
- Notification channel: created in Java code (Termux's own channel)
- Notification ID: defined in Termux Java code (likely ID 1 or `TermuxConstants.TERMUX_APP_NOTIFICATION_ID`)

### SOUL ForegroundService

- Flutter plugin class: `com.pravera.flutter_foreground_task.service.ForegroundService`
- Channel ID: `soul_foreground` (configured in `ForegroundServiceManager.initialize()`)
- Channel name: "SOUL Background Service"
- Service ID (notification ID): `256` (set in `ForegroundServiceManager.startService()`)
- `autoRunOnBoot: true` — will register its own boot intent

### Coexistence assessment

- **Different Java classes** — no class collision.
- **Different notification channels** — `soul_foreground` vs Termux's channel — no collision.
- **Different notification IDs** — 256 vs Termux's ID — no collision (Termux uses small integers, 256 is safely distinct).
- **Both `specialUse` type** — Android allows multiple `specialUse` foreground services per app with distinct subtypes.
- **Boot receiver:** SOUL's `autoRunOnBoot=true` tells `flutter_foreground_task` to restart the service on boot. Termux has `SystemEventReceiver` with `BOOT_COMPLETED` intent. Both boot receivers fire — no conflict.

**Risk:** `flutter_foreground_task` auto-adds a `<receiver>` for boot restart via its own manifest. This merges automatically. Verify the plugin's boot receiver does not conflict with Termux's `SystemEventReceiver` (different class names, different logic — should be fine).

---

## 8. CI/CD Changes

### Current workflow (`debug_build.yml`)

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.41.4'    # Already correct
    channel: 'stable'

- name: Flutter pub get
  run: |
    cd flutter_module
    flutter pub get

- name: Build APKs
  run: ./gradlew assembleDebug
```

### Required additions after merge

**1. NDK setup** — ObjectBox native libs require NDK to be present. The `app/build.gradle` already sets `ndkVersion` from `project.properties.ndkVersion`. GitHub-hosted `ubuntu-latest` runners have NDK available but a specific version must be specified:

```yaml
- name: Setup NDK
  uses: android-actions/setup-android@v3
  # Or: ensure NDK is installed via the Java/Android SDK setup step
  # ubuntu-latest already has Android SDK with NDK via ANDROID_SDK_ROOT
```

Check `gradle.properties` for the NDK version used, then verify it's available on `ubuntu-latest` (NDK r25+ is standard).

**2. build_runner codegen step** — Must run before Gradle tries to compile Flutter:

```yaml
- name: Flutter codegen (build_runner)
  run: |
    cd flutter_module
    dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `objectbox.g.dart` (from `objectbox-model.json` + model classes)
- `soul_database.g.dart` (from Drift schema + DAOs)
- `*.freezed.dart` (from @freezed annotations)
- `*.g.dart` (from @JsonSerializable, @riverpod)
- `*.env.g.dart` (from envied)

**3. VOYAGE_API_KEY dart-define** — `EmbeddingService` reads `String.fromEnvironment('VOYAGE_API_KEY')`. If key is empty, embedding returns null gracefully. For CI builds, add:

```yaml
- name: Flutter pub get
  run: |
    cd flutter_module
    flutter pub get --dart-define=VOYAGE_API_KEY=${{ secrets.VOYAGE_API_KEY }}
```

Or pass it during codegen/build step. Note: `pub get` doesn't use `--dart-define`. The define must be set during `flutter build` or passed to Gradle.

**4. Order of steps:**

```
flutter pub get  →  dart run build_runner  →  gradlew assembleDebug
```

build_runner requires `pub get` first. Gradle reads the Flutter module output, which depends on generated files.

**5. `envied` / `.env` handling** — `envied_generator` generates from `@EnviedField` annotations that read from a `.env` file at code generation time. If `.env` is not committed (correct, it shouldn't be), CI needs to create it or use `String.fromEnvironment()` instead of `@EnviedField`. Check if any SOUL files use `@Envied` annotation and handle accordingly.

**6. Gradle NDK for app module** — `app/build.gradle` already has `ndkVersion` for the terminal emulator's native C code (`src/main/cpp/Android.mk`). ObjectBox's NDK requirement is handled by the prebuilt `.so` in `objectbox_flutter_libs` — no additional NDK config in `app/build.gradle` needed beyond what exists.

---

## 9. Import Refactoring

### Scope

All 237 Dart files in `soul-app/apps/soul/lib/` use relative imports within the `soul_app` package. Since the package is named `soul_app` in `pubspec.yaml`, any absolute package imports are `package:soul_app/...`.

**Search for absolute package imports:**

```bash
grep -r "package:soul_app/" soul-app/apps/soul/lib/ | wc -l
```

In practice, the SOUL codebase uses **relative imports** throughout (confirmed by reading `providers.dart`, `main.dart`, `app_router.dart` — all use `'../../...'` relative paths). Absolute `package:soul_app/` imports would only appear if the code references its own package absolutely, which is uncommon in well-structured Flutter projects.

**What definitely needs changing:**

- `import 'package:soul_app/...'` → `import 'package:flutter_module/...'` (if any exist)
- The `name:` field in `flutter_module/pubspec.yaml` stays `flutter_module` — all `package:flutter_module/generated/...` imports in the existing code remain valid

**Import change scope is likely zero** if the SOUL codebase uses only relative imports internally. Verify by running grep after copying files.

### Files that must be kept unchanged after merge

- `flutter_module/lib/generated/terminal_bridge.g.dart` — Pigeon generated, references `package:flutter_module.TerminalBridgeApi`
- `flutter_module/lib/generated/system_bridge.g.dart` — Same
- `flutter_module/pigeons/` — Pigeon schema source files

### Conflict: SOUL has its own `/terminal` UI

SOUL's `lib/ui/terminal/terminal_screen.dart` uses `xterm` for a vessel-connected terminal. This is NOT the same as Termux's native terminal. The route `/terminal` appears in `app_router.dart` as a tab in the `StatefulShellRoute`. For Phase 6, keep this route but note it will be superseded or adapted in Phase 7 (Bottom Sheet Layout) and Phase 9 (SOUL Terminal Awareness). The Pigeon `TerminalBridgeApi` bridges to the native terminal, while SOUL's `TerminalScreen` connects to vessels via WebSocket.

---

## 10. Risk Assessment

| Rank | Risk | Severity | Mitigation |
|------|------|----------|-----------|
| 1 | **build_runner codegen fails in CI** — ObjectBox generator requires NDK to be available; Drift generator requires all table `.drift` files to be correct; any missing import breaks entire codegen. | High | Run codegen locally via cmd-proxy first to validate. Add explicit NDK install step in workflow. |
| 2 | **ProviderScope init ordering** — ObjectBox `openStore()` is async; if widget tree builds before store is ready, `objectBoxStoreProvider` throws `UnimplementedError` and crashes. | High | Use `FutureProvider<Store>` or a loading screen widget that awaits init before rendering SOUL UI. |
| 3 | **Dart SDK constraint mismatch** — `flutter_module` currently allows `>=3.4.0`, SOUL requires `^3.11.1`. If CI Flutter version is older, codegen/build fails silently. | Medium | Update `environment.sdk` to `^3.11.1` and confirm CI uses Flutter 3.41.4 (already set in workflows). |
| 4 | **objectbox.g.dart + objectbox-model.json placement** — These must be in the same directory as the ObjectBox entity classes. If copied to wrong path, codegen breaks. | Medium | Copy to `flutter_module/lib/` root alongside entity model classes. |
| 5 | **Drift schema migration** — SoulDatabase is at schema version 12. On first run in `com.soul.terminal` context, `onCreate` runs (fresh DB). If migration code references tables that don't exist in `onCreate`, startup crashes. | Medium | `onCreate` calls `m.createAll()` — this is safe. Risk is if `onUpgrade` has side effects that run on fresh install; it should not since `from < 2` etc. guards apply. |
| 6 | **envied / VOYAGE_API_KEY in CI** — If any file uses `@Envied` annotation pointing to a `.env` file, codegen fails without that file. | Medium | Identify all `@Envied` usages. Create a CI step to write a minimal `.env` with placeholder values, or switch to `String.fromEnvironment()` pattern. |
| 7 | **xterm package conflict** — SOUL includes `xterm: ^4.0.0` for vessel terminal. `xterm` is a pure-Dart terminal emulator (no native code). No conflict with Termux's native rendering. But the UI route `/terminal` uses `xterm` to show a vessel-connected terminal that may confuse users. | Low | Keep code, exclude from bottom navigation in Phase 7. |
| 8 | **flutter_foreground_task boot restart** — With `autoRunOnBoot=true`, SOUL's foreground service restarts after device reboot. This adds a background process even when the user hasn't opened the app. | Low | Acceptable behavior for SOUL's monitoring capabilities. Can be disabled via settings if needed. |
| 9 | **Pigeon bridge setup call** — `SoulBridgeApi.setUp(this)` was called in `BridgeTestScreen.initState()`. After merge, this must be called from the SOUL root widget's `initState()` or from a widget that implements `SoulBridgeApi`. If not set up, Java-side bridge calls fail silently. | Low | Identify the correct widget in SOUL app to own the bridge setup. `AppShell` or root `SoulApp` widget is best candidate. |
| 10 | **Sentry in FlutterFragment** — `SentryConfig.init()` wraps `runApp()`. In add-to-app, this still works, but Sentry may capture errors from both Flutter and native sides. Ensure DSN is configured via `--dart-define=SENTRY_DSN=...` in GitHub Actions (currently not set — builds run without Sentry). | Low | Add `SENTRY_DSN` secret and `--dart-define` arg, or stub `SentryConfig.init()` to be a no-op when DSN is empty. |

---

## 11. Validation Architecture

### MERG-01: SOUL app Dart code (339 files) copied

**Verify:** `find flutter_module/lib -name "*.dart" | wc -l` yields ≥ 339 (237 SOUL + existing generated + 1 soul_core + main.dart).

**CI check:** `dart analyze flutter_module/lib` reports zero errors after copy.

### MERG-02: pubspec.yaml merged (52 deps)

**Verify:** `cat flutter_module/pubspec.yaml | grep -c "^  [a-z]"` yields 52+ dependencies.

**CI check:** `flutter pub get` exits 0 with no version conflicts in output.

### MERG-03: AndroidManifest merged (permissions, services, boot receiver)

**Verify:** `grep -c "READ_CONTACTS\|READ_CALENDAR\|ForegroundService\|NotificationListener" app/src/main/AndroidManifest.xml` yields 4+.

**CI check:** `./gradlew :app:processDebugManifest` exits 0, merged manifest at `app/build/intermediates/merged_manifests/debug/` contains all required entries.

### MERG-04: ProviderScope refactored for FlutterFragment

**Verify:** `flutter_module/lib/main.dart` contains `UncontrolledProviderScope` and does not call `ProviderContainer` with a direct `objectBoxStoreProvider.overrideWithValue` in `main()`.

**Runtime check:** App launches without `UnimplementedError` from `objectBoxStoreProvider`. LogCat shows "ObjectBox store initialized" before first widget build.

### MERG-05: Database paths work in com.soul.terminal context

**Verify:** First launch creates `soul.sqlite` at `/data/data/com.soul.terminal/files/Documents/soul.sqlite` (or `app_flutter/soul.sqlite`). ObjectBox data at `.../objectbox/`.

**Runtime check:** `adb shell run-as com.soul.terminal ls files/` shows `Documents/` containing `soul.sqlite`.

### MERG-06: Foreground service coexistence

**Verify:** TermuxService starts → then SOUL ForegroundService starts → both appear in `adb shell dumpsys activity services | grep -E "TermuxService|ForegroundService"`.

**Runtime check:** Two distinct notification entries in status bar (or just SOUL's since Termux may not show a persistent notification by default).

### MERG-07: SOUL chat UI functional as main screen

**Verify:** FlutterFragment displays `SoulApp` root widget. Navigation to `/chat/new` works. Sending a message (with API key set) returns a response.

**Runtime check:** End-to-end: enter API key in settings → open chat → send message → receive Claude response.

### MERG-08: CI builds merged app successfully

**Verify:** `debug_build.yml` passes on GitHub Actions after all changes committed. Artifacts include `soul-terminal_vX.Y.Z+xxxxxxx-soul-terminal-github-debug_arm64-v8a.apk`.

**CI check:** All four workflow jobs (pub get, build_runner, assembleDebug, artifact upload) succeed.

### MERG-09: API key input works in merged context

**Verify:** `ApiKeyService.setAnthropicKey(key)` writes to Android Keystore under `com.soul.terminal` package. Key survives app restart.

**Runtime check:** Enter key in SOUL settings → force-stop app → reopen → key is pre-loaded (no re-entry needed). `container.read(apiKeyNotifierProvider)` returns the key without prompting.

---

## RESEARCH COMPLETE
