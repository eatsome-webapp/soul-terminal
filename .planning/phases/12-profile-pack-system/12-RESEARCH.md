# Phase 12: Profile Pack System — Research

## 1. Profile Pack Build Pipeline

### Docker Image
The existing `bootstrap_build.yml` uses `ghcr.io/termux/package-builder` — a 2.4GB Ubuntu 24.04-based image with Android NDK, SDK, and cross-compilation toolchain pre-configured. This is the canonical image for building Termux packages and bootstraps.

### Approach: Snapshot $PREFIX Delta
The profile pack build cannot reuse `generate-bootstraps.sh` directly (that creates a full bootstrap). Instead, the workflow needs to:

1. Start from the same `ghcr.io/termux/package-builder` Docker image
2. Extract a base bootstrap (or use `build-package.sh -I` to download base packages)
3. Install the profile's packages on top (`pkg install -y nodejs git gh && npm install -g @anthropic-ai/claude-code`)
4. Diff the resulting `$PREFIX` against the base bootstrap to create a delta zip
5. Include SYMLINKS.txt in the same format as bootstrap (target`<-`link format, `←` separator)
6. Compute SHA-256, publish as GitHub Release asset, update manifest.json

### Key Challenge: Running pkg Inside Docker
Termux packages are built for Android/aarch64 but the Docker runs on x86_64. Options:
- **Option A: Cross-compile individual packages** — complex, the `build-package.sh` system handles this but you'd need to build nodejs, git, gh, and all deps individually
- **Option B: QEMU user-mode emulation** — run aarch64 binaries on x86_64 using `qemu-user-static` + binfmt_misc. GitHub Actions runners support this via `docker/setup-qemu-action`. This lets you run `pkg install` inside an aarch64 Termux environment
- **Option C: Use pre-built .deb packages** — download aarch64 .deb files from Termux's apt repository, extract them into a staging $PREFIX, then zip the delta

**Recommended: Option C** — simplest, most reliable. The `.deb` files are already cross-compiled and available at `https://packages.termux.dev/apt/termux-main/`. Download + dpkg-deb extract + npm via QEMU for the npm global install step.

### Workflow Pattern (based on bootstrap_build.yml)
```yaml
name: Profile Pack Build
on:
  workflow_dispatch:
    inputs:
      profile_id: {type: choice, options: [claude-code, python]}
      version_tag: {type: string, required: true}
jobs:
  build-profile-pack:
    runs-on: ubuntu-24.04
    steps:
      - checkout
      - setup-qemu-action (for aarch64 npm install)
      - run Docker with ghcr.io/termux/package-builder
      - download base bootstrap, extract
      - pkg install profile packages (via apt-get + dpkg in staging dir)
      - npm install -g (via QEMU user-mode)
      - diff base vs. result, create delta zip with SYMLINKS.txt
      - sha256sum, create release, update manifest.json
```

### npm Global Install Challenge
`npm install -g @anthropic-ai/claude-code` is the biggest part of the pack (~200MB+). This installs JavaScript files (architecture-independent) plus native addons (architecture-dependent). Two approaches:
- **QEMU aarch64 emulation**: slow (~30 min) but accurate
- **Host npm install + copy**: since most of Claude Code is JavaScript, install on host, then selectively cross-compile native addons. Fragile.

**Recommended: QEMU emulation** — correctness over speed, this runs infrequently.

## 2. Pack Format & Extraction

### Current Zip Structure (from ProfilePackInstaller.java)
The installer expects a zip with:
- `SYMLINKS.txt` — lines in format `target←linkpath` (relative to $PREFIX)
- Regular files — paths relative to $PREFIX (e.g., `bin/node`, `lib/node_modules/...`)
- Directories — created automatically during extraction

### Extraction Logic (already implemented)
`ProfilePackInstaller.extractProfilePack()`:
1. Writes `.soul-profile-installing` marker (crash recovery)
2. Extracts all files over `$PREFIX` (additive, overwrites existing)
3. Sets chmod 0700 on files in `bin/`, `libexec/`, `lib/apt/apt-helper`, `lib/apt/methods`
4. Creates symlinks from SYMLINKS.txt (deletes existing before re-creating)
5. Writes `.soul-profile-{id}` version marker
6. Deletes `.soul-profile-installing` marker
7. Deletes downloaded zip

### Permissions
- Files in `bin/`, `libexec/` get `0700` (owner execute)
- Other files get default permissions from ZipInputStream
- Symlinks: created via `Os.symlink()`, which works without root on Android

