# Phase 9: SOUL Terminal Awareness - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

De AI (SOUL) kan de terminal aansturen en observeren. Commando's sturen via gestructureerde API, output lezen en verwerken, destructieve acties blokkeren met bevestigingsdialoog, API keys filteren uit memory logs, en de gebruiker informeren over activiteit via UI indicators. Security whitelist moet geïmplementeerd zijn vóórdat het AI→terminal pad live gaat.

</domain>

<decisions>
## Implementation Decisions

### Command execution model
- Gestructureerde API: `runCommand(executable, args[])` — nooit raw shell string (SM-1 uit STATE.md)
- Bestaande `executeCommand(String command)` in TerminalBridgeImpl vervangen/uitbreiden met gestructureerde variant
- Dedicated awareness sessie die SOUL zelf aanmaakt — voorkomt conflict met gebruikerssessies
- OSC 133 `\033]133;D\007` parsing in TerminalEmulator met callback naar TerminalSessionClient voor commando-klaar detectie
- Seriële executie: wacht op OSC 133 completion marker voordat volgend commando gestuurd wordt — geen race conditions
- Queue in Dart-side SoulAwarenessService: commando's worden ingediend en serieel afgehandeld

### Security whitelist (AWAR-05) — MOET EERST
- Blacklist van destructieve patronen: `rm -rf`, `dd if=`, `mkfs`, `git reset --hard`, `:(){:|:&};:`, `chmod -R 777`, `> /dev/sda`
- Pattern matching op de gestructureerde command args — niet op raw string (voorkomt shell injection bypass)
- Native Android AlertDialog bij destructief commando detectie — blokkeert executie tot gebruiker bevestigt
- Geen bypass/skip optie — destructieve commando's vereisen altijd bevestiging
- Implementatievolgorde binnen fase: whitelist (AWAR-05) → API key filter (AWAR-06) → ANSI strip (AWAR-07) → sendInput + output (AWAR-01/02) → OSC 133 (AWAR-03) → UI (AWAR-04/08)

### API key / wachtwoord filtering (AWAR-06)
- Regex blacklist op output vóór opslag in SOUL memory: `sk-ant-...`, `sk-...`, `ghp_...`, `github_pat_...`, `ANTHROPIC_API_KEY=...`, wachtwoordvelden
- Terminal zelf toont alles ongewijzigd — filtering alleen op het pad naar SOUL AI context/memory
- Filtering in Dart-side SoulAwarenessService, niet in Java bridge

### Output pipeline (AWAR-02, AWAR-07)
- ANSI escape code stripping in Dart-side SoulAwarenessService — Java stuurt raw transcript via Pigeon
- Bestaande SoulBridgeController.onTerminalTextChanged() als basis — al 100ms debounce, max 10 updates/sec
- Laatste 50 regels per update (consistent met bestaand patroon in SoulBridgeController)
- Volledige transcript niet nodig — laatste 50 regels is voldoende voor AI context in v1.1

### UI indicators (AWAR-04, AWAR-08)
- "Uitvoeren in terminal..." indicator als compact card in SOUL chat UI (systeembericht stijl)
- Card toont commando naam + spinner, verdwijnt na OSC 133 completion
- Tappable: tik op indicator card opent terminal sheet naar half-expanded (AWAR-08)
- Eén indicator tegelijk — seriële executie, geen meerdere simultane commando's
- Gebruiker kan altijd sheet handmatig openen via drag handle om lopend commando te observeren

### Claude's Discretion
- Exacte regex patronen voor API key filtering
- ANSI stripping implementatie (regex vs parser library)
- OSC 133 callback interface naam en signature
- SoulAwarenessService interne queue implementatie
- Indicator card visueel ontwerp (kleuren, animatie)
- Hoe dedicated awareness sessie visueel verschilt van user sessies in tab bar

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Pigeon bridge (uit te breiden)
- `flutter_module/pigeons/terminal_bridge.dart` — Pigeon definitie: TerminalBridgeApi (HostApi) + SoulBridgeApi (FlutterApi) — nieuwe methods nodig voor gestructureerde command API
- `app/src/main/java/com/termux/bridge/TerminalBridgeImpl.java` — Java HostApi implementatie: huidige `executeCommand(String)` moet uitgebreid met `runCommand(executable, args[])`
- `app/src/main/java/com/termux/bridge/SoulBridgeController.java` — Debounced output streaming naar Flutter, `onTerminalTextChanged()` — basis voor AWAR-02
- `flutter_module/lib/generated/terminal_bridge.g.dart` — Generated Dart Pigeon code

