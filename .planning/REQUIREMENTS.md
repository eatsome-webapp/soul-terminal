# Requirements: SOUL Terminal

**Defined:** 2026-03-20
**Core Value:** Een native terminal die naadloos integreert met SOUL — terminal + AI brain in één app.

## v1.1 Requirements

Requirements for milestone v1.1: Van terminal naar AI coding omgeving.

### Terminal Config

- [ ] **TERM-04**: User ziet scrollback buffer van 20.000 regels (was 2.000)
- [ ] **TERM-05**: User heeft extra keys layout geoptimaliseerd voor Claude Code
- [ ] **TERM-06**: User ziet SOUL kleurthema als default (bg #0F0F23, fg #E0E0E0, cursor #6C63FF)
- [ ] **TERM-07**: User ziet SOUL kleuren in drawer, extra keys en app chrome (#6C63FF accent)

### App Merge

- [x] **MERG-01**: SOUL app Dart code (339 files) gekopieerd naar soul-terminal flutter_module
- [x] **MERG-02**: pubspec.yaml gemerged (52 deps incl. ObjectBox, Drift, foreground_task)
- [x] **MERG-03**: AndroidManifest.xml gemerged (permissies, services, boot receiver)
- [ ] **MERG-04**: ProviderScope gerefactored voor FlutterFragment context (niet main.dart)
- [x] **MERG-05**: Database pad geunificeerd (Drift + ObjectBox werken in com.soul.terminal context)
- [x] **MERG-06**: Foreground service coëxistentie met Termux's eigen service
- [ ] **MERG-07**: SOUL chat UI functioneel als hoofdscherm in FlutterFragment
- [ ] **MERG-08**: CI/CD bouwt merged app succesvol (52 Flutter deps + Android)
- [x] **MERG-09**: API key invoer werkt in merged context (Android Keystore onder com.soul.terminal)

### Layout

- [ ] **LAYT-01**: User ziet Flutter (SOUL chat) als hoofdscherm bij app start
- [ ] **LAYT-02**: User kan terminal omhoog slepen als bottom sheet via handle bar
- [ ] **LAYT-03**: User kan sheet in 4 states gebruiken: hidden, collapsed (peek), half-expanded (40%), expanded (full)
- [ ] **LAYT-04**: User kan keyboard gebruiken in terminal sheet zonder layout glitches
- [ ] **LAYT-05**: User kan back button gebruiken om sheet te sluiten zonder app te sluiten
- [ ] **LAYT-06**: Terminal process draait door ongeacht sheet state

### Session Management

- [ ] **SESS-01**: User ziet tab bar met sessienamen bovenaan terminal sheet
- [ ] **SESS-02**: User ziet process namen in tabs (claude, bash, python via /proc/PID/cmdline)
- [ ] **SESS-03**: User kan nieuwe sessie aanmaken via + knop in tab bar
- [ ] **SESS-04**: User kan sessie hernoemen of sluiten via lang indrukken op tab
- [ ] **SESS-05**: User kan swipen links/rechts om van sessie te wisselen
- [ ] **SESS-06**: SOUL chat kan sessies aanmaken en sluiten via Pigeon

### SOUL Awareness

- [ ] **AWAR-01**: SOUL kan commando's sturen naar terminal sessie via sendInput
- [ ] **AWAR-02**: SOUL ontvangt terminal output stream via Pigeon bridge
- [ ] **AWAR-03**: SOUL detecteert wanneer commando klaar is via OSC 133 prompt markers
- [ ] **AWAR-04**: SOUL toont "Uitvoeren in terminal..." indicator bij actief commando
- [ ] **AWAR-05**: SOUL vraagt bevestiging voor destructieve commando's (rm -rf, git reset, etc.)
- [ ] **AWAR-06**: API keys en wachtwoorden worden niet gelogd in SOUL memory
- [ ] **AWAR-07**: Terminal output wordt gestript van ANSI escape codes voor AI context
- [ ] **AWAR-08**: User kan altijd sheet openen om te zien wat SOUL doet

### Onboarding

- [ ] **ONBR-01**: User ziet welkomstscherm bij eerste start met keuze: Claude Code / Python / Alleen terminal
- [ ] **ONBR-02**: SOUL installeert gekozen packages op achtergrond met voortgang in chat
- [ ] **ONBR-03**: User kan API key invoeren in SOUL chat, opgeslagen via Android Keystore
- [ ] **ONBR-04**: User kan GitHub CLI authenticeren via SOUL chat flow
- [ ] **ONBR-05**: User krijgt HyperOS battery/autostart instructies op Xiaomi devices
- [ ] **ONBR-06**: Onboarding configureert .bashrc/.zshrc met OSC 133 prompt markers
- [ ] **ONBR-07**: User ziet "Je omgeving is klaar" na voltooiing

### UX Polish

- [ ] **UXPL-01**: User kan bestandspaden in terminal output lang indrukken om te kopiëren/openen
- [ ] **UXPL-02**: Claude Code y/n prompts worden automatisch als native Android dialog getoond
- [ ] **UXPL-03**: Sheet expand is velocity-based: snel omhoog = altijd full screen
- [ ] **UXPL-04**: User ziet lichte blur achter sheet (SOUL UI wazig zichtbaar)
- [ ] **UXPL-05**: User voelt haptic feedback bij sheet open/close/switch
- [ ] **UXPL-06**: In landscape wordt terminal sheet een side drawer (rechts), SOUL chat links
- [ ] **UXPL-07**: App heeft content descriptions en TalkBack support

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### AI Autonomy

- **AUTO-01**: SOUL voert multi-step command sequences uit zonder per-stap bevestiging
- **AUTO-02**: SOUL legt automatisch terminal errors uit met suggesties
- **AUTO-03**: Semantische command history (zoek op wat het deed, niet exacte tekst)

### Terminal Advanced

- **TADV-01**: Inline image rendering in terminal (sixel/kitty graphics)
- **TADV-02**: Split panes (meerdere terminals naast elkaar)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Warp-stijl terminal Blocks | Jaren werk, upstream incompatibel met Termux rendering |
| Cloud sync | Lokaal-eerst architectuur, privacy prioriteit |
| iOS versie | Android-only terminal fork |
| Eigen terminal emulator | Termux's terminal-emulator is bewezen en onderhouden |
| Plugin apps (Termux:Float etc.) | Niet nodig — SOUL vervangt plugin functionaliteit |
| Data migratie soul-app → soul-terminal | Eenmalige handmatige actie, geen app feature |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| TERM-04 | Phase 5 — Terminal Quick Wins | Pending |
| TERM-05 | Phase 5 — Terminal Quick Wins | Pending |
| TERM-06 | Phase 5 — Terminal Quick Wins | Pending |
| TERM-07 | Phase 5 — Terminal Quick Wins | Pending |
| MERG-01 | Phase 6 — App Merge | Complete |
| MERG-02 | Phase 6 — App Merge | Complete |
| MERG-03 | Phase 6 — App Merge | Complete |
| MERG-04 | Phase 6 — App Merge | Pending |
| MERG-05 | Phase 6 — App Merge | Complete |
| MERG-06 | Phase 6 — App Merge | Complete |
| MERG-07 | Phase 6 — App Merge | Pending |
| MERG-08 | Phase 6 — App Merge | Pending |
| MERG-09 | Phase 6 — App Merge | Complete |
| LAYT-01 | Phase 7 — Bottom Sheet Layout | Pending |
| LAYT-02 | Phase 7 — Bottom Sheet Layout | Pending |
| LAYT-03 | Phase 7 — Bottom Sheet Layout | Pending |
| LAYT-04 | Phase 7 — Bottom Sheet Layout | Pending |
| LAYT-05 | Phase 7 — Bottom Sheet Layout | Pending |
| LAYT-06 | Phase 7 — Bottom Sheet Layout | Pending |
| SESS-01 | Phase 8 — Session Management | Pending |
| SESS-02 | Phase 8 — Session Management | Pending |
| SESS-03 | Phase 8 — Session Management | Pending |
| SESS-04 | Phase 8 — Session Management | Pending |
| SESS-05 | Phase 8 — Session Management | Pending |
| SESS-06 | Phase 8 — Session Management | Pending |
| AWAR-01 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-02 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-03 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-04 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-05 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-06 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-07 | Phase 9 — SOUL Terminal Awareness | Pending |
| AWAR-08 | Phase 9 — SOUL Terminal Awareness | Pending |
| ONBR-01 | Phase 10 — Onboarding Flow | Pending |
| ONBR-02 | Phase 10 — Onboarding Flow | Pending |
| ONBR-03 | Phase 10 — Onboarding Flow | Pending |
| ONBR-04 | Phase 10 — Onboarding Flow | Pending |
| ONBR-05 | Phase 10 — Onboarding Flow | Pending |
| ONBR-06 | Phase 10 — Onboarding Flow | Pending |
| ONBR-07 | Phase 10 — Onboarding Flow | Pending |
| UXPL-01 | Phase 11 — UX Polish | Pending |
| UXPL-02 | Phase 11 — UX Polish | Pending |
| UXPL-03 | Phase 11 — UX Polish | Pending |
| UXPL-04 | Phase 11 — UX Polish | Pending |
| UXPL-05 | Phase 11 — UX Polish | Pending |
| UXPL-06 | Phase 11 — UX Polish | Pending |
| UXPL-07 | Phase 11 — UX Polish | Pending |

**Coverage:**
- v1.1 requirements: 47 total
- Mapped to phases: 47
- Unmapped: 0

---
*Requirements defined: 2026-03-20*
*Last updated: 2026-03-20 after initial definition*
