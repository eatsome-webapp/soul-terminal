---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: — Foundation
status: unknown
last_updated: "2026-03-20T21:42:20.665Z"
progress:
  total_phases: 11
  completed_phases: 4
  total_plans: 17
  completed_plans: 16
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-20)

**Core value:** Een native terminal die naadloos integreert met SOUL — terminal + AI brain in één app.
**Current focus:** Phase 05 — terminal-quick-wins

## Current Position

Phase: 05 (terminal-quick-wins) — COMPLETE
Plan: 1 of 1 — complete (2026-03-20)
Resume: .planning/phases/05-terminal-quick-wins/05-01-SUMMARY.md

## v1.1 Phase Overview

| # | Phase | Status | Requirements |
|---|-------|--------|-------------|
| 5 | Terminal Quick Wins | Pending | TERM-04..07 (4) |
| 6 | App Merge | Pending | MERG-01..09 (9) |
| 7 | Bottom Sheet Layout | Pending | LAYT-01..06 (6) |
| 8 | Session Management | Pending | SESS-01..06 (6) |
| 9 | SOUL Terminal Awareness | Pending | AWAR-01..08 (8) |
| 10 | Onboarding Flow | Pending | ONBR-01..07 (7) |
| 11 | UX Polish | Pending | UXPL-01..07 (7) |

## Accumulated Context

### From v1.0

- Pigeon interface nesting: outer class is container, interface genest, setUp() statisch
- android.nonTransitiveRClass=false — bestaande code gebruikt cross-module R class referenties
- android.defaults.buildfeatures.buildconfig=true — AGP 8.x compatibility
- Java 17 alleen in app module
- flutter pub get only (no flutter build aar) — source inclusion via settings.gradle
- ListView + BaseAdapter (niet RecyclerView) — geen androidx.recyclerview dependency
- TermuxSession is com.termux.shared.shell.TermuxSession
- Bootstrap: moderne format (2025+), geen SYMLINKS.txt, arm64-v8a only

### From v1.1 Research

- `windowSoftInputMode="adjustPan"` + `ViewCompat.setOnApplyWindowInsetsListener` voor IME in BottomSheet (CP-1)
- Dedicated `BottomSheetDragHandleView` + `NestedScrollingChild3` in TerminalView voor touch conflict (CP-2)
- HyperOS detectie bij onboarding voor Xiaomi battery/autostart instructies (CP-3)
- `Handler(Looper.getMainLooper()).post{}` wrapper voor Pigeon calls vanuit PTY reader thread (CP-4)
- OSC 133 `\033]133;D\007` voor commando-klaar detectie, configureren via onboarding (CP-5)
- Security: gestructureerde command API (`runCommand(executable, args[])`) vóór AI→terminal live (SM-1)
- AWAR-05 whitelist moet geïmplementeerd zijn vóór AWAR-01/02 live gaan
- `ViewPager2:1.1.0` voor sessie-tabs (vervangt deprecated ViewPager v1)
- `datastore-preferences:1.1.5` voor API key opslag (EncryptedSharedPreferences is deprecated)
- `RenderEffect` blur API 31+ — al beschikbaar in bestaande dependencies
- ProviderScope refactoring (MERG-04) is de zwaarste merge taak