### Terminal emulator (OSC 133)
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` — `doOscSetTextParameters()` r2050: parst OSC sequences, geen handler voor 133 — moet toegevoegd
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalSession.java` — Session lifecycle, `TerminalSessionClient` callback interface
- `terminal-emulator/src/test/java/com/termux/terminal/OperatingSystemControlTest.java` — Bestaande OSC tests, model voor OSC 133 tests

### Session management
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` — `addNewSession()`, `setCurrentSession()` — voor dedicated awareness sessie
- `app/src/main/java/com/termux/app/TermuxService.java` — `createTermuxSession()` — sessie lifecycle

### Layout (sheet interactie)
- `app/src/main/java/com/termux/app/TermuxActivity.java` — `getBottomSheetBehavior()` — voor UI indicator → sheet open actie

### Security
- `.planning/ROADMAP.md` §Phase 9 — Expliciete security-first implementatievolgorde en destructieve patronen lijst
- `.planning/STATE.md` §Accumulated Context — SM-1 (gestructureerde command API), CP-5 (OSC 133 configuratie)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **SoulBridgeController**: Heeft al debounced output streaming (100ms, 50 regels) — direct herbruikbaar voor AWAR-02
- **TerminalBridgeImpl**: Heeft al `executeCommand()`, `createSession()`, sessie management — uitbreiden voor awareness
- **TerminalEmulator.doOscSetTextParameters()**: OSC parser framework aanwezig — hook voor OSC 133 toevoegen
- **SessionInfo Pigeon class**: Al gedefinieerd met id/name/isRunning — herbruikbaar
- **Handler(Looper.getMainLooper()).post{}**: Bestaand patroon voor Pigeon calls vanuit achtergrond threads (CP-4)

### Established Patterns
- **Java only** in Android modules — geen Kotlin
- **Pigeon bridge**: Definitie in pigeons/terminal_bridge.dart, genereren naar Java + Dart
- **Debounced output**: SoulBridgeController pattern met Handler + postDelayed
- **Service-bound sessions**: Terminal processen leven in TermuxService, niet view-bound

### Integration Points
- **Pigeon definitie**: Nieuwe methods toevoegen aan TerminalBridgeApi (HostApi) voor gestructureerde command execution
- **TerminalEmulator**: OSC 133 handler toevoegen in doOscSetTextParameters() switch
- **TerminalSessionClient**: Nieuwe callback voor OSC 133 completion events
- **SoulBridgeController**: Uitbreiden met command completion events naast output streaming
- **Flutter SOUL chat UI**: Indicator card widget toevoegen
- **BottomSheetBehavior**: Programmatisch openen vanuit indicator tap (via getBottomSheetBehavior())

</code_context>

<specifics>
## Specific Ideas

- Security-first: whitelist code moet volledig getest en werkend zijn vóórdat sendInput live gaat — geen shortcuts
- Dedicated awareness sessie moet visueel herkenbaar zijn in tab bar (bijv. "SOUL" label of icoon) maar niet closable door gebruiker
- OSC 133 is shell-afhankelijk — bash en zsh hebben verschillende configuratie nodig (PROMPT_COMMAND vs precmd) — onboarding (Phase 10) configureert dit
- API key patronen moeten breed genoeg zijn om varianten te vangen (sk-ant-api03-..., ghp_..., etc.) maar geen false positives op gewone strings

</specifics>

<deferred>
## Deferred Ideas

- Multi-step command sequences zonder per-stap bevestiging — v2 (AUTO-01)
- Automatische error uitleg met suggesties — v2 (AUTO-02)
- Semantische command history — v2 (AUTO-03)

</deferred>

---

*Phase: 09-soul-terminal-awareness*
*Context gathered: 2026-03-21*
