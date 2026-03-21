# Roadmap: SOUL Terminal

**Current milestone:** v1.1 — Van terminal naar AI coding omgeving
**Last updated:** 2026-03-20

---

## v1.0 — Foundation (COMPLETE)

**Goal:** Werkende SOUL Terminal APK met branding, bootstrap pipeline, Flutter module embedding, Pigeon bridge, en terminal enhancements.

### Phase 1 — Foundation (COMPLETE 2026-03-19)

**Goal:** Een werkende SOUL Terminal APK met correcte branding, package name, en geautomatiseerde builds.
**Requirements:** REBR-01..06, CICD-01, CICD-02

**Success criteria:**
1. APK installeert als `com.soul.terminal` naast bestaande Termux zonder conflict
2. Launcher toont "SOUL Terminal" met custom icon en SOUL kleurschema
3. GitHub Actions bouwt automatisch een gesignde APK bij elke push
4. Terminal werkt identiek aan Termux (shell, tabs, extra keys, alle bestaande features)

### Phase 2 — Bootstrap Pipeline (COMPLETE 2026-03-19)

**Goal:** Alle packages herbouwd met `com.soul.terminal` prefix en serveerbaar via eigen apt repository.
**Requirements:** BOOT-01..05, CICD-04

**Success criteria:**
1. `pkg install python` installeert vanuit eigen repository met correcte prefix
2. Bootstrap packages laden succesvol bij eerste app start (geen Termux fallback)
3. GitHub Actions workflow kan handmatig getriggerd worden om bootstrap packages te rebuilden

### Phase 3 — Flutter Integration (COMPLETE 2026-03-19)

**Goal:** Flutter module embedded in terminal app met werkende Pigeon bridge — AI kan terminal aansturen.
**Requirements:** FLUT-01..05, PIGB-01..05, CICD-03

**Success criteria:**
1. Toggle-knop wisselt tussen terminal-fullscreen en Flutter-fullscreen zonder lag
2. Flutter module kan een commando uitvoeren in de terminal en het resultaat ontvangen via Pigeon
3. Terminal output streamt naar Flutter met max 10 updates/sec (debounced)
4. cmd-proxy is volledig vervangen door Pigeon bridge voor Claude Code communicatie
5. CI/CD bouwt Flutter module + Gradle in twee stages succesvol

### Phase 4 — Terminal Enhancements (COMPLETE 2026-03-19)

**Goal:** Terminal features die power users verwachten — keyboard protocol, notificaties, command palette.
**Requirements:** TERM-01..03

**Success criteria:**
1. Neovim/Helix herkent Kitty keyboard protocol en modifier keys werken correct
2. Terminal commando's kunnen Android notificaties triggeren via OSC9 escape sequence
3. Command palette opent met fuzzy search over sessies, commands en history

---

## v1.1 — Van terminal naar AI coding omgeving (ACTIVE)

**Goal:** SOUL Terminal transformeren van een rebranded Termux naar een volwaardige AI coding omgeving — Flutter als hoofdscherm, terminal als bottom sheet, SOUL kan zelfstandig terminal gebruiken, en een onboarding flow die nieuwe gebruikers meteen productief maakt.

**Phases:** 5–11
**Requirements:** 47 (TERM-04..07, MERG-01..09, LAYT-01..06, SESS-01..06, AWAR-01..08, ONBR-01..07, UXPL-01..07)

---

### Phase 5 — Terminal Quick Wins

**Status:** Pending
**Requirements:** TERM-04, TERM-05, TERM-06, TERM-07 (4 requirements)

**What:** Pure Java/Android configuratiewijzigingen aan de terminal. Geen Flutter, geen Pigeon — snelle wins die de dagelijkse Claude Code workflow verbeteren en SOUL-branding doortrekken naar de terminal UI. Geen dependencies op andere v1.1 fasen.

