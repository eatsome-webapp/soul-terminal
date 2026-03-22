# Phase 12: Profile Pack System - Context

**Gathered:** 2026-03-22
**Status:** Ready for planning
**Source:** User discussion + codebase analysis

<domain>
## Phase Boundary

Replaces the 10-15 minute `pkg install` + `npm install` onboarding with a 3-tier installation system:
- Tier 1: Pre-built profile pack download+extract (<60s)
- Tier 2: Deferred/lazy install (skip at setup, install on first use)
- Tier 3: Improved pkg fallback (parallel, time estimates, better UX)

Plus: auto-update system, crash recovery, and pluggable profiles for open-source community.

**In scope:** GitHub Actions build pipeline, manifest system, setup wizard refactor, lazy install service, background update checker, update UI, crash recovery wiring, settings UI.

**Out of scope:** proot-distro profiles, custom package compilation, app self-update (APK), cloud profile sync.
</domain>

<decisions>
## Implementation Decisions

### Tier 1: Profile Pack Build Pipeline (PROF-01, PROF-02)
- GitHub Actions workflow builds profile packs using Termux Docker container
- Pack = zip of `$PREFIX` delta after `pkg install -y nodejs git gh && npm install -g @anthropic-ai/claude-code`
- Published as GitHub Release asset with SHA-256 checksum
- manifest.json updated with real URL, sha256, sizeBytes after build
- Profile pack is architecture-specific (aarch64 only for now)
- Pack version follows date-based scheme: `2026.03.22-r1`

### Tier 2: Lazy/Deferred Install (PROF-03)
- User selects "Terminal Only" or skips install → no packages installed
- When user types a command that requires missing binary (e.g., `claude`, `node`, `python`):
  - Detect via shell `command_not_found_handler` in .bashrc OR via Pigeon output monitoring
  - Show inline prompt: "X is niet geinstalleerd. Installeren via profile pack?"
  - If yes → trigger Tier 1 download or Tier 3 fallback
- Implementation: shell function in .bashrc that calls back to SOUL via OSC custom escape

### Tier 3: Improved Fallback (PROF-04)
- Current: sequential `pkg install` + `npm install` with 5min timeouts each
- Improved: show estimated time based on package count, parallel where possible
- `pkg install -y nodejs git gh` can run in parallel with download of large npm packages
- Progress: replace opaque "Even geduld..." with per-package status updates
- Timeout increased to 10 min per step (some networks are slow)

### Auto-Update System (PROF-05, PROF-06, PROF-09, PROF-10)
- Background check: fetch manifest (~1KB) every 24h in soul_background_handler.dart
- Compare remote version with local marker (`$PREFIX/.soul-profile-{id}`)
- If newer: store `profileUpdateAvailable` flag in SettingsDao
- NO automatic download — user decides (data costs money, especially on mobile)
- Update notification: subtle banner in settings screen, not intrusive
- Update flow: reuse existing ProfilePackService.downloadPack() + installPack()
- Update extracts over existing $PREFIX — only overwrites package files, NOT home directory
- User configurable: check frequency (daily/weekly/never) via settings UI
- Opt-in by default: check enabled, but download always manual

### Crash Recovery (PROF-07)
- ProfilePackInstaller already writes `.soul-profile-installing` marker during extraction
- getInterruptedInstallation() method exists in Java but is NEVER CALLED from Dart
- Wire into main.dart _initAndRun(): check for interrupted install on startup
- If found: offer retry or cleanup (delete partial extraction marker)

### Pluggable Profiles (PROF-08)
- manifest.json schema already supports multiple profiles
- Community profiles: fork repo, add profile entry to manifest, build pack via same workflow
- Future: support external manifest URLs (not in v1, just the architecture)
- Profile entry contains: id, name, description, icon, version, arch, sizeBytes, sha256, url

### Claude's Discretion
- Exact Docker image/approach for building Termux packages in CI
- command_not_found_handler implementation details for Tier 2
- Exact UI layout for update notification banner
- Whether to show download size before confirming update
- Notification channel for update-available (local notification vs in-app only)
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Setup Wizard (existing code to modify)
- `flutter_module/lib/ui/setup_wizard/setup_wizard_provider.dart` — Current installation logic (Tier 1/3 switching)
- `flutter_module/lib/ui/setup_wizard/setup_wizard_screen.dart` — Current wizard UI

### Profile Pack Infrastructure (existing, partially implemented)
- `flutter_module/lib/services/profile_pack/profile_pack_service.dart` — Download/install orchestration
- `flutter_module/lib/services/profile_pack/profile_manifest.dart` — Manifest model + isAvailable check
- `app/src/main/java/com/termux/app/ProfilePackInstaller.java` — Java extraction + version markers
- `app/src/main/java/com/termux/bridge/ProfilePackBridgeImpl.java` — Pigeon bridge to Java
- `profile-packs/manifest.json` — Remote manifest (currently empty URLs)

### Background Service (add update check here)
- `flutter_module/lib/services/platform/soul_background_handler.dart` — 15-min periodic handler
- `flutter_module/lib/ui/settings/background_service_settings.dart` — Settings UI for background tasks

### App Startup (wire crash recovery here)
- `flutter_module/lib/main.dart` — _initAndRun() initialization sequence

### CI/CD (model for new workflow)
- `.github/workflows/bootstrap_build.yml` — Existing bootstrap build workflow (pattern to follow)

### Database/Settings
- `flutter_module/lib/services/database/daos/settings_dao.dart` — SettingsKeys for persistence
</canonical_refs>

<specifics>
## Specific Ideas

- manifest.json wordt gefetcht van `https://raw.githubusercontent.com/eatsome-webapp/soul-terminal/master/profile-packs/manifest.json`
- Profile pack download directory: `/data/data/com.soul.terminal/cache/profile-packs`
- Version marker files: `$PREFIX/.soul-profile-{profileId}` (already implemented)
- Crash recovery marker: `$PREFIX/.soul-profile-installing` (already implemented)
- Background handler interval: bestaande 15-min cycle, update check 1x per 24u (use timestamp)
- Bootstrap build workflow als model: Docker cross-compile, SHA-256 checksum, GitHub Release
</specifics>

<deferred>
## Deferred Ideas

- External manifest URLs (third-party profile registries) — v2
- Differential/incremental updates (only changed files) — v2
- Profile rollback (keep previous version for downgrade) — v2
- ARM32 support — out of scope (aarch64 only)
- Profile dependency resolution (profile A requires profile B) — v2
</deferred>

---

*Phase: 12-profile-pack-system*
*Context gathered: 2026-03-22 via user discussion*
