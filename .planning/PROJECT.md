# SOUL Terminal

## What This Is

Een fork van Termux die wordt omgebouwd tot de terminal-laag van SOUL. Draait naast (en later geïntegreerd in) de SOUL Flutter app. Biedt een native Android terminal met eigen branding, custom bootstrap, en uiteindelijk een embedded Flutter module voor de SOUL AI interface — alles in één APK.

## Core Value

Een native terminal die naadloos integreert met SOUL — zodat Claude Code, de AI brain, en de terminal in één app leven zonder compromis op terminal performance.

## Requirements

### Validated

- [x] Rebranding: package name `com.soul.terminal`, app naam "SOUL Terminal" — Validated in Phase 1: Foundation
- [x] Custom launcher icon en UI theming (SOUL branding) — Validated in Phase 1: Foundation
- [x] Flutter module embedding (FlutterFragment naast terminal) — Validated in Phase 3: Flutter Integration
- [x] Pigeon bridge interface (Flutter ↔ Java communicatie) — Validated in Phase 3: Flutter Integration
- [x] CI/CD: gecombineerde build pipeline (terminal + Flutter module) — Validated in Phase 3: Flutter Integration
- [x] Eliminatie van cmd-proxy via native Pigeon bridge — Validated in Phase 3: Flutter Integration
- [x] Terminal features: Kitty keyboard protocol, OSC9 notifications, command palette — Validated in Phase 4: Terminal Enhancements
- [x] Terminal quick wins: scrollback 20k, Claude Code extra keys, SOUL kleurthema — Validated in Phase 5: Terminal Quick Wins
- [x] App merge: SOUL Flutter app (191 source files) gemerged in flutter_module — Validated in Phase 6: App Merge
- [x] Bottom sheet terminal: CoordinatorLayout + BottomSheet met 4 states — Validated in Phase 7: Bottom Sheet Layout
- [x] Session management: TabLayout tab bar, process namen, swipe, Pigeon API — Validated in Phase 8: Session Management

### Active
- [ ] Pigeon bridge: terminal/sessie/output APIs (uitgebreid in Phase 8, consumer in Phase 9)
- [ ] SOUL terminal awareness (AI kan terminal gebruiken)
- [ ] Onboarding flow (eerste start → werkende dev environment)
- [ ] UX polish (path tap-copy, native permission dialogs, landscape)

### Out of Scope

- iOS — Android-only terminal fork
- Eigen terminal emulator library — we gebruiken Termux's terminal-emulator/terminal-view
- Multi-device sync — lokaal-eerst
- Plugin apps (Termux:Float, Termux:API etc.) — niet nodig in v1

## Current Milestone: v1.1 Van terminal naar AI coding omgeving

**Goal:** SOUL Terminal transformeren van een rebranded Termux naar een volwaardige AI coding omgeving — Flutter als hoofdscherm, terminal als bottom sheet, SOUL kan zelfstandig terminal gebruiken, en een onboarding flow die nieuwe gebruikers meteen productief maakt.

**Target features:**
- Terminal quick wins (scrollback, extra keys, kleurthema)
- Flutter module als hoofdscherm met bottom sheet terminal
- Pigeon bridge voor type-safe Flutter ↔ terminal communicatie
- Session management met tab bar
- SOUL terminal awareness (AI stuurt terminal aan)
- Onboarding flow voor eerste start
- UX polish voor open source lancering

## Context

- Fork van termux/termux-app (master branch)
- Architectuurbeslissing: **Termux + FlutterFragment** (optie B) gekozen boven Flutter + PlatformView, native Android, WebView, en pure Dart terminal
- Requires fork van termux/termux-packages voor custom bootstrap met nieuw prefix
- Draait op Xiaomi 17 Ultra (aarch64), Android, geen root
- GitHub Actions voor builds — nooit lokaal bouwen
- Uiteindelijk vervangt dit zowel Termux als de standalone SOUL app

## Constraints

- **Package name**: `com.soul.terminal` — alle bootstrap packages moeten hiermee gebouwd worden
- **Architectuur**: aarch64 only (Xiaomi 17 Ultra)
- **Geen root**: alles moet werken zonder root access
- **Termux upstream**: minimale wijzigingen aan core om merge conflicts bij updates te beperken
- **Flutter embedding**: add-to-app pattern, FlutterFragment, geen PlatformView voor terminal

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Termux + FlutterFragment (optie B) | Native terminal performance, geen jank, Claude Code werkt out-of-the-box | ✓ Validated Phase 3 |
| Eigen bootstrap i.p.v. Termux repos | Package name wijziging vereist herbouw van alle packages | — Pending |
| Pigeon bridge i.p.v. cmd-proxy | In-process communicatie, geen HTTP/token overhead, veiliger | ✓ Validated Phase 3 |

---
*Last updated: 2026-03-21 after Phase 8: Session Management completed*