**Tasks:**
- Verhoog scrollback buffer van 2.000 naar 20.000 regels (`TerminalEmulator.TERMINAL_TRANSCRIPT_ROWS_MAX`)
- Voeg Claude Code extra keys toe: `Tab`, `Esc`, `Ctrl+C`, `Ctrl+D`, `Ctrl+Z`, `Ctrl+L`, pijltjes, `Home`, `End`
- Stel SOUL kleurthema in als default: bg `#0F0F23`, fg `#E0E0E0`, cursor `#6C63FF`
- Pas drawer, extra keys balk en app chrome aan met `#6C63FF` accent

**Success criteria:**
1. Gebruiker kan 20.000 regels omhoog scrollen in een lange Claude Code sessie zonder dat output afknijpt
2. Gebruiker heeft één tik toegang tot `Esc`, `Tab` en `Ctrl+C` zonder het toetsenbord te wisselen
3. Terminal opent standaard met donker SOUL-thema (paarse cursor zichtbaar) zonder handmatige configuratie
4. Drawer en extra keys balk tonen `#6C63FF` paars in plaats van standaard Termux groen
5. Kleurthema en extra keys overleven app herstart

---

### Phase 6 — App Merge

**Status:** Pending
**Requirements:** MERG-01, MERG-02, MERG-03, MERG-04, MERG-05, MERG-06, MERG-07, MERG-08, MERG-09 (9 requirements)

**What:** De bestaande SOUL Flutter app (339 Dart-bestanden, 52 dependencies) samenvoegen met de soul-terminal flutter_module. Na merge is de SOUL chat UI operationeel als hoofdscherm in de FlutterFragment. Dit is de grootste en riskantste stap in v1.1.

**Kritieke pitfalls:**
- `ProviderScope` refactoring: niet `runApp` maar fragment-compatible initialisatie (MERG-04)
- Foreground service coëxistentie: SOUL service + TermuxService tegelijk (MERG-06)
- Database paden: Drift + ObjectBox schrijven naar `com.soul.terminal` app directory (MERG-05)

**Tasks:**
- Kopieer SOUL app Dart-bestanden (339 files) naar `flutter_module/lib/`
- Merge `pubspec.yaml`: ObjectBox, Drift, riverpod, foreground_task + 48 andere deps (52 totaal)
- Merge `AndroidManifest.xml`: permissies, services, boot receiver
- Refactor `ProviderScope` van `main.dart` naar `FlutterFragment`-compatible root widget
- Unificeer database paden: Drift + ObjectBox in `com.soul.terminal` context
- Coëxistentie foreground services: eigen notifications + wake lock naast TermuxService
- Valideer SOUL chat UI als functioneel hoofdscherm in FlutterFragment
- CI/CD pipeline bouwt succesvol met alle 52 Flutter deps + Android
- API key invoer via Android Keystore onder `com.soul.terminal` context

**Success criteria:**
1. SOUL chat UI is zichtbaar en bedienbaar als hoofdscherm bij app start (geen splash/crash)
2. CI/CD build slaagt groen met alle 52 deps zonder conflicten
3. API key invoer werkt en overleeft app herstart (Keystore persistentie onder juiste package)
4. Database operaties (Drift query, ObjectBox write) slagen zonder pad-conflicten
5. Beide foreground services (SOUL + Termux) draaien simultaan zonder notification conflict

---

### Phase 7 — Bottom Sheet Layout

**Status:** COMPLETE — alle 3 plannen uitgevoerd (07-01: layout, 07-02: touch/IME, 07-03: back button + cleanup)
**Requirements:** LAYT-01, LAYT-02, LAYT-03, LAYT-04, LAYT-05, LAYT-06 (6 requirements — alle geleverd)

**What:** CoordinatorLayout refactor van `TermuxActivity`. Flutter (SOUL chat) wordt het fullscreen hoofdscherm; de terminal schuift omhoog als een persistent BottomSheet. Legt de visuele architectuur voor alle volgende fasen.

