# Pitfalls Research: SOUL Terminal

## Critical Pitfalls

### P1: Bootstrap binaries have hardcoded `/data/data/com.termux` paths
Termux compiles all packages with `$PREFIX` baked into the binaries (e.g., `/data/data/com.termux/files/usr`). Changing `TERMUX_PACKAGE_NAME` to `com.soul.terminal` means **every single binary** in the bootstrap must be recompiled with the new prefix `/data/data/com.soul.terminal/files/usr`. You cannot mix packages from different prefixes — they will crash or silently produce wrong paths at runtime.

- **Warning signs:** Segfaults, "file not found" errors for libs/configs, packages referencing `/data/data/com.termux/` in strace output
- **Prevention:** Fork `termux-packages`, change `TERMUX_APP__PACKAGE_NAME` in `scripts/properties.sh` to `com.soul.terminal`, rebuild ALL packages from source with `build-bootstraps.sh` (not `generate-bootstraps.sh`). Run `./scripts/run-docker.sh ./clean.sh` before building to prevent stale prefix contamination. Verify with `strings` on key binaries (bash, apt, pkg) that no `com.termux` paths remain.
- **Phase:** Bootstrap Pipeline (must be completed before first working APK)

### P2: FlutterFragment plugin registration failure
Flutter plugins are NOT automatically registered when using `FlutterFragment` (unlike `FlutterActivity`). The default `FlutterFragment.createDefault()` creates an engine that skips `GeneratedPluginRegistrant`. Any plugin call (camera, location, platform channels) throws `PlatformException: Unable to establish connection on channel`.

- **Warning signs:** `PlatformException(channel-error, ...)` at runtime, plugins work in standalone Flutter app but not in embedded fragment
- **Prevention:** Use a cached `FlutterEngine` pre-warmed in `Application.onCreate()`, manually call `GeneratedPluginRegistrant.registerWith(engine)` before attaching the fragment. Alternatively, override `FlutterFragment` and implement `configureFlutterEngine()`.
- **Phase:** Flutter Module Embedding

