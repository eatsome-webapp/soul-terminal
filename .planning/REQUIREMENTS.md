# Requirements: SOUL Terminal

**Defined:** 2026-03-19
**Core Value:** Een native terminal die naadloos integreert met SOUL — zodat Claude Code, de AI brain, en de terminal in één app leven zonder compromis op terminal performance.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Rebranding

- [ ] **REBR-01**: App draait met package name `com.soul.terminal` (applicationId gewijzigd)
- [ ] **REBR-02**: App toont naam "SOUL Terminal" in launcher en app info
- [ ] **REBR-03**: Custom launcher icon met SOUL branding
- [ ] **REBR-04**: UI theming aangepast aan SOUL kleurschema
- [ ] **REBR-05**: sharedUserId verwijderd (geen plugin compat nodig)
- [ ] **REBR-06**: targetSdk verhoogd naar minimaal 34 (Play Store vereiste)

### Bootstrap

- [ ] **BOOT-01**: Fork van termux-packages met `com.soul.terminal` prefix in properties.sh
- [ ] **BOOT-02**: Bootstrap packages gebouwd voor aarch64 via Docker cross-compilatie
- [ ] **BOOT-03**: Bootstrap checksums bijgewerkt in app/build.gradle
- [ ] **BOOT-04**: Eigen apt repository opgezet (GitHub Releases of CDN)
- [ ] **BOOT-05**: `pkg install` werkt correct met eigen repository

### Flutter Module

- [ ] **FLUT-01**: Flutter module aangemaakt als subdirectory (`flutter_module/`)
- [ ] **FLUT-02**: FlutterEngine singleton pre-warmed in Application.onCreate()
- [ ] **FLUT-03**: FlutterFragment geïntegreerd in TermuxActivity met toggle
- [ ] **FLUT-04**: GeneratedPluginRegistrant.registerWith() correct aangeroepen
- [ ] **FLUT-05**: Layout toggle tussen terminal-fullscreen en Flutter-fullscreen

### Pigeon Bridge

- [ ] **PIGB-01**: Pigeon schema gedefinieerd (TerminalBridge, SoulBridge, SystemBridge)
- [ ] **PIGB-02**: TerminalBridge: Flutter kan commando's uitvoeren in terminal
- [ ] **PIGB-03**: SoulBridge: Host pusht terminal output naar Flutter (debounced, max 10/sec)
- [ ] **PIGB-04**: Bidirectionele communicatie werkt betrouwbaar
- [ ] **PIGB-05**: cmd-proxy functionaliteit volledig vervangen door Pigeon bridge

### CI/CD

- [ ] **CICD-01**: GitHub Actions workflow bouwt debug APK automatisch
- [ ] **CICD-02**: Release signing via GitHub Secrets
- [ ] **CICD-03**: Twee-stage build: Flutter module eerst, dan Gradle assembleRelease
- [ ] **CICD-04**: Bootstrap build als aparte workflow (zeldzaam, handmatig te triggeren)

### Terminal Features

- [ ] **TERM-01**: Kitty keyboard protocol ondersteuning in terminal-emulator
- [ ] **TERM-02**: OSC9 desktop notifications (terminal → Android notificatie)
- [ ] **TERM-03**: Command palette met fuzzy search (sessies, commands, history)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### AI Features

- **SOUL-01**: AI command suggestions op basis van terminal context
- **SOUL-02**: AI error explanation met automatische foutanalyse
- **SOUL-03**: Smart command history met semantisch zoeken
- **SOUL-04**: Context-aware autocomplete
- **SOUL-05**: Terminal-to-SOUL handoff ("SOUL, deploy dit")

### Advanced Terminal

- **ADVT-01**: Inline image support (Kitty graphics protocol)
- **ADVT-02**: Split panes (native, zonder tmux)
- **ADVT-03**: Session restore na app restart

### SOUL Brain Integration

- **BRAIN-01**: Claude API integratie via Flutter module
- **BRAIN-02**: Chat UI in Flutter overlay
- **BRAIN-03**: Memory layer (Drift + ObjectBox) in Flutter module

## Out of Scope

| Feature | Reason |
|---------|--------|
| iOS versie | Android-only terminal fork |
| Eigen terminal emulator library | Termux's terminal-emulator is bewezen en stabiel |
| Plugin apps (Termux:Float, Termux:API) | SOUL Terminal is self-contained |
| GUI file manager | Terminal users gebruiken ranger/lf/yazi |
| Built-in code editor | Neovim/Helix in terminal is beter |
| Multi-device sync | v1 is local-first |
| Web terminal | Native Android app |
| Root-only features | Target device heeft geen root |
| AccessibilityService | Verboden door Play Store sinds jan 2026 |
| Persona selector UI | SOUL is een entiteit |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| (populated by roadmapper) | | |

**Coverage:**
- v1 requirements: 25 total
- Mapped to phases: 0
- Unmapped: 25

---
*Requirements defined: 2026-03-19*
*Last updated: 2026-03-19 after initial definition*
