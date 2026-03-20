# Features Research: SOUL Terminal

## v1.1 — Van terminal naar AI coding omgeving

*Bijgewerkt: 2026-03-20 — Focus op bottom sheet terminal, session management, SOUL terminal awareness, onboarding, en UX polish*

---

## Table Stakes

Features die gebruikers verwachten van een Android terminal. Zonder deze verlaten ze de app.

### Van Termux geerfde table stakes (gratis)
| Feature | Status |
|---------|--------|
| Bash/Zsh shell | Inherited |
| Package manager (pkg/apt) | Inherited — vereist custom bootstrap voor com.soul.terminal |
| Multiple sessions | Inherited — swipe-drawer UI |
| Persistent sessions (survive app switch) | Inherited — foreground service |
| Copy/paste support | Inherited |
| Extra keys row (Ctrl, Alt, Tab, etc.) | Inherited |
| Configurable font/size/theme | Inherited |
| True color (24-bit) | Inherited |
| Unicode/emoji rendering | Inherited |
| SSH client | Inherited via packages |
| Foreground service notification | Inherited — verplicht op Android 12+ |
| Storage access | Inherited via termux-setup-storage |
| URL detection | Inherited |

**Totaal inherited: ~13 features gratis.** Strategische reden om te forken i.p.v. from scratch.

### V1.0 al gebouwd (niet te vergeten)
| Feature | Status |
|---------|--------|
| SOUL branding (naam, icoon, kleurthema) | Gebouwd in Phase 1 |
| Flutter module embedding (FlutterFragment) | Gebouwd in Phase 3 |
| Pigeon bridge (terminal control, session info, output streaming) | Gebouwd in Phase 3 |
| Kitty keyboard protocol | Gebouwd in Phase 4 |
| OSC9 notifications | Gebouwd in Phase 4 |
| Command palette | Gebouwd in Phase 4 |
| CI/CD pipeline | Gebouwd in Phase 1+3 |

---

## v1.1 Feature Analyse: Hoe doen andere apps dit?

### 1. Bottom Sheet Terminal

**Patroon:** Flutter hoofdscherm (SOUL AI) is de primaire view. Terminal schuift omhoog als een Persistent Bottom Sheet — altijd beschikbaar, nooit volledig verdwenen.

**Hoe vergelijkbare apps dit doen:**
- **Android Material Design**: Twee varianten — Modal (dimmed overlay, voor kortdurend gebruik) en Persistent (permanent aanwezig, schuifbaar). Voor een terminal is Persistent de juiste keuze: terminal moet altijd bereikbaar zijn zonder context te verliezen.
- **Google Maps / Music Players**: Klassiek patroon — kaart/content op hoofdscherm, mini-player/info-panel schuift omhoog. Drie toestanden: gecollapsed (peek), half-open, volledig open.
- **Termius (Android)**: Meerder sessies in tabs, scherm volledig gevuld met terminal. Geen AI overlay. Split-view alleen in landscape.
- **JuiceSSH**: Vergelijkbaar — single fullscreen terminal, sessies via notification of tab bar.

**Wat SOUL anders doet:** Flutter is de primaire UI (niet de terminal), terminal is het instrument van de AI. Dit keert het gebruikelijke patroon om.

**Verwacht gedrag:**
- Collapsed state: kleine peek-bar (~56dp) met sessie-naam en snelle toegang
- Half-expanded: ~40% van het scherm — genoeg voor snelle terminal check
- Fully expanded: volledig scherm terminal, Flutter UI verdwijnt/verkleint
- Swipe-handle bovenaan het sheet voor bediening
- Back-button behavior: collapsed → closed (terug naar Flutter UI)
- Toestanden overleven app-switch (Persistent bottom sheet houdt state)

**Implementatie:** Android `BottomSheetBehavior` (native) of `DraggableScrollableSheet` (Flutter/Compose). Voor SOUL: de terminal is native Android view (Termux TerminalView), Flutter host geeft het sheet-container gedrag. Coördinatie via Pigeon bridge.

**Complexiteit:** Medium — de echte uitdaging is touch event routing tussen Flutter (sheet) en TerminalView (scroll/gesture). TerminalView consumeert touch events voor tekst-selectie; het sheet consumeert ze voor drag. Conflict resolutie nodig.

---

### 2. AI-Assisted Terminal (SOUL Terminal Awareness)

**Patroon:** De AI heeft lees- en schrijftoegang tot de terminal — output lezen, commando's insturen, context gebruiken voor beslissingen.