**Kritieke pitfalls:**
- Touch event conflict: `BottomSheetBehavior` pikt verticale swipes in terminal weg — oplossing via dedicated `BottomSheetDragHandleView` + `NestedScrollingChild3` in TerminalView (CP-2)
- IME conflict: toetsenbord duwt sheet omhoog — oplossing `adjustPan` + `ViewCompat.setOnApplyWindowInsetsListener` (CP-1)

**Architecture:**
- `TermuxActivity` root layout → `CoordinatorLayout`
- `FlutterFragment` als fullscreen achtergrond
- Terminal container als `BottomSheetBehavior` child
- 4 states: hidden, collapsed/peek (48dp handle zichtbaar), half-expanded (40%), expanded (fullscreen)

**Tasks:**
- Refactor `TermuxActivity` layout naar `CoordinatorLayout`
- Implementeer `BottomSheetBehavior` met 4 states
- Dedicated drag handle als exclusieve swipe-zone (voorkomt touch conflict met TerminalView)
- `NestedScrollingChild3` implementatie in TerminalView
- `windowSoftInputMode="adjustPan"` + inset listener voor IME
- Back button interceptie: sheet → peek, niet app sluiten
- Valideer terminal process continuïteit bij alle sheet states

**Success criteria:**
1. SOUL chat is zichtbaar als hoofdscherm bij app start; terminal sheet toont alleen de handle bar
2. Gebruiker sleept de handle bar omhoog: terminal schuift soepel naar half-expanded (geen jank, geen touch conflict)
3. Gebruiker opent toetsenbord in terminal: sheet past zich aan, geen UI-overlap tussen terminal en keyboard
4. Gebruiker drukt back in expanded sheet: sheet sluit naar peek state, app sluit niet
5. Terminal sessie (inclusief lopend Claude Code proces) survives meerdere sheet minimize/expand cycli

---

### Phase 8 — Session Management

**Status:** COMPLETE (2026-03-21)
**Requirements:** SESS-01, SESS-02, SESS-03, SESS-04, SESS-05, SESS-06 (6 requirements)
**Dependencies:** Phase 7 (sheet layout vereist voor tab bar positie)

**What:** Tab bar bovenaan de terminal sheet voor sessie-navigatie. ViewPager2 voor swipe tussen sessies. Process namen worden live gelezen uit `/proc/PID/cmdline`. SOUL chat kan sessies aanmaken/sluiten via Pigeon.

**Tasks:**
- Voeg `ViewPager2:1.1.0` toe als dependency en bouw `SessionTabBar` widget
- Lees process naam uit `/proc/PID/cmdline` per tab (polling interval 2s)
- Implementeer `+` knop voor nieuwe sessie aanmaken
- Implementeer lang-indrukken context menu op tab: hernoemen + sluiten
- Swipe links/rechts via ViewPager2 wisselt tussen sessies
- Pigeon API uitbreiding: `createSession()`, `closeSession()` aanroepbaar vanuit Flutter/SOUL

**Success criteria:**
1. Tab bar toont sessie-tabs bovenaan het terminal sheet (altijd zichtbaar in expanded en half-expanded state)
2. Tab label toont de juiste process naam (`claude`, `bash`, `python`) — update binnen 3 seconden na process start
3. Gebruiker maakt nieuwe sessie via `+` knop: nieuwe tab verschijnt, terminal is leeg en klaar voor input
4. Gebruiker sluit sessie via lang-indrukken menu: tab verdwijnt, actieve sessie verschuift correct
5. SOUL chat kan programmatisch een sessie aanmaken en erin schrijven via Pigeon (gevalideerd via integratie test)

---

### Phase 9 — SOUL Terminal Awareness

**Status:** Pending
**Requirements:** AWAR-01, AWAR-02, AWAR-03, AWAR-04, AWAR-05, AWAR-06, AWAR-07, AWAR-08 (8 requirements)
**Dependencies:** Phase 7 (sheet voor AWAR-08), Phase 8 (sessies voor AWAR-01/02)