### Important: No Home Directory Writes (PROF-10)
The extraction targets `TERMUX_PREFIX_DIR_PATH` only (`/data/data/com.soul.terminal/files/usr`). Home directory (`/data/data/com.soul.terminal/files/home`) is never touched. This is already enforced by the zip structure — all paths are relative to $PREFIX.

### Build Script Delta Logic
```bash
# After installing packages:
# 1. Find new/modified files
find $PREFIX -newer $TIMESTAMP_MARKER -type f -o -type l > delta_files.txt
# 2. Build SYMLINKS.txt from symlinks
find $PREFIX -type l | while read lnk; do
  target=$(readlink "$lnk")
  rel=${lnk#$PREFIX/}
  echo "${target}←${rel}"
done > SYMLINKS.txt
# 3. Create zip (files relative to $PREFIX)
cd $PREFIX && zip -r profile-pack.zip $(cat delta_files.txt) SYMLINKS.txt
```

## 3. Lazy Install (Tier 2)

### Bash's `command_not_found_handle`
Bash (note: no 'r' at end) provides `command_not_found_handle()` function. When a command is not found in PATH, bash calls this function with the command name as `$1`. Zsh has the equivalent `command_not_found_handler()` (with 'r').

### Termux Already Has This
Termux ships a `command-not-found` package (v3.4.1, Apache-2.0). It's a C++ binary at `$PREFIX/libexec/termux/command-not-found` that maps command names to package names using an embedded database. The hook is configured in `$PREFIX/etc/bash.bashrc`:
```bash
command_not_found_handle() {
  $PREFIX/libexec/termux/command-not-found "$1"
}
```

### SOUL Integration Strategy
Instead of replacing Termux's `command-not-found`, layer on top of it:

1. **In .bashrc** (written during onboarding/shell config step):
```bash
command_not_found_handle() {
  # Notify SOUL via OSC escape sequence
  printf '\033]777;soul-cnf;%s\007' "$1"
  # Also run Termux's default handler for user info
  if [ -x "$PREFIX/libexec/termux/command-not-found" ]; then
    "$PREFIX/libexec/termux/command-not-found" "$1"
  fi
  return 127
}
```

2. **On Java side**: Parse terminal output for OSC 777 escape sequence in TerminalView or output stream listener. When detected, fire Pigeon event to Flutter with the missing command name.

3. **On Flutter side**: Show inline prompt "X is niet geinstalleerd. Installeren via profile pack?" with options to install via pack or pkg.

### Alternative: Pigeon Output Monitoring
The existing `onTerminalOutput` Pigeon callback already streams terminal output to Flutter. Could detect "command not found" text pattern instead of OSC escape. Simpler but less reliable (locale-dependent, could match false positives).

**Recommended: OSC escape approach** — reliable, no false positives, works regardless of locale.

### Mapping Commands to Profiles
Need a small lookup table:
```dart
const commandToProfile = {
  'claude': 'claude-code',
  'node': 'claude-code',
  'npm': 'claude-code',
  'npx': 'claude-code',
  'git': 'claude-code',  // also in python profile
  'gh': 'claude-code',
  'python': 'python',
  'python3': 'python',
  'pip': 'python',
  'pip3': 'python',
};
```

## 4. Background Update Architecture

### Current Background Handler
`SoulBackgroundHandler` runs in a **separate isolate** via `FlutterForegroundTask`. The `onRepeatEvent()` fires every 15 minutes and already contains multiple daily-rate-limited checks (briefing, metrics, weekly review).

### Adding Profile Update Check
Pattern to follow (same as existing daily checks):

```dart
// In SoulBackgroundHandler fields:
DateTime? _lastProfileUpdateCheck;

// In onRepeatEvent():
try {
  final now = DateTime.now();
  if (_lastProfileUpdateCheck == null ||
      now.difference(_lastProfileUpdateCheck!).inHours >= 24) {
    await _checkProfileUpdates();
    _lastProfileUpdateCheck = now;
  }
} catch (error) {
  _logger.e('Profile update check failed: $error');
}
```

### Persisting Last-Check Timestamp
Use `SettingsDao` (already available via `_backgroundDb.settingsDao`):
```dart
const _lastUpdateCheckKey = 'profile_update_last_check';
const _updateAvailableKey = 'profile_update_available';
const _updateCheckFrequencyKey = 'profile_update_check_frequency'; // daily/weekly/never
```

