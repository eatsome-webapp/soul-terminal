---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: unknown
stopped_at: Completed 02-C-PLAN.md — bootstrap integratie in soul-terminal app, debug APK gebouwd
last_updated: "2026-03-19T10:15:00.000Z"
progress:
  total_phases: 4
  completed_phases: 3
  total_plans: 16
  completed_plans: 15
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-19)

**Core value:** Een native terminal die naadloos integreert met SOUL — terminal + AI brain in één app.
**Current focus:** Phase 04 — terminal-enhancements

## Current Position

Phase: 04 (terminal-enhancements) — EXECUTING
Plan: 3 of 3 (04-C complete)

## Progress

Phase 1: 5/5 plans complete (100%)
Phase 2: 2/3 plans complete (67%)
Phase 3: 1+ plans executed (in progress)
Phase 4: 0 plans (not yet planned)

## Decisions Made

- **2026-03-19 | 02-C:** Relay repo (eatsome-webapp/soul-terminal, master) is de correcte locatie voor build.gradle — lokale soul-terminal dir wijst naar soul-app (Flutter app)
- **2026-03-19 | 02-C:** ABI splits beperkt tot arm64-v8a — NDK buildde bootstrap-arm.zip incbin die niet meer gedownload wordt (aarch64-only)
- **2026-03-19 | 02-C:** Workflow matrix verwijderd (apt-android-7 + apt-android-5) — soul-terminal gebruikt één bootstrap zonder packageVariant
- **2026-03-19 | 03-D:** Pigeon interface nesting: TerminalBridgeApi.TerminalBridgeApi en SystemBridgeApi.SystemBridgeApi — outer class is container, interface genest, setUp() statisch op interface
- **2026-03-19 | 03-D:** SoulBridgeController gebruikt TerminalBridgeApi.SoulBridgeApi — bidirectionele APIs gegroepeerd in één Pigeon file
- **2026-03-19 | 03-D:** SoulBridgeApi.setUp(null) in Dart dispose() — deregistreert message handler, voorkomt leaks
- **2026-03-19 | 04-B:** ConcurrentHashMap<TerminalSession, Long> voor rate limiting — thread-safe zonder synchronization overhead
- **2026-03-19 | 04-B:** TERMUX_TERMINAL_NOTIFICATION_ID_BASE = 2000 — ruim boven bestaande IDs (1337, 1338)
- **2026-03-19 | 04-B:** mNotificationChannelCreated flag — lazy init, voorkomt onnodige binder calls
- **2026-03-19 | 04-B:** mLastNotificationTime.remove(session) in removeFinishedSession — voorkomt geheugenlek
- **2026-03-19 | 04-A:** ESC_CSI_EQUALS = 20 — volgende beschikbare integer na ESC_CSI_EXCLAMATION = 19
- **2026-03-19 | 04-A:** mKittyKeyboardMode & 0x03 — alleen bits 0+1 (modes 1+2) ondersteund in v1
- **2026-03-19 | 04-A:** isTildeKey() returns false — CSI u format voor alle keys (Kitty spec staat dit toe)
- **2026-03-19 | 04-A:** Printable char Kitty encoding check: unicodeChar != event.getUnicodeChar(metaState)
- **2026-03-19 | 04-C:** ListView + BaseAdapter gebruikt (niet RecyclerView) — androidx.recyclerview is geen build.gradle dependency
- **2026-03-19 | 04-C:** TermuxSession is com.termux.shared.shell.TermuxSession, niet een inner class van TermuxService
- **2026-03-19 | 04-C:** toggleFlutterView() als stub toegevoegd — Phase 03 Flutter integratie vult de body in
- **2026-03-19 | 04-C:** Ctrl+Shift+P check vóór Ctrl+Alt block — specifieke combos hebben prioriteit boven generieke
- **2026-03-19 | 03-C:** setupFlutterFragment() logs warning (not crash) if engine not yet cached — async init race condition op trage devices
- **2026-03-19 | 03-C:** setSoulToggleButtonView() als aparte methode — consistent met setToggleKeyboardView/setNewSessionButtonView patroon
- **2026-03-19 | 03-B:** Pigeon-gegenereerde files handmatig aangemaakt — cmd-proxy token verlopen; equivalent aan dart run pigeon output
- **2026-03-19 | 03-B:** flutter_module/.gitignore whitelist voor *.g.dart — root home .gitignore sluit alle *.g.dart uit
- **2026-03-19 | 03-B:** SoulBridgeApi in TerminalBridgeApi.java gegroepeerd — Pigeon conventie voor bidirectionele APIs
- **2026-03-19 | 03-A:** android.nonTransitiveRClass=false — bestaande code gebruikt cross-module R class referenties; true zou alle imports breken
- **2026-03-19 | 03-A:** android.defaults.buildfeatures.buildconfig=true — AGP 8.x disabled BuildConfig generatie standaard, expliciet preserved
- **2026-03-19 | 03-A:** Java 17 alleen in app module gewijzigd — submodules in latere plannen indien nodig
- **2026-03-19 | 03-A:** package attribuut verwijderd uit app AndroidManifest.xml — namespace in build.gradle is nu de bron (AGP 8.x requirement)
- **2026-03-19 | 03-E:** flutter pub get only (no flutter build aar) — source inclusion via settings.gradle laat Gradle de Flutter build automatisch aanroepen
- **2026-03-19 | 03-E:** debug_build.yml branch trigger gecorrigeerd van master naar main — repo gebruikt main als default branch
- **2026-03-19 | 03-E:** Pigeon-gegenereerde files gecommit — CI hoeft geen aparte codegen stap te doen
- **2026-03-19 | 02-B:** bootstrap-build workflow: generate-bootstraps.sh direct op host (geen Docker) — GitHub Actions heeft geen FUSE/OverlayFS voor fuse-overlayfs die build-package.sh intern gebruikt
- **2026-03-19 | 02-B:** generate-bootstraps.sh patch: mkdir -p TERMUX__PREFIX__PROFILE_D_DIR — upstream bug, directory wordt niet aangemaakt vóór write
- **2026-03-19 | 02-B:** apt-repo: Packages index met 79 bootstrap packages gefilterd uit upstream termux-main; eigen .deb files niet gebouwd
- **2026-03-19 | 02-B:** Moderne bootstrap (2025+) heeft geen SYMLINKS.txt meer — symlinks als native zip entries, geen apart tekstbestand
- **2026-03-19 | 02-A:** eatsome-webapp is a user account, not org — gh repo fork --org flag not supported, forked directly
- **2026-03-19 | 02-A:** TERMUX_APP__NAMESPACE left as com.termux — Java namespace, per plan's "do not change Java paths" rule
- **2026-03-19 | 02-A:** TERMUX_REPO_APP derived paths updated explicitly (hardcoded, not auto-derived from TERMUX_APP__PACKAGE_NAME)
- **2026-03-19 | 02-A:** dpkg/gawk patch com.termux occurrences are comment-only examples, not functional package name refs — unchanged
- **2026-03-19 | 01-C:** No existing debug_build.yml found — created from scratch (workflows dir did not exist)
- **2026-03-19 | 01-C:** Release build produces universal APK only (splitAPKsForReleaseBuilds=0 is Termux default)
- **2026-03-19 | 01-B:** Raster PNG launcher icons are solid-color placeholders (#1A1A2E) — proper rendered icons to be generated via Android Studio Image Asset tool once Termux source is cloned
- **2026-03-19 | 01-B:** styles.xml and colors.xml created fresh (Termux source not yet in repo — Plan 01-A prerequisite pending)
- **2026-03-19 | 01-A:** Java namespace `com.termux` preserved in build.gradle namespace — alleen applicationId verandert naar `com.soul.terminal`
- **2026-03-19 | 01-A:** sharedUserId verwijderd — SOUL Terminal is standalone, geen Termux plugin-compatibiliteit nodig
- **2026-03-19 | 01-A:** foregroundServiceType="specialUse" — passend voor terminal emulator op Android 14+
- **2026-03-19 | 01-A:** desugar_jdk_libs bumped naar 2.1.3 voor targetSdk 34

## Execution Metrics

| Phase | Plan | Duration | Tasks | Files |
|-------|------|----------|-------|-------|
| 03 | D | 20 min | 6 | 6 |
| 04 | B | 20 min | 7 | 7 |
| 03 | C | 15 min | 7 | 5 |
| 04 | A | 25 min | 4 | 3 |
| 04 | C | 15 min | 4 | 5 |
| 03 | B | 12 min | 4 | 9 |
| 03 | A | 20 min | 10 | 9 |
| 03 | E | 8 min | 4 | 2 |
| 02 | B | 30 min | 4 | 3 |
| 02 | A | 13 min | 6 | 4 |
| 01 | E | 8 min | 9 | 8 |
| 01 | D | 5 min | 6 | 254 |
| 01 | C | 8 min | 2 | 2 |
| 01 | B | 14 min | 4 | 15 |
| 01 | A | 25 min | 10 | 8 |

## Session Continuity

- **Stopped at:** Completed 03-D-PLAN.md — Pigeon bridge implementation, bidirectionele Flutter↔terminal communicatie
- **Resume file:** None
- **Next:** 03-D klaar — bidirectionele Pigeon bridge volledig; volgende plan in fase 03 bepalen