**Hoe vergelijkbare apps dit doen:**

**Warp Terminal (desktop):**
- Kernarchitectuur: "Blocks" — elk commando + output wordt een gestructureerde eenheid (niet een raw character stream)
- AI kan een Block als context meekrijgen: gebruiker selecteert output, klikt "@agent", AI ziet de exacte command + output
- Agent Mode: AI voert zelfstandig commando's uit, ziet output, beslist op basis daarvan of volgende stap nodig is — een echte agentic loop
- "Active AI": altijd-aan suggesties op basis van huidige prompt, command history, exit codes
- Blocks bieden structured access: command, output, exit code, working directory — allemaal apart opvraagbaar
- Privacymodel: output wordt naar Warp servers gestuurd voor AI processing (cloud-first)

**GitHub Copilot CLI (2025):**
- Terminal-native agent: leest repository context, voert commando's uit, maakt PRs
- Agentic loop: plan → execute bash → read output → adjust plan → repeat
- Approval flow: toont voorgestelde commando's, vraagt bevestiging voor uitvoering
- Context: huidige directory, git status, recent command history worden meegestuurd

**Claude Code (architectuur):**
- Bash tool: persistent shell sessie, commando's uitvoeren, output teruglezen
- Tool use protocol: model vraagt `bash(command="...")`, harness voert uit, geeft stdout/stderr/exit_code terug
- Agentic loop: gather context → take action → verify results → herhaal
- Geen aparte terminal UI — model runt in de terminal, stuurt de terminal aan

**Wat SOUL Terminal Awareness betekent:**
- SOUL (Flutter/Claude API) kan via Pigeon bridge: output lezen van actieve sessie, commando's schrijven naar terminal input, sessie-state opvragen (working directory, exit code, running process)
- SOUL initieert commando's op verzoek van gebruiker ("SOUL, run de tests") of proactief (na foutdetectie)
- Approval flow: SOUL toont voorgesteld commando in Flutter UI, gebruiker keurt goed, Pigeon bridge stuurt het naar terminal

**Verwacht gedrag:**
- SOUL ziet terminal output via Pigeon output-stream (al gebouwd)
- SOUL kan terminal input schrijven via Pigeon terminal-control (al gebouwd)
- SOUL weet welke sessie actief is, wat de working directory is
- Gebruiker kan SOUL activeren met wake-word of button in Flutter UI
- SOUL vraagt bevestiging voor destructieve commando's (rm, git reset, etc.)

**Complexiteit:** Medium — de Pigeon bridge is al gebouwd. De uitdaging zit in:
1. Output parsing: raw terminal output bevat ANSI escape codes — strippen voor AI context
2. Command tracking: weten wanneer een commando klaar is (prompt terug) versus nog bezig
3. Context windowing: alleen relevante output meesturen (niet 20k regels scrollback)

---

### 3. Session/Tab Management

**Patroon:** Meerdere terminal sessies, snel wisselen, herkenbare namen/iconen.

**Hoe vergelijkbare apps dit doen:**