### P3: FlutterEngine memory leaks on fragment navigation
Known Flutter framework bug (issues #168658, #36898): `FlutterFragment` and `FlutterHostFragment` are not properly released after navigation back to native screens. `onWindowFocusChangeListener` leaks through `ViewTreeObserver`, keeping the entire engine + Dart heap in memory.

- **Warning signs:** OOM crashes after switching between terminal and Flutter views multiple times, LeakCanary reports on `FlutterView`/`FlutterImageView`
- **Prevention:** Use a single cached `FlutterEngine` that outlives the fragment. Do NOT create a new engine per fragment. Detach the fragment's view without destroying the engine. Consider `FlutterEngineCache` for the singleton pattern.
- **Phase:** Flutter Module Embedding

### P4: sharedUserId locks you into a signing key forever
The AndroidManifest uses `android:sharedUserId="${TERMUX_PACKAGE_NAME}"`. Once installed with a signing key, you can NEVER change that key without requiring users to uninstall and lose all data. Also, `sharedUserId` is deprecated in API 29+ and causes warnings.

- **Warning signs:** App installs fail with "signatures do not match" when switching from debug to release or between CI builds
- **Prevention:** Decide on signing key strategy before first public APK. Consider removing `sharedUserId` entirely since SOUL Terminal won't share data with Termux plugin apps. If you keep it, use `com.soul.terminal` (not `com.termux`) to avoid conflicts with existing Termux installs.
- **Phase:** Rebranding (Phase 1)

## Common Mistakes

### M1: Incomplete package name replacement in TermuxConstants.java
`TermuxConstants.java` is ~600+ lines with the package name referenced in 30+ constants. Every path (`TERMUX_FILES_DIR_PATH`, `TERMUX_PREFIX_DIR_PATH`, `TERMUX_BIN_PREFIX_DIR_PATH`, etc.) is derived from `TERMUX_PACKAGE_NAME`. A partial rename leaves inconsistent paths.

- **Warning signs:** App launches but can't find `$PREFIX`, bootstrap extraction fails, shell starts in wrong directory
- **Prevention:** Only change the single `TERMUX_PACKAGE_NAME = "com.termux"` constant at line 352 — all other paths are derived from it. Verify with a project-wide search for literal `"com.termux"` strings after the change.
- **Phase:** Rebranding

### M2: Forgetting the namespace vs. applicationId distinction
The codebase has multiple `namespace` declarations in build.gradle files (`com.termux`, `com.termux.shared`, `com.termux.emulator`, `com.termux.view`). These are Java package namespaces for R class generation, NOT the applicationId. Changing them breaks all `import com.termux.*` statements across the entire codebase (hundreds of files). But NOT changing `applicationId` means the APK installs as `com.termux`.

- **Warning signs:** Thousands of compilation errors after namespace change, or app installs but conflicts with Termux
- **Prevention:** Change `applicationId` and `manifestPlaceholders.TERMUX_PACKAGE_NAME` in `app/build.gradle` to `com.soul.terminal`. Keep Java `namespace` values as `com.termux.*` to avoid mass refactoring. The namespace and applicationId can be different. Only rename Java packages later if/when doing a full code refactor.
- **Phase:** Rebranding

### M3: Missing `strings.xml` entity update
The file `app/src/main/res/values/strings.xml` defines `<!ENTITY TERMUX_PACKAGE_NAME "com.termux">` as an XML entity. This is used in string resources. Missing this causes the old package name to appear in UI text and permission strings.

- **Warning signs:** "com.termux" appearing in permission dialogs, notification text, or about screens
- **Prevention:** Update the entity in `strings.xml`, plus `manifestPlaceholders.TERMUX_APP_NAME` to "SOUL Terminal"
- **Phase:** Rebranding

### M4: Flutter module increases APK size by 15-30 MB
The Flutter engine adds ~15 MB baseline, plus Dart AOT code. For a terminal app that's currently ~5-10 MB, this is a 3-6x increase.

- **Warning signs:** Users on low-storage devices can't install, APK exceeds Play Store size warnings
- **Prevention:** Use deferred components (Android dynamic delivery) to load Flutter module on demand. Build arm64-v8a only (project constraint). Use `--split-debug-info` and `--obfuscate` for release builds.
- **Phase:** Flutter Module Embedding

### M5: Flutter engine startup latency on cold start
`FlutterEngine` initialization takes 200-500ms on modern devices for loading the Dart VM, compiling JIT, and running `main()`. If created during Activity launch, the terminal will feel sluggish.

- **Warning signs:** Visible delay when opening app, blank Flutter view for 300ms+
- **Prevention:** Pre-warm `FlutterEngine` in `Application.onCreate()` and cache it. The terminal view should be ready instantly; Flutter initializes in background. Never block terminal startup on Flutter being ready.
- **Phase:** Flutter Module Embedding

## Package Name Rebranding Risks

### R1: Content provider authority conflicts
The AndroidManifest defines providers with authorities `${TERMUX_PACKAGE_NAME}.documents` and `${TERMUX_PACKAGE_NAME}.files`. If a user has Termux AND SOUL Terminal installed and both use `com.termux`, Android refuses to install the second app ("INSTALL_FAILED_CONFLICTING_PROVIDER").

- **Prevention:** Ensure `manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.soul.terminal"` so authorities become `com.soul.terminal.documents` and `com.soul.terminal.files`.
- **Phase:** Rebranding

### R2: RunCommandService intent filter changes break external integrations
The `RunCommandService` listens for `${TERMUX_PACKAGE_NAME}.RUN_COMMAND` intents with permission `${TERMUX_PACKAGE_NAME}.permission.RUN_COMMAND`. Any external app (Tasker, Automate, scripts) using the old intent action will silently fail.

- **Prevention:** Acceptable for v1 — SOUL Terminal is a new app, not a Termux replacement. Document the new intent actions for integrators.
- **Phase:** Rebranding

### R3: External storage symlinks reference package name
`TermuxInstaller.java` (line 338-350) creates symlinks at `Android/data/com.termux` and `Android/media/com.termux`. If the package name changes but this code doesn't update, symlinks point to wrong directories or fail silently.

- **Prevention:** These symlinks are derived from the Android context's `getExternalFilesDir()`, which automatically uses the correct package name. Verify this during testing — do NOT hardcode paths.
- **Phase:** Rebranding

### R4: termux-am-library dependency uses com.termux groupId
`termux-shared/build.gradle` depends on `com.termux:termux-am-library:v2.0.0` from Maven. This is an external dependency that doesn't need rebranding, but if you publish your own fork of this library, the groupId must be consistent.

- **Prevention:** Keep using the upstream `com.termux:termux-am-library` dependency. Only fork if you need to modify it. Not a priority for v1.
- **Phase:** Not applicable for v1

## Bootstrap Pipeline Risks

### B1: build-bootstraps.sh on master branch is broken
The `build-bootstraps.sh` on the master branch of `termux-packages` has known issues. The `infra-improvs` branch has a more reliable version.

- **Warning signs:** Build failures with unhelpful errors, missing packages, broken symlinks in output zip
- **Prevention:** Use the `infra-improvs` branch of `termux-packages` for `build-bootstraps.sh`. Or use the script from a recent stable release tag.
- **Phase:** Bootstrap Pipeline

### B2: bzip2 subpackage confusion
When customizing the bootstrap package list, adding `bzip2` directly fails because it's a subpackage of `libbz2`. The builder looks for a non-existent top-level `bzip2` package.

- **Warning signs:** `ERROR: No package bzip2 found in any of the enabled repositories`
- **Prevention:** Use `libbz2` instead of `bzip2` in the package list. Audit all packages in the bootstrap list for subpackage relationships before building.
- **Phase:** Bootstrap Pipeline

### B3: Bootstrap checksum mismatch after rebuild
The `downloadBootstraps` task in `app/build.gradle` (lines 218-237) hardcodes SHA-256 checksums for each architecture's bootstrap zip. After building custom bootstraps, these checksums must be updated or the build fails.

- **Warning signs:** `Wrong checksum for ...` during Gradle build
- **Prevention:** After building custom bootstraps with `build-bootstraps.sh`, compute SHA-256 of each output zip and update `app/build.gradle`. Better: change the download URL to point to your own GitHub releases (not `termux/termux-packages`). Consider hosting bootstraps in the same repo as release artifacts.
- **Phase:** Bootstrap Pipeline

### B4: Cross-compilation environment requirements
Building termux packages requires a specific Docker environment (`termux/package-builder`). Building outside Docker or with wrong NDK versions produces broken binaries.

- **Warning signs:** Packages compile but crash at runtime, missing symbol errors, wrong ABI
- **Prevention:** Always use `./scripts/run-docker.sh` for package builds. Set up GitHub Actions with the official Docker image. Never build packages locally on the phone.
- **Phase:** Bootstrap Pipeline

### B5: apt repository must match package name
Packages built for `com.soul.terminal` cannot be served from Termux's official apt repository. You need your own repository, or users can never `pkg install` anything after bootstrap.

- **Warning signs:** `apt update` fails, packages install but crash due to prefix mismatch
- **Prevention:** Set up a GitHub Pages or Cloudflare R2 apt repository. Configure `sources.list` in the bootstrap to point to your repository. Automate package publishing in CI.
- **Phase:** Bootstrap Pipeline (required for ongoing package updates)

## Prevention Strategies

### Phase: Rebranding
1. Change ONLY these files for package name:
   - `TermuxConstants.java` line 352: `TERMUX_PACKAGE_NAME = "com.soul.terminal"`
   - `app/build.gradle`: `manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.soul.terminal"` and `manifestPlaceholders.TERMUX_APP_NAME = "SOUL Terminal"`
   - `app/src/main/res/values/strings.xml`: entity `TERMUX_PACKAGE_NAME` to `com.soul.terminal`
2. Do NOT change Java namespace/package directories yet — keep `com.termux.*` internally
3. Remove or update `sharedUserId` in AndroidManifest
4. Project-wide search for hardcoded `"com.termux"` string literals (not import statements)
5. Test: install alongside Termux — no conflicts

### Phase: Bootstrap Pipeline
1. Fork `termux-packages`, change `TERMUX_APP__PACKAGE_NAME` in `properties.sh`
2. Use `build-bootstraps.sh` from `infra-improvs` branch
3. Build aarch64 only (project constraint)
4. Update checksums in `app/build.gradle`
5. Set up apt repository for ongoing package distribution
6. CI: automate bootstrap rebuild on package updates

### Phase: Flutter Module Embedding
1. Pre-warm a single cached `FlutterEngine` in `Application.onCreate()`
2. Manually register plugins with `GeneratedPluginRegistrant.registerWith(engine)`
3. Never create new engines per fragment — use `FlutterEngineCache`
4. Add Pigeon interface definition before writing any platform channel code
5. Profile memory after 10+ terminal-Flutter-terminal switches
6. Keep terminal view as the primary — Flutter is secondary, non-blocking

### Phase: CI/CD
1. Separate workflows: bootstrap build (rare) vs. app build (frequent)
2. Bootstrap artifacts stored as GitHub releases with checksums
3. App build downloads bootstrap from your releases, not Termux upstream
4. Sign APKs with a persistent keystore stored as GitHub secret
5. Test APK install via ADB in CI if possible (or manual on-device)