### Update Check Logic
1. Read `_updateCheckFrequencyKey` from settings — if "never", skip
2. Read `_lastUpdateCheckKey` — if within frequency window, skip
3. Fetch manifest (~1KB HTTP GET to raw.githubusercontent.com)
4. For each installed profile (read version markers via Pigeon bridge): compare remote vs local version
5. If newer: write `_updateAvailableKey = true` + `profile_update_remote_version = X` to settings
6. Send notification to main isolate via `FlutterForegroundTask.sendDataToMain()`
7. Update `_lastUpdateCheckKey`

### Important: Background Isolate Cannot Use Pigeon
Pigeon bridges require a BinaryMessenger (FlutterEngine), which isn't available in the background isolate. Options:
- **Option A**: Read version marker files directly from Dart (`File('$PREFIX/.soul-profile-{id}').readAsStringSync()`) — simple, no bridge needed
- **Option B**: Send command to main isolate, which calls Pigeon, then replies back — complex

**Recommended: Option A** — the version marker is just a text file in a known location. Dart `File` I/O works in any isolate.

### Settings UI Integration
Add to `BackgroundServiceSettings`:
- SwitchListTile: "Profile updates controleren" (on/off)
- DropdownButton: Frequency (dagelijks/wekelijks) — only shown when enabled
- Conditional banner: "Update beschikbaar: {profile} {version}" with "Nu updaten" button

## 5. Manifest & Version Comparison

### Version Format
Date-based: `2026.03.22-r1`
- `2026.03.22` = date (YYYY.MM.DD)
- `-r1` = revision number for same-day builds

### Comparison Algorithm
Simple string comparison works for this format because:
- Year.Month.Day is lexicographically orderable when zero-padded
- Revision `r1 < r2 < r10` fails with string comparison!

**Need numeric-aware comparison:**
```dart
int compareVersions(String a, String b) {
  // Split on '-r' to get date and revision
  final partsA = a.split('-r');
  final partsB = b.split('-r');

  // Compare date portion (string compare works for YYYY.MM.DD)
  final dateCompare = partsA[0].compareTo(partsB[0]);
  if (dateCompare != 0) return dateCompare;

  // Compare revision number numerically
  final revA = partsA.length > 1 ? int.tryParse(partsA[1]) ?? 0 : 0;
  final revB = partsB.length > 1 ? int.tryParse(partsB[1]) ?? 0 : 0;
  return revA.compareTo(revB);
}
```

This correctly handles: `2026.03.22-r1 < 2026.03.22-r2 < 2026.03.22-r10 < 2026.04.01-r1`

## 6. Existing Code Analysis

### Already Implemented (Working)
| Component | File | Status |
|-----------|------|--------|
| ProfileManifest model | `profile_manifest.dart` | Complete — fromJson, isAvailable check |
| ProfilePackService | `profile_pack_service.dart` | Complete — fetchManifest, downloadPack (with progress), installPack, getInstalledVersion, getInterruptedInstallation |
| ProfilePackInstaller (Java) | `ProfilePackInstaller.java` | Complete — extractProfilePack, verifySha256, version markers, crash recovery markers |
| Pigeon bridge definition | `profile_pack_bridge.dart` | Complete — 4 methods |
| Pigeon bridge impl (Java) | `ProfilePackBridgeImpl.java` | Complete — delegates to ProfilePackInstaller |
| Pigeon bridge generated (Java) | `ProfilePackBridgeApi.java` | Complete — registered in TermuxActivity.setupPigeonBridges() |
| Pigeon bridge generated (Dart) | `profile_pack_bridge.g.dart` | Complete |
| Setup wizard fast-path | `setup_wizard_provider.dart` | Complete — _installViaProfilePack() tries pack first, falls back to pkg |
| Manifest JSON | `profile-packs/manifest.json` | Schema complete, but URLs/sha256/sizes are empty (placeholder) |

### Not Yet Implemented (Needs Building)
| Component | Requirement | Notes |
|-----------|-------------|-------|
| GitHub Actions profile pack build workflow | PROF-01 | New workflow needed; bootstrap_build.yml as model |
| Real manifest.json values | PROF-01 | URLs, sha256, sizes need to be filled by CI |
| Lazy install (command_not_found hook) | PROF-03 | New: shell hook + OSC escape + Flutter handler |
| Improved pkg fallback (parallel, time estimates) | PROF-04 | Modify _installViaPkg() in setup_wizard_provider.dart |
| Background update check | PROF-05 | Add to SoulBackgroundHandler.onRepeatEvent() |
| Update notification UI | PROF-06 | New: banner in settings + notification |
| Crash recovery wiring | PROF-07 | Wire getInterruptedInstallation() into main.dart _initAndRun() |
| Pluggable profiles architecture | PROF-08 | Mostly done (manifest supports multiple profiles); document for community |
| Update check frequency setting | PROF-09 | New: SettingsKeys + BackgroundServiceSettings UI |
| Safe update extraction | PROF-10 | Already enforced — extraction targets $PREFIX only, not home |