**What:** De AI kan de terminal aansturen en observeren. AWAR-05 (security whitelist) moet geïmplementeerd zijn voordat het AI→terminal pad live gaat — dit is niet-onderhandelbaar.

**Security-first implementatievolgorde binnen de fase:**
1. Command injection whitelist (AWAR-05) — geblokkeerd tot dit klaar is
2. API key / wachtwoord isolatie (AWAR-06)
3. ANSI stripping (AWAR-07)
4. `sendInput` + output stream (AWAR-01, AWAR-02)
5. OSC 133 prompt detectie (AWAR-03)
6. UI indicator + sheet-open knop (AWAR-04, AWAR-08)

**Tasks:**
- Implementeer `SoulAwarenessService` (Dart) als orchestrator
- Gestructureerde command API: `runCommand(executable, args[])` — nooit raw shell string
- Whitelist: destructieve patronen (`rm -rf`, `dd if=`, `mkfs`, `git reset --hard`, `:(){:|:&}`) → bevestigingsdialoog
- API key / wachtwoord filtering: regex blacklist voor output logging naar SOUL memory (`sk-...`, wachtwoordvelden)
- ANSI escape code stripping in output pipeline; 100ms debounce buffer
- Pigeon: `sendInput()` en `onTerminalOutput` EventChannel stream
- OSC 133 parsing (`\033]133;D\007`) voor commando-klaar detectie
- Flutter: "Uitvoeren in terminal..." indicator in SOUL chat UI
- Gebruiker kan altijd sheet handmatig openen om lopend commando te observeren (AWAR-08)

**Success criteria:**
1. SOUL stuurt `ls -la` naar terminal: output verschijnt in terminal view én in SOUL chat context
2. SOUL wacht correct op OSC 133 marker voordat het volgende commando wordt gestuurd (geen race condition)
3. Destructief commando (`rm -rf ~/test`) toont native Android bevestigingsdialoog — nooit direct uitgevoerd
4. API key in terminal output (patroon `sk-ant-...`) verschijnt niet in SOUL memory logs
5. SOUL chat toont "Uitvoeren in terminal..." indicator tijdens actief commando; verdwijnt na completion

---

### Phase 10 — Onboarding Flow

**Status:** In progress — plan 10-01 (infrastructure) complete, plan 10-02 (functional steps) complete, plan 10-03 pending
**Requirements:** ONBR-01, ONBR-02, ONBR-03, ONBR-04, ONBR-05, ONBR-06, ONBR-07 (7 requirements)
**Progress:** ONBR-01 (welcome/profile), ONBR-02 (package install streaming), ONBR-03 (API key validation), ONBR-04 (GitHub CLI), ONBR-05 (Xiaomi battery) COMPLETE — ONBR-06, ONBR-07 pending plan 10-03
**Dependencies:** Phase 6 (merge voor SOUL chat als basis), Phase 9 (AWAR voor package installatie via terminal)

**What:** Meerstaps onboarding wizard voor eerste start. HyperOS battery-instructies zijn kritiek voor het primaire testapparaat (Xiaomi 17 Ultra) — zonder dit werken achtergrond-sessies niet op het testdevice.

**Tasks:**
- Bouw `OnboardingFlow` Flutter widget (meerstaps wizard, eenmalig bij eerste start)
- Welkomstscherm met setup-keuze: Claude Code / Python / Alleen terminal
- Package installatie op achtergrond via terminal sessie, voortgang zichtbaar als berichten in SOUL chat
- API key invoer stap — opgeslagen via Android Keystore (DataStore + AES-GCM)
- GitHub CLI authenticatie flow via SOUL chat (opent browser voor OAuth)
- Detecteer Xiaomi/HyperOS: toon specifieke battery restrictions + autostart instructies
- Schrijf `.bashrc` / `.zshrc` OSC 133 configuratie (`PROMPT_COMMAND` / `precmd` hook) — vereist voor AWAR-03
- Voltooiingsscherm: "Je omgeving is klaar"