**Termux (huidige aanpak — pijnpunten):**
- Sessies via swipe-drawer (links naar rechts) — niet discoverable, veel gebruikers weten het niet
- Geen tab bar — grote UX klacht in GitHub issues (#4134, #3798)
- Sessiewisseling via volume-up+N of drawer
- Populaire request: "gewoon tabs zoals een browser"
- Android 16 Linux Terminal (Google): heeft inmiddels echte tab bar toegevoegd — bevestigt dat dit de juiste richting is

**Termius:**
- Echte tab bar voor meerdere SSH sessies
- Elke tab toont host-naam en verbindingsstatus
- Swipe tussen tabs, tap om te wisselen
- Tab context: groen/rood indicator voor actief/verbroken

**Warp:**
- Tabs + Launch Configurations: sla tab-setups op als herbruikbare profiel
- Session restore: heropen vorige sessie met dezelfde tabs, splits, working directories

**Verwacht gedrag voor SOUL Terminal v1.1:**
- Tab bar zichtbaar in bottom sheet (bovenaan het sheet, onder de swipe-handle)
- Tabs tonen: sessienummer + working directory naam (of custom naam)
- Nieuw sessie-knop (+) rechts in tab bar
- Long-press tab: hernoem, sluit sessie
- Max 4-5 tabs voor leesbaarheid op mobiel scherm
- Sessies overleven app-switch (al gedekt door foreground service)

**Complexiteit:** Laag-Medium — Termux heeft al de sessielijst als data model. UI tab bar is nieuw te bouwen, maar de backend (sessie aanmaken/vernietigen/switchen) is inherited.

---

### 4. Developer Onboarding Flow

**Patroon:** Eerste start → stap-voor-stap setup → gebruiker is productief.

**Hoe vergelijkbare apps dit doen:**

**Best practices 2025 (research-consensus):**
- Value-first: toon waarde voor je permissies vraagt — "zie dit voor je ons toestaat"
- Aha-moment zo snel mogelijk bereiken (< 3 schermen voor core waarde zichtbaar is)
- Progressief vragen: vraag permissies op het moment dat je ze nodig hebt, niet allemaal upfront
- Skip optie: power users willen direct aan de slag
- Progress indicator: toon hoeveel stappen resten
- Reverseerbaar: onboarding opnieuw kunnen starten via instellingen

**Developer-specifieke onboarding (tools als Warp, Cursor, VS Code):**
- Warp: eerste start toont kort value prop, daarna direct terminal — geen lange wizard
- GitHub Copilot CLI: `gh copilot` eerste keer toont authenticatie-stap, daarna meteen bruikbaar
- VS Code: stap-voor-stap (theme kiezen, extensions installeren, sync inschakelen) — maar overslaan mogelijk

**Wat SOUL Terminal nodig heeft:**
- Eerste start detectie (SharedPreferences `onboarding_complete` flag)
- Stap 1: Storage permission (vereist voor proot/packages)
- Stap 2: Bootstrap installatie (Termux packages downloaden — eerste keer 50-200MB)
- Stap 3: Claude API key instellen (voor SOUL AI)
- Stap 4: Optioneel: SSH key genereren / proot-distro installeren voor dev environment
- Afronding: "SOUL Terminal is klaar" → directe start

**Verwacht gedrag:**
- Flutter overlay toont de onboarding flow (niet native Android UI)
- Progress: stappen duidelijk gemarkeerd (1/4, 2/4, etc.)
- Bootstrap installatie toont voortgangsbar + terminal output van pkg update
- Foutafhandeling: "Bootstrap mislukt, opnieuw proberen" knop
- Skip mogelijk na stap 2 (bootstrap essentieel, API key optioneel)

**Complexiteit:** Medium — de installatiestap (bootstrap) is de bottleneck. Voortgang tonen van `pkg install` vereist terminal output streaming (al gebouwd in Pigeon bridge).

---

### 5. Terminal UX Innovations

**Patroon:** Kleine verbeteringen die terminal-gebruik comfortabeler maken op mobiel.

**Hoe vergelijkbare apps dit doen:**

**Path detection / Smart selection:**
- **Warp**: double-click selecteert slimme eenheden — bestandspaden, URLs, IP-adressen, emails — als one unit, niet woord-voor-woord. Patterns: floating point numbers, IP addresses, email addresses, file paths, URLs.
- **iTerm2 (macOS)**: quad-click activeert Smart Selection met semantische regels. Zelfde soort patronen.
- **Zed editor terminal**: Cmd+click op pad/fout-locatie opent het bestand op de juiste regel.
- **Termius**: tik op URL opent browser, geen geavanceerde path detection.

**Op mobiel ontbreekt:** Termux heeft geen smart path detection. Tap-to-copy van pad of URL vereist handmatig selecteren — frictie op een touchscreen.

**Verwacht gedrag voor SOUL Terminal:**
- Long-press op tekst: contextmenu toont "Kopieer", "Open in browser" (voor URLs), "Open met SOUL" (voor paden)
- Smart selection: tap op bestandspad selecteert het gehele pad (niet één woord)
- URL tap: direct openen in browser (Termux heeft dit al gedeeltelijk)
- Error path tap: SOUL opent het bestand en springt naar de juiste regel

**Permission dialogs:**
- Android vereist runtime permissions voor storage (MANAGE_EXTERNAL_STORAGE of REQUEST_INSTALL_PACKAGES)
- Huidige Termux aanpak: shell-script toont instructies in terminal — verwarrend voor nieuwe gebruikers
- Betere aanpak: native Android dialog via Flutter, met uitleg waarom de permissie nodig is, voor we vragen

**Landscape support:**
- Termux werkt in landscape — extra schermruimte voor terminal
- Bottom sheet in landscape: sheet neemt verticaal weinig ruimte, terminal krijgt meer breedte
- Tab bar in landscape: horizontaal schuifbaar als teveel tabs

**Scrollback vergroten:**
- Termux default: 2000 regels. Claude Code genereert snel meer output.
- Aanbeveling: 20.000 regels scrollback (al geïdentificeerd als quick win)
- Implementatie: `TerminalEmulator` constructor parameter aanpassen

**Claude Code extra keys:**
- Claude Code gebruikt Ctrl+C (interrupt), Ctrl+D (EOF), Tab (autocomplete), Esc (cancel)
- Extra keys row toevoegen: dedicated Claude Code profiel met deze keys prominent

---

## Differentiators

Features die SOUL Terminal onderscheiden van Termux en alle andere Android terminals.

### Tier 1 — Core differentiators v1.1 (must ship)
| Feature | Complexiteit | Dependency | Onderscheidend t.o.v. |
|---------|-------------|------------|----------------------|
| **Bottom sheet terminal (Flutter + Terminal)** | Medium | FlutterFragment (gebouwd) | Alle Android terminals: terminal IS de UI, niet een paneel |
| **SOUL terminal awareness (AI stuurt terminal)** | Medium | Pigeon bridge (gebouwd) | Termux, Termius, JuiceSSH: geen AI integratie |
| **Session tab bar (in bottom sheet)** | Laag | Termux sessie-model | Termux: alleen swipe-drawer, niet discoverable |
| **Onboarding flow (guided setup)** | Medium | Flutter UI, Pigeon bridge | Termux: geen onboarding, bootstrap handmatig |

### Tier 2 — UX polish (competitive edge)
| Feature | Complexiteit | Dependency | Onderscheidend t.o.v. |
|---------|-------------|------------|----------------------|
| **Smart path detection (tap-to-copy/open)** | Medium | TerminalView touch handling | Termux: handmatig selecteren op touchscreen |
| **Native permission dialogs** | Laag | Flutter UI | Termux: shell-script instructies |
| **Scrollback 20k regels** | Laag | TerminalEmulator parameter | Termux default: 2000 regels |
| **Claude Code extra keys profiel** | Laag | Extra keys configuratie | Termux: generiek extra keys profiel |

### Tier 3 — Long-term moat (na v1.1)
| Feature | Complexiteit | Dependency |
|---------|-------------|------------|
| **AI command suggestions (proactief)** | Medium-Hoog | SOUL brain + Pigeon bridge + output parsing |
| **AI error explanation (automatisch)** | Medium | SOUL brain + exit code tracking |
| **Smart command history (semantisch)** | Medium | SOUL brain + lokale DB |
| **Terminal-to-SOUL handoff** | Medium | Pigeon bridge + SOUL brain |

---

## Anti-Features

Dingen die we bewust NIET bouwen voor v1.1 (en waarom).

| Anti-Feature | Reden |
|-------------|-------|
| **Warp-stijl terminal Blocks** | Vereist complete terminal rendering herschrijven. Termux is stream-based, Blocks zijn structured. Jaren werk, Termux upstream incompatibel. |
| **Modal bottom sheet voor terminal** | Modal dimmed de achtergrond — terminal is primair instrument, moet altijd bereikbaar blijven. Persistent sheet is het juiste patroon. |
| **Cloud sync van sessies** | v1 is local-first. Complexiteit niet gerechtvaardigd. |
| **Inline image rendering (Kitty graphics)** | Hoge complexiteit, terminal-view aanpassingen, niet nodig voor v1.1 scope. |
| **Split panes** | Hoge complexiteit, touch event management. tmux dekt dit al voor power users. |
| **Eigen terminal emulator** | Termux's terminal-emulator is bewezen en upstream te mergen. |
| **iOS versie** | Android-only fork. |
| **Plugin apps** | SOUL Terminal is self-contained. |
| **GUI file manager** | ranger/lf in terminal is beter dan wat wij bouwen. |
| **Warp-stijl cloud account vereist** | SOUL Terminal werkt offline. Geen server dependency voor core functionaliteit. |
| **Onboarding verplicht (geen skip)** | Power users moeten kunnen overslaan. Verplichte wizards zijn anti-pattern. |
| **Permissies upfront allemaal vragen** | Privacy anti-pattern. Vraag permissies op het moment van gebruik. |

---

## Feature Dependencies

```
[GEBOUWD] FlutterFragment + Pigeon bridge (Phase 3)
  ├── Bottom Sheet Terminal
  │    ├── DraggableScrollableSheet in Flutter
  │    ├── Touch event routing (Flutter ↔ TerminalView)
  │    └── Sheet state persistence (collapsed/expanded/fullscreen)
  │
  ├── Session Tab Bar (in bottom sheet)
  │    ├── Termux sessie-model (inherited)
  │    └── Tab UI in Flutter (nieuw)
  │
  ├── SOUL Terminal Awareness
  │    ├── Output streaming Pigeon channel (gebouwd)
  │    ├── Terminal input Pigeon channel (gebouwd)
  │    ├── ANSI strip filter (output cleaning voor AI)
  │    ├── Command completion detectie (prompt regex)
  │    └── Claude API integratie in Flutter
  │
  └── Onboarding Flow
       ├── First-run detectie (SharedPreferences)
       ├── Flutter wizard UI
       ├── Storage permission request
       ├── Bootstrap installatie monitor (via terminal output stream)
       └── API key opslaan (encrypted SharedPreferences)

[NIEUW — geen dependencies buiten Termux]
Terminal UX Quick Wins
  ├── Scrollback 20k (TerminalEmulator parameter)
  ├── Claude Code extra keys (termux.properties)
  └── Smart path detection (TerminalView OnLongClickListener)

Native permission dialogs
  └── Flutter UI + Android runtime permission API
```

**Kritiek pad v1.1:**
1. Bottom sheet terminal (FlutterFragment al gebouwd → sheet wrapper toevoegen)
2. Session tab bar (eenvoudigste UI, backend al aanwezig)
3. Terminal UX quick wins (laagste complexiteit, direct waarde)
4. Onboarding flow (vereist bootstrap monitoring via Pigeon)
5. SOUL terminal awareness (vereist output parsing + Claude API)

---

## Complexity Assessment

### Laag (dagen)
- **Scrollback 20k**: één parameter in TerminalEmulator constructor
- **Claude Code extra keys**: configuratie aanpassing
- **Native permission dialogs**: Flutter widget, Android API
- **Session tab bar UI**: Flutter widget op bestaande sessie data
- **SOUL kleurthema**: CSS/theme variabelen

### Medium (1-2 weken)
- **Bottom sheet terminal**: DraggableScrollableSheet + touch event routing
- **Onboarding wizard**: Flutter multi-step flow + bootstrap monitoring
- **Smart path detection**: TerminalView touch override + regex patterns
- **ANSI strip filter**: parser voor terminal output (bibliotheken beschikbaar)
- **Command completion detectie**: shell prompt regex (PS1-based)

### Hoog (weken)
- **SOUL terminal awareness (volledig)**: output parsing + command tracking + Claude API + approval flow samengebracht
- **Touch event conflict resolution**: Flutter drag vs TerminalView touch — het lastigste technische probleem van v1.1

### Inherited (gratis)
- Shell, packages, sessie-model, clipboard, storage, SSH, foreground service, scrollback buffer

---

## MVP Definition

**v1.1 MVP** — minimum set die "AI coding omgeving" belofte waarmaakt:

1. **Bottom sheet terminal** — Flutter is primaire UI, terminal is bereikbaar als paneel
2. **Session tab bar** — zichtbare sessie-navigatie (vervangt onvindbare swipe-drawer)
3. **Scrollback 20k + Claude Code extra keys** — terminal quick wins
4. **Onboarding flow** — eerste start leidt gebruiker naar werkende dev environment
5. **Basis SOUL terminal awareness** — SOUL kan commando's voorstellen, gebruiker keurt goed, Pigeon voert uit

**Niet in MVP v1.1 (later):**
- Smart path detection
- Volledig autonome AI terminal loop (zonder approval)
- AI error explanation automatisch
- Session restore na app-kill

---

## Prioritization Matrix

| Feature | Impact | Effort | Volgorde | Reden |
|---------|--------|--------|----------|-------|
| Scrollback 20k | Hoog | Laag | **1e** | Directe pijn bij Claude Code gebruik |
| Claude Code extra keys | Medium | Laag | **2e** | Quick win, geen dependencies |
| Session tab bar | Hoog | Laag | **3e** | Grote UX klacht in Termux, eenvoudig |
| Bottom sheet terminal | Hoog | Medium | **4e** | Core v1.1 feature, bouwt op FlutterFragment |
| Native permission dialogs | Medium | Laag | **5e** | Parallel uitvoerbaar met bottom sheet |
| Onboarding flow | Hoog | Medium | **6e** | Vereist bottom sheet + terminal stream |
| SOUL terminal awareness (basis) | Hoog | Medium | **7e** | Vereist alle voorgaande |
| Smart path detection | Medium | Medium | **8e** | UX polish, geen harde dependency |

---

## Competitor Analysis

### Termux (directe fork basis)
**Sterktes:** Volwassen terminal emulator, rijke package manager, gratis/open source, grote community
**Zwaktes:** Geen AI, geen discoverable sessie-navigatie (swipe-drawer), geen onboarding, verouderde UX, geen Flutter/moderne UI
**SOUL differentieert:** AI integratie, moderne UI (Flutter), discoverable sessie-tabs, guided onboarding

### Termius (premium SSH client)
**Sterktes:** Mooie UI, multi-sessie tabs, cross-platform sync, SFTP, Mosh
**Zwaktes:** SSH-client, niet een lokale terminal emulator. Geen AI. Geen package manager. Betaald voor sync.
**SOUL differentieert:** Lokale terminal emulator (shell, packages), AI brain, gratis

### JuiceSSH
**Sterktes:** Gratis, SSH/Telnet/Mosh, plugin systeem, simpele UI
**Zwaktes:** SSH-client (geen lokale shell). Verouderd (laatste update 2021). Geen AI.
**SOUL differentieert:** Alles — JuiceSSH is dead in the water

### Warp Terminal (desktop, niet mobiel)
**Sterktes:** Blocks architectuur, uitstekende AI integratie, agentic loop, moderne UX, session restore
**Zwaktes:** Desktop only (Linux beta 2026, nog geen Android). Cloud-vereist voor AI features. Proprietair.
**SOUL differentieert:** Android-native, offline capable, integratie met SOUL brain op het apparaat
**Leren van Warp:** Blocks als context voor AI (gestructureerd, niet raw stream), approval flow voor AI commando's, agent task list UI

### Google Android Linux Terminal (Android 16)
**Sterktes:** Systeemintegratie, tab bar (nieuw in 2025), virtuele machine isolatie
**Zwaktes:** Android 16+ only (beperkt bereik). VM overhead. Geen AI. Debian-only.
**SOUL differentieert:** Android 12+, native packages (Termux), AI integratie, bredere compatibiliteit

### GitHub Copilot CLI / Claude Code
**Sterktes:** Krachtige AI, agentic loop, tool use, repository context
**Zwaktes:** Niet een terminal emulator — draait binnen een terminal. Vereist desktop/laptop setup.
**SOUL differentieert:** Terminal emulator + AI in één app op Android. De AI EN de terminal op hetzelfde apparaat.

---

## Bronnen

### Competitor / Pattern research
- [Warp Terminal documentation — Blocks, Agent Mode, Session Management](https://docs.warp.dev)
- [Warp AI Agentic Terminal — Inside architecture](https://medium.com/@XPII/inside-warp-ai-agentic-terminal-7ac9861dbfbe)
- [GitHub Copilot CLI architecture](https://shubh7.medium.com/github-copilot-cli-architecture-features-and-operational-protocols-f230b8b3789f)
- [How Claude Code actually works](https://virtuslab.com/blog/ai/how-claude-code-works/)
- [Termius Android changelog](https://serverauditor.com/changelog/android-changelog)
- [Termux session drawer UX issue](https://commonplace.doubleloop.net/making_it_easier_to_open_the_session_drawer_in_termux_in_right_handed_one_handed_mode.html)
- [Android Linux Terminal adds tabs (Android 16)](https://www.androidauthority.com/android-linux-terminal-tabs-3535373/)

### Android / Flutter
- [Material Design: Persistent vs Modal Bottom Sheet](https://m2.material.io/components/sheets-bottom/android/)
- [Android Developers: Partial bottom sheet (Compose)](https://developer.android.com/develop/ui/compose/components/bottom-sheets-partial)
- [Warp Smart Selection](https://docs.warp.dev/terminal/more-features/text-selection)
- [Zed terminal path hyperlink](https://github.com/zed-industries/zed/pull/27218)

### Onboarding
- [Best Practices Developer Onboarding 2025](https://blog.stateshift.com/how-to-design-developer-onboarding-that-actually-works/)
- [7 Mobile Onboarding Best Practices 2025](https://nextnative.dev/blog/mobile-onboarding-best-practices)
- [Onboarding UX: First-time user flow](https://gapsystudio.com/blog/onboarding-ux-design/)

### Eerder onderzoek (v1.0)
- [Terminal Compatibility Matrix](https://tmuxai.dev/terminal-compatibility/)
- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
- [Flutter Add-to-App: FlutterFragment](https://docs.flutter.dev/add-to-app/android/add-flutter-fragment)
- [Pigeon Package](https://pub.dev/packages/pigeon)