## 7. Integration Points

### 1. main.dart `_initAndRun()` — Crash Recovery (PROF-07)
Insert after foreground service start, before setup wizard check:
```dart
// Check for interrupted profile pack installation
try {
  final packService = ProfilePackService();
  final interrupted = await packService.getInterruptedInstallation();
  if (interrupted != null) {
    _logger.w('Interrupted profile pack installation detected: $interrupted');
    // Store flag for UI to handle (show retry dialog)
    final settingsDao = container.read(settingsDaoProvider);
    await settingsDao.setString('interrupted_profile_install', interrupted);
  }
} catch (error) {
  _logger.e('Crash recovery check failed: $error');
}
```

### 2. SoulBackgroundHandler — Update Check (PROF-05, PROF-09)
Add to `onRepeatEvent()` alongside existing daily checks. Needs:
- New `_checkProfileUpdates()` method
- Direct File I/O for version marker reading (no Pigeon in background isolate)
- SettingsDao for last-check timestamp and frequency preference

### 3. setup_wizard_provider.dart — Tier 3 Improvements (PROF-04)
Modify `_installViaPkg()`:
- Run `pkg install` commands in parallel where independent
- Add estimated time based on package count
- Replace "Even geduld..." with per-package progress

### 4. .bashrc Shell Config — Lazy Install Hook (PROF-03)
Extend `writeShellConfig()` in setup_wizard_provider.dart to also write the `command_not_found_handle` function.

### 5. TermuxActivity or Terminal Output Stream — OSC 777 Detection (PROF-03)
Parse OSC 777 `soul-cnf` escape sequences from terminal output. Route to Flutter via existing `onTerminalOutput` or new dedicated Pigeon method.

### 6. BackgroundServiceSettings — Update Frequency UI (PROF-09)
Add profile update section after existing background service toggles.

### 7. Settings Screen — Update Banner (PROF-06)
New widget that watches `profile_update_available` setting and shows download option.

### 8. GitHub Actions — New Workflow (PROF-01)
New file: `.github/workflows/profile_pack_build.yml`

### 9. profile-packs/manifest.json — CI Auto-Update (PROF-01)
CI workflow updates manifest with real URLs, sha256, sizes after build.

## 8. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| QEMU aarch64 emulation too slow in CI | Build takes >1h | Medium | Cache the base $PREFIX snapshot; only run npm install under QEMU; set 360min timeout |
| npm global install creates broken native addons under emulation | Claude Code won't start | Low | Test pack on real device before publishing; CI can run basic `node -e "require('@anthropic-ai/claude-code')"` under QEMU |
| Profile pack zip too large (>500MB) | Slow download on mobile, storage pressure | Medium | Measure actual size; consider splitting npm node_modules into separate pack; strip unnecessary files (docs, tests, .map files) |
| Background update check fails silently | User never sees updates | Low | Log failures; add "last checked" timestamp visible in settings UI |
| OSC 777 escape not parsed by terminal emulator | Lazy install hook doesn't work | Low | Test with Termux's terminal-emulator library; fallback to text pattern matching if OSC not supported |
| `command_not_found_handle` overwritten by user or other tools | Lazy install breaks | Low | Check in shell config if function exists before overwriting; append SOUL logic, don't replace |
| Version marker file deleted by user | Update check thinks profile not installed | Low | Graceful fallback: treat missing marker as "not installed", offer fresh install |
| Interrupted install leaves $PREFIX in broken state | Terminal unusable | Medium | Crash recovery already has marker; offer "retry" or "clean up" (delete marker + suggest manual pkg install) |
| Background isolate cannot access Pigeon bridges | Cannot read version markers via bridge | High (confirmed) | Use direct File I/O from Dart to read `.soul-profile-{id}` marker files — no bridge needed |
| manifest.json fetch blocked (network, GitHub down) | Update check fails | Low | Catch exception, log, retry next cycle; cache last successful manifest locally |

## RESEARCH COMPLETE