**Success criteria:**
1. Eerste app-start toont welkomstscherm — niet het normale SOUL chat scherm
2. Keuze "Claude Code" start installatie van `nodejs`, `git`, `gh`; voortgang zichtbaar als chatberichten
3. Xiaomi-device toont specifieke HyperOS battery-instructies (stap afwezig op niet-Xiaomi devices)
4. `.bashrc` bevat OSC 133 `PROMPT_COMMAND` na voltooide onboarding (AWAR-03 daarna functioneel)
5. Tweede app-start toont onboarding niet meer (first-run flag persistent opgeslagen)

---

### Phase 11 — UX Polish

**Status:** Pending
**Requirements:** UXPL-01, UXPL-02, UXPL-03, UXPL-04, UXPL-05, UXPL-06, UXPL-07 (7 requirements)

**What:** Finale polish voor open source lancering. Parallel-safe — raakt geen gedeelde architectuur van andere fasen. Bevat accessibility, haptics, blur, landscape layout, en interactieve terminal output.

**Tasks:**
- Long press op bestandspaden in terminal output: copy/open dialog (path regex detectie in TerminalView)
- Claude Code y/n prompt interceptie: regex op terminal output detecteert `[y/N]?` prompt → native AlertDialog
- Velocity-based sheet expand: fling omhoog boven drempelwaarde → altijd full screen (ook bij korte veegbeweging)
- `RenderEffect` blur (API 31+) op SOUL chat UI achter open sheet
- `VibrationEffect` haptic feedback bij sheet open/close en tab-switch
- Landscape mode: terminal sheet wordt side drawer (rechts 40%), SOUL chat links 60%
- Content descriptions op alle interactieve elementen; TalkBack navigatie gevalideerd

**Success criteria:**
1. Lang indrukken op bestandspad in terminal output toont dialog met "Kopieer" en "Open" opties
2. Claude Code stelt y/n vraag: native Android dialog verschijnt; antwoord wordt correct naar terminal gestuurd
3. Snel vegen (velocity > drempel) expandeert sheet altijd naar full screen, ook met korte veegbeweging
4. Sheet open/close is voelbaar via subtiel haptic pulse (VibrationEffect, geen zware vibratie)
5. In landscape: SOUL chat links en terminal rechts tegelijk zichtbaar, geen full-screen toggle nodig

---

## Coverage

| Phase | Requirements | Count |
|-------|-------------|-------|
| Phase 5 | TERM-04, TERM-05, TERM-06, TERM-07 | 4 |
| Phase 6 | MERG-01, MERG-02, MERG-03, MERG-04, MERG-05, MERG-06, MERG-07, MERG-08, MERG-09 | 9 |
| Phase 7 | LAYT-01, LAYT-02, LAYT-03, LAYT-04, LAYT-05, LAYT-06 | 6 |
| Phase 8 | SESS-01, SESS-02, SESS-03, SESS-04, SESS-05, SESS-06 | 6 |
| Phase 9 | AWAR-01, AWAR-02, AWAR-03, AWAR-04, AWAR-05, AWAR-06, AWAR-07, AWAR-08 | 8 |
| Phase 10 | ONBR-01, ONBR-02, ONBR-03, ONBR-04, ONBR-05, ONBR-06, ONBR-07 | 7 |
| Phase 11 | UXPL-01, UXPL-02, UXPL-03, UXPL-04, UXPL-05, UXPL-06, UXPL-07 | 7 |
| **Total** | | **47 / 47** |

Coverage: 100%

---

*Roadmap created: 2026-03-20*
*v1.0 phases 1–4 marked complete. v1.1 phases 5–11 defined.*
*2026-03-21: Phase 10 plans 10-01 + 10-02 complete. ONBR-01..05 delivered.*
