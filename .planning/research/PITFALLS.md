# Pitfalls Research: SOUL Terminal v1.1

## Scope

Gevaren bij het toevoegen van de volgende features aan een bestaande Android terminal + Flutter add-to-app:
- Bottom sheet terminal (FlutterFragment boven, TerminalView schuift omhoog)
- Session management (tab bar in sheet)
- SOUL terminal awareness (AI stuurt terminal aan via Pigeon)
- Onboarding flow (eerste start → werkende dev environment)
- UX polish (path tap-copy, landscape, permissions)

Bestaande v1.0 pitfalls (bootstrap, rebranding, FlutterEngine leaks) worden niet herhaald tenzij ze direct integreren met v1.1 features.

---

## Critical Pitfalls

### CP-1: BottomSheetBehavior + IME — keyboard duwt sheet omhoog i.p.v. resizen

**Wat gaat er mis:**
Als de bottom sheet een invoerveld bevat (zoekbalk, command palette), verschijnt het toetsenbord en duwt de CoordinatorLayout het sheet omhoog. Dit conflicteert met `BottomSheetBehavior` die tegelijkertijd de positie beheert. Resultaat: sheet springt naar positie die nergens op slaat, of het toetsenbord overlapt de inhoud. Op Android 11 en ouder is dit erger omdat `WindowInsetsCompat` niet betrouwbaar werkt met `adjustResize`.

**Waarom het gebeurt:**
`CoordinatorLayout` + `BottomSheetBehavior` en de IME gebruiken allebei de window insets. `android:windowSoftInputMode="adjustResize"` resized het Activity window, wat de CoordinatorLayout triggert, die dan het sheet verplaatst. De twee systemen kennen elkaars state niet.

**Hoe te voorkomen:**
- Gebruik `WindowInsetsControllerCompat` en `ViewCompat.setOnApplyWindowInsetsListener` op de sheet root view om IME-insets handmatig te verwerken
- Stel `android:windowSoftInputMode="adjustPan"` in het manifest in voor de Activity — duwt het gehele scherm omhoog, sheet blijft stabiel
- Als de sheet een `NestedScrollView` bevat: voeg `app:layout_behavior="@string/bottom_sheet_behavior"` toe aan de buitenste container, niet aan een inner scroll view
- Test specifiek op Android 10 (API 29) — gedrag verschilt van Android 12+

**Waarschuwingssignalen:**
- Sheet springt naar top-of-screen wanneer toetsenbord opent
- Command palette wordt half bedekt door toetsenbord
- `adjustResize` + CoordinatorLayout + peek height = layout jump bij elke IME toggle

**Phase:** v1.1 — Bottom Sheet Terminal (Plan 05-A of 05-B)

---

### CP-2: Touch event interception — TerminalView ontvangt geen swipe-up meer

**Wat gaat er mis:**
`BottomSheetBehavior` intercepteert alle verticale touch events in het sheet-gebied, inclusief de `TerminalView` die achter/onder de sheet zit. Als de sheet in `STATE_COLLAPSED` is (peek height zichtbaar), registreert `BottomSheetBehavior` een opwaartse swipe op de terminal als "expand sheet" in plaats van "scroll terminal output".

**Waarom het gebeurt:**
`CoordinatorLayout.onInterceptTouchEvent()` delegeert naar `BottomSheetBehavior.onInterceptTouchEvent()`, die het event claimt zodra de beweging voldoet aan een drempelwaarde. De `TerminalView` heeft geen `NestedScrolling` interface geimplementeerd (het is een custom `View`, geen `RecyclerView`/`NestedScrollView`), dus de CoordinatorLayout weet niet dat de terminal scroll wil consumeren.

**Hoe te voorkomen:**
- Implementeer `NestedScrollingChild3` in `TerminalView`, of wrap het in een `NestedScrollView` die scroll-events delegeert naar de terminal
- Alternatief: gebruik `BottomSheetBehavior.setNestedScrollingChildRef()` om de terminal als primaire scroll child te registreren
- In de sheet: gebruik een dedicated drag handle (`BottomSheetDragHandleView`) zodat alleen slepen aan de handle het sheet expandeert
- Overweeg `STATE_HALF_EXPANDED` als standaard toestand — geeft gebruiker natuurlijker gevoel

**Waarschuwingssignalen:**
- Terminal reageert niet op scroll wanneer sheet in peek-state is
- Sheet expandeert onverwacht tijdens terminal gebruik
- `TerminalView.onTouchEvent()` wordt nooit aangeroepen terwijl sheet collapsed is

**Phase:** v1.1 — Bottom Sheet Terminal

---

### CP-3: TermuxService gedood door Xiaomi HyperOS bij recents-swipe

**Wat gaat er mis:**
Op Xiaomi/HyperOS (de doeldevice!) wordt `TermuxService` — een foreground service — toch gedood wanneer de gebruiker de app wegveegt uit de recents. Dit is HyperOS-specifiek gedrag: de OS negeert `android:stopWithTask="false"` en `START_STICKY` voor apps zonder expliciete autostart-toestemming. Alle lopende terminal sessies, inclusief Claude Code, worden direct afgesloten.

**Waarom het gebeurt:**
HyperOS heeft een eigen process killer die foreground services doodt bij recents-swipe, ongeacht de Android-spec. Apps staan standaard op "battery saver" modus. Zonder `autostart` permission en `No restrictions` battery setting, werkt de service niet als verwacht.

**Hoe te voorkomen:**
- Detecteer Xiaomi/HyperOS bij onboarding (`Build.MANUFACTURER.equals("Xiaomi")`) en toon gerichte instructies: Settings → Apps → SOUL Terminal → Battery → No restrictions + Autostart
- Verwijs naar `dontkillmyapp.com/xiaomi` voor de exacte stappen
- Gebruik `PowerManager.WakeLock` met `PARTIAL_WAKE_LOCK` als backup wanneer er actieve sessies zijn
- Voeg een wakelock toggle toe in de SOUL Terminal instellingen (zoals Termux zelf doet)
- Documenteer dit als bekende beperking in de onboarding flow

**Waarschuwingssignalen:**
- Claude Code stopt midden in een taak zodra gebruiker naar andere app gaat
- `TermuxService.onTaskRemoved()` wordt aangeroepen (log dit!)
- Sessies tonen "Process completed" na terugkeer in app

**Phase:** v1.1 — Onboarding (expliciete permissie-stap) + Session Management

---

### CP-4: Pigeon bridge blokkeert main thread bij terminal output streaming

**Wat gaat er mis:**
SOUL terminal awareness vereist dat terminal output naar Flutter wordt gestreamd via de Pigeon bridge (`sendOutputToFlutter(String chunk)`). Als de Java-kant de Pigeon callback aanroept vanuit de `TerminalSession` output-thread (niet de main thread), crasht de app met `java.lang.RuntimeException: Methods marked with @UiThread must be executed on the main thread`.

**Waarom het gebeurt:**
Pigeon-generated Android code verwacht dat alle host-naar-Flutter calls vanuit de main (UI) thread komen. `TerminalSession` output-callbacks worden echter aangeroepen vanuit de pseudo-terminal (pty) reader thread — een achtergrondthread. De mismatch is niet zichtbaar tijdens development (geen crash in debug als timing meevalt) maar crasht in productie onder load.

**Hoe te voorkomen:**
- Wrap alle Pigeon calls vanuit `TerminalSession` in `Handler(Looper.getMainLooper()).post { ... }`
- Gebruik `@TaskQueue(TaskQueueOptions.BACKGROUND_TASK_QUEUE)` annotatie in Pigeon host API definities waar van toepassing
- Debounce output: stuur niet elke byte naar Flutter, maar batch updates via een 16ms timer (60 FPS equivalent)
- Test door terminal intensief te gebruiken (bijv. `cat /dev/urandom | head -c 10M`) terwijl Flutter sheet open is

**Waarschuwingssignalen:**
- Crash alleen bij hoog output volume (long-running commands)
- `Only the original thread that created a view hierarchy can touch its views` in stacktrace
- Race condition: soms werkt het, soms niet

**Phase:** v1.1 — SOUL Terminal Awareness (Pigeon bridge uitbreiding)

---

### CP-5: Terminal output parsing — prompt-detectie faalt bij custom PS1 en ANSI codes

**Wat gaat er mis:**
SOUL terminal awareness vereist detectie van het shell-prompt om te weten wanneer een commando klaar is. Regex op `$ ` of `% ` werkt niet zodra de gebruiker een custom PS1 heeft met ANSI kleurcodes, git-branch informatie, of multi-line prompts. Bovendien: de output van een lopend commando kan toevallig de prompt-string bevatten (bijv. `cat ~/.bashrc` toont de PS1 definitie). False positives sturen SOUL in de war.

**Waarom het gebeurt:**
Terminals hebben geen standaard protocol voor "commando klaar" — dit is een fundamenteel probleem. ANSI escape sequences (`\033[32m$ \033[0m`) worden door `TerminalView` gerenderd maar de raw output bevat de escape codes. Prompt-detectie op raw bytes moet rekening houden met sequences die tot 20+ bytes lang zijn voor een visueel simpele `$ `.

**Hoe te voorkomen:**
- Gebruik OSC 133 shell integration (`\033]133;A\007` = prompt start, `\033]133;B\007` = command start, `\033]133;C\007` = output start, `\033]133;D\007` = command done) — voeg dit toe aan het onboarding bash/zsh configuratie script
- Schrijf een custom `.bashrc` toevoeging bij onboarding: `PS1='\033]133;A\007'$PS1'\033]133;B\007'`
- Implementeer OSC-parsing in de Pigeon output stream: filter op `\033]133;D` als "commando compleet" signaal
- Fallback: timeout-gebaseerde prompt-detectie als OSC 133 niet beschikbaar is

**Waarschuwingssignalen:**
- SOUL stuurt volgende commando voordat vorige klaar is
- Prompt-detectie werkt in bash maar faalt in zsh/fish
- Claude Code output bevat false-positive prompt-matches

**Phase:** v1.1 — SOUL Terminal Awareness

---

### CP-6: Bootstrap tweede fase faalt bij onboarding — app blijft leeg scherm tonen

**Wat gaat er mis:**
`TermuxInstaller` voert de bootstrap installatie uit in een achtergrondthread met een voortgangsvenster. Als de tweede fase (`termux-bootstrap-second-stage.sh`) faalt — door permission errors (Android 14+), netwerk timeout bij extra package downloads, of ontbrekende execute-bit na extractie — gooit de app een crash report en toont daarna een leeg terminal scherm. De gebruiker weet niet wat er mis is.

**Waarom het gebeurt:**
De second-stage bootstrap script wordt uitgevoerd als een shell commando direct na zip-extractie. Op Android 14+ (API 34) zijn er strengere restricties op het uitvoeren van bestanden vanuit app-specifieke directories. Op sommige devices (waaronder Xiaomi in tweede gebruikersruimte) is het `files/` pad niet beschikbaar voor executie.

**Hoe te voorkomen:**
- Voeg explicit error handling toe in `TermuxInstaller`: vang `IOException` van second-stage op, log de volledige stacktrace, toon een leesbare foutmelding met herstelstappen
- Verifieer execute-bit na extractie: `new File(scriptPath).setExecutable(true)` expliciet aanroepen
- Voeg `retry` logica toe: bij failure, bied een knop "Opnieuw proberen" die de bootstrap herstart
- Voeg bootstrap health check toe bij elke app start: controleer of `$PREFIX/bin/bash` bestaat en uitvoerbaar is
- Test specifiek op Android 14 emulator voor release

**Waarschuwingssignalen:**
- App toont "Process completed" direct bij eerste start
- `TermuxInstaller` crash report in logcat met error code 2
- Bootstrap zip correct aanwezig in assets maar shell start mislukt

**Phase:** v1.1 — Onboarding Flow

---

### CP-7: FlutterFragment + CoordinatorLayout nesting — FlutterView negeert insets

**Wat gaat er mis:**
Als `FlutterFragment` genest is in een `CoordinatorLayout` (vereist voor `BottomSheetBehavior`), verwerkt de `FlutterView` geen window insets correct. Flutter's `MediaQuery.of(context).padding` rapporteert verkeerde waarden voor statusbar/navigationbar hoogte, waardoor SOUL UI content achter de statusbalk of navigatiebalk verschijnt.

**Waarom het gebeurt:**
`FlutterView` consumeert window insets voor zichzelf, maar in een geneste view hierarchy (Activity → CoordinatorLayout → FlutterView) worden insets al gedeeltelijk geconsumeerd door de CoordinatorLayout voordat ze bij FlutterView aankomen. Flutter's inset-doorgifte mechanisme verwacht dat FlutterView direct een child is van de window decorator view.

**Hoe te voorkomen:**
- Gebruik `FlutterFragment` als fullscreen overlay boven de `CoordinatorLayout`, niet er in genest
- In Flutter: gebruik `SafeArea` widget als top-level wrapper voor alle SOUL UI
- In Java/Kotlin: roep `ViewCompat.setOnApplyWindowInsetsListener(flutterView)` aan om insets expliciet door te geven
- Stel `android:fitsSystemWindows="true"` in op de FlutterView container

**Waarschuwingssignalen:**
- SOUL UI content overlapt statusbalk
- `MediaQuery.padding.top` is 0 in Flutter terwijl statusbalk zichtbaar is
- Insets werken correct in standalone FlutterActivity maar niet in FlutterFragment

**Phase:** v1.1 — Bottom Sheet Terminal + Flutter Integration

---

## Technical Debt Patterns

### TD-1: Session state opgeslagen in Activity instance variabelen

Termux's `TermuxActivity` houdt referenties naar actieve sessies bij als instance variabelen. Bij configuration change (rotatie, split-screen op foldables) wordt de Activity recreated maar de service blijft draaien. Zonder `onSaveInstanceState` / `ViewModel` voor sessie-UI-state raakt de tab bar out-of-sync met de werkelijke sessies in `TermuxService`.

**Preventie:** Gebruik een `ViewModel` die de session list houdt. Bind de tab bar aan `LiveData<List<TermuxSession>>` vanuit de service, niet aan een Activity-lokale lijst.

**Phase:** v1.1 — Session Management

---

### TD-2: Pigeon interface gedeeld tussen bottom sheet en AI — schema drift

Als de Pigeon interface (`soul_terminal_api.dart`) voor zowel de bottom sheet UI als de AI terminal awareness wordt gebruikt zonder versioning, raken schema's uit sync. Flutter verwacht een `SessionInfo` object met veld X, Java stuurt het zonder dat veld — runtime crash die niet gedetecteerd wordt door de type-checker.

**Preventie:** Voeg een `apiVersion: int` veld toe aan elke Pigeon dataclass. Valideer bij setup. Bump de versie bij elke schema-wijziging. Houd Pigeon `.dart` en `.java` generated files altijd samen in dezelfde commit.

**Phase:** v1.1 — SOUL Terminal Awareness

---

### TD-3: Onboarding flow niet idempotent

Als onboarding halverwege onderbroken wordt (app crash, battery kill, gebruiker verlaat app), start de onboarding bij herstart mogelijk opnieuw vanaf stap 1 en probeert packages opnieuw te installeren die al geinstalleerd zijn. `pkg install` bij reeds-geinstalleerde packages geeft exit code 0 maar netto tijdverlies is 30-60 seconden.

**Preventie:** Sla onboarding-fase op in `SharedPreferences` met expliciete checkpoints: `BOOTSTRAP_DONE`, `PACKAGES_DONE`, `SHELL_CONFIGURED`, `ONBOARDING_COMPLETE`. Begin bij herstart altijd bij het laatste checkpoint. Maak elke stap idempotent (check before install).

**Phase:** v1.1 — Onboarding Flow

---

## Performance Traps

### PT-1: Terminal output naar Flutter zonder debouncing — 60fps verspilling

`TerminalSession` ontvangt output in kleine chunks (soms 1-4 bytes per callback bij interactieve programma's). Elke chunk direct via Pigeon naar Flutter sturen geeft 1000+ Pigeon calls per seconde bij actief gebruik. Elke call involvemeert JNI overhead, method channel serialization, en een Flutter setState. Resultaat: terminal wordt traag, Flutter jank.

**Preventie:** Implementeer een 16ms debounce buffer in Java: verzamel chunks, stuur eens per frame naar Flutter. Gebruik `Handler.postDelayed()` of een `ScheduledExecutorService`. In Flutter: ontvang de gebufferde string, append aan de output buffer, render één keer.

**Phase:** v1.1 — SOUL Terminal Awareness

---

### PT-2: BottomSheetBehavior animatie blokkeert terminal rendering

`BottomSheetBehavior` animeert sheet-transitie op de UI thread. Als de sheet expand/collapse animeert terwijl de terminal actief output ontvangt (Claude Code aan het werken), concurreren beide operaties voor UI-thread tijd. Zichtbaar als frame drops tijdens sheet animatie.

**Preventie:** Pauzeer terminal output-routing naar Flutter tijdens sheet-animaties. Gebruik `BottomSheetCallback.onSlide()` om een flag te zetten. Herstart output routing in `onStateChanged(STATE_EXPANDED)` of `STATE_COLLAPSED`.

**Phase:** v1.1 — Bottom Sheet Terminal

---

### PT-3: Memory — TerminalView blijft ge-attach terwijl sheet verborgen is

Wanneer de bottom sheet collapsed is (terminal onzichtbaar), blijft `TerminalView` in de view hierarchy en verwerkt het alle terminal output — inclusief rendering van tekst die niemand ziet. Op lange sessies (Claude Code die uren werkt) accumuleert de scrollback buffer (20k regels) in geheugen.

**Preventie:** Bij `STATE_COLLAPSED`, ontkoppel de `TerminalSession` van de `TerminalView` (`terminalView.attachSession(null)`). Herattach bij `STATE_EXPANDED`. De sessie blijft draaien in de achtergrond, alleen de rendering is gestopt. Verifieer dat het scrollback buffer niet verloren gaat bij detach/reattach.

**Phase:** v1.1 — Bottom Sheet Terminal

---

## Security Mistakes

### SM-1: Command injection via SOUL AI terminal awareness

SOUL stuurt commando's naar de terminal via `TerminalSession.write(String command)`. Als de commando-string komt van een LLM-response zonder sanitization, kan indirect prompt injection leiden tot uitvoering van destructieve commando's. Een kwaadaardig bestand gelezen door Claude Code (bijv. een README met `; rm -rf ~/`) kan als terminal input eindigen als de output-parsing de shell commando's er niet uitfiltert.

**Preventie:**
- Implementeer een expliciete "command allow list" in de Pigeon interface: SOUL mag alleen gestructureerde commando's sturen (`runCommand(String executable, List<String> args)` i.p.v. `sendRawInput(String)`)
- Voeg een bevestigingsdialoog toe voor destructieve commando's (patronen: `rm -rf`, `chmod -R`, `dd if=`, `mkfs`)
- Log alle commando's die via SOUL gestuurd worden met timestamp
- Nooit een hele LLM-response als raw terminal input sturen — altijd parsen naar gestructureerde commando's

**Waarschuwingssignalen:**
- Terminal voert commando's uit die SOUL niet expliciet gepland had
- Output bevat `; command` patronen die geinterpreteerd worden als shell chaining

**Phase:** v1.1 — SOUL Terminal Awareness (prioriteit: voor eerste gebruik)

---

### SM-2: API key exposure via terminal scrollback

SOUL communiceert met Claude API via Pigeon. Als de API key ooit als omgevingsvariabele of shell-argument wordt doorgegeven, verschijnt het in de terminal output of `ps aux` output. De scrollback buffer (20k regels) persisteert in geheugen en is zichtbaar in bug reports.

**Preventie:**
- Sla de API key uitsluitend op in `EncryptedSharedPreferences` (Android Keystore)
- Geef de key nooit door als shell omgevingsvariabele of als argument aan subprocessen
- Mask API keys in log output: vervang `sk-ant-...` patronen met `[REDACTED]` in alle logging
- Voeg key-masking toe aan de terminal scrollback export functie

**Phase:** v1.1 — SOUL Terminal Awareness + UX polish

---

### SM-3: ANSI escape code injection via AI output → terminal

LLMs kunnen ANSI escape codes genereren in hun output (bijv. `\033[2J` om het scherm te wissen, `\033[?1049h` voor alternate screen buffer, of historisch: ANSI bombs die keyboard keys herdefiniëren). Als SOUL de LLM-output direct als terminal input stuurt, kan de terminal in een onverwachte staat belanden.

**Preventie:**
- Filter ANSI escape codes uit LLM-responses voordat ze als terminal input worden gebruikt
- Gebruik LLM output alleen voor gestructureerde commando-extractie, nooit als raw terminal input
- Specifiek: filter `\033[` gevolgd door command-codes die state wijzigen (niet color codes)

**Phase:** v1.1 — SOUL Terminal Awareness

---

## UX Pitfalls

### UX-1: Onboarding blokkeert op netwerkfout zonder recovery

De onboarding flow installeert packages via `pkg install` die netwerkverkeer vereist. Op slechte verbindingen (of bij fouten in de eigen apt repository) faalt de installatie maar de onboarding UI toont alleen een generieke foutmelding. De gebruiker weet niet of het een tijdelijke netwerk-issue of een permanent probleem is.

**Preventie:**
- Implementeer retry-logica met exponential backoff (3 pogingen, 5/15/30 seconden)
- Toon specifieke foutmelding: onderscheid netwerk-timeout van package-not-found van disk-full
- Bied een "skip" optie voor niet-kritieke packages (bijv. luxe tools) — laat core bootstrap altijd verplicht
- Onthoud welke packages al geinstalleerd zijn; herstart altijd vanaf het laatste succesvolle checkpoint

**Phase:** v1.1 — Onboarding Flow

---

### UX-2: Tab bar in bottom sheet — sessienamen niet persistent

Bij herstart van de app worden sessienamen (bijv. "Claude Code", "Git", "Build") gereset naar "Session 1", "Session 2", etc. Termux bewaart sessienamen niet standaard. Gebruikers die bewust hun sessies benoemen verliezen die context na elke app-herstart.

**Preventie:**
- Sla sessienamen op in `SharedPreferences` gekoppeld aan de sessie-index
- Herstel sessienamen bij `TermuxService` herstart via `TermuxSession.setSessionName()`
- Overweeg sessie-namen ook te tonen in de persistent notificatie

**Phase:** v1.1 — Session Management

---

### UX-3: Bottom sheet peek height verkeerd bij landscape + notch

Op de Xiaomi 17 Ultra in landscape mode verschuift de bottom sheet peek height buiten beeld of overlapt de navigatiebar. De peek height is vaak hardcoded in dp (bijv. 56dp voor een drag handle), maar in landscape is de beschikbare hoogte veel kleiner. Combined met een notch/punch-hole camera wijken de insets af van portrait.

**Preventie:**
- Bereken peek height dynamisch: `min(desiredPeekHeight, screenHeight * 0.25f)`
- Gebruik `ViewCompat.setOnApplyWindowInsetsListener` om insets te verwerken en peek height te heroverwegen bij elke inset-change
- Test expliciet in landscape op de doeldevice (Xiaomi 17 Ultra, 6.73" display)

**Phase:** v1.1 — UX Polish

---

## "Looks Done But Isn't" Checklist

Items die klaar lijken in development maar kapot zijn in productie:

- [ ] **Bottom sheet opent** — maar terminal scroll werkt niet meer wanneer sheet in peek state is (CP-2)
- [ ] **Pigeon bridge stuurt output** — maar crasht pas bij >100KB output vanuit achtergrondthread (CP-4)
- [ ] **Onboarding voltooid op dev device** — maar crasht bij Android 14+ permission restricties (CP-6)
- [ ] **SOUL stuurt commando's** — maar commando's bevatten shell injection patronen vanuit LLM output (SM-1)
- [ ] **Sessienamen zichtbaar** — maar verdwenen na eerste app-herstart (UX-2)
- [ ] **Sheet animatie smooth** — maar terminal output stopt tijdens animatie (PT-2)
- [ ] **Onboarding packages geinstalleerd** — maar onboarding herstart bij onderbreking en probeert opnieuw (TD-3)
- [ ] **TermuxService als foreground service** — maar gedood door HyperOS op testdevice (CP-3)
- [ ] **Prompt-detectie werkt in bash** — maar faalt bij zsh of starship prompt (CP-5)
- [ ] **API key opgeslagen** — maar zichtbaar in `ps aux` output of logcat (SM-2)

---

## Pitfall-to-Phase Mapping

| Pitfall | Feature | Phase/Plan |
|---------|---------|-----------|
| CP-1: IME + BottomSheet conflict | Bottom Sheet Terminal | 05-A (Layout) |
| CP-2: Touch interception terminal | Bottom Sheet Terminal | 05-A (Touch handling) |
| CP-3: HyperOS kills TermuxService | Session Management + Onboarding | 05-D (Permissions) |
| CP-4: Pigeon main thread blocking | SOUL Terminal Awareness | 05-C (Pigeon bridge) |
| CP-5: Prompt detection unreliable | SOUL Terminal Awareness | 05-C (Shell integration) |
| CP-6: Bootstrap second stage fails | Onboarding Flow | 05-E (Bootstrap health check) |
| CP-7: FlutterView insets in CoordinatorLayout | Bottom Sheet + Flutter | 05-A (Layout) |
| TD-1: Session state in Activity | Session Management | 05-B (ViewModel) |
| TD-2: Pigeon schema drift | SOUL Terminal Awareness | 05-C (Versioning) |
| TD-3: Onboarding niet idempotent | Onboarding Flow | 05-E (Checkpoints) |
| PT-1: Output debouncing | SOUL Terminal Awareness | 05-C (Performance) |
| PT-2: Animatie blokkeert terminal | Bottom Sheet Terminal | 05-A (Animation) |
| PT-3: TerminalView geheugen hidden | Bottom Sheet Terminal | 05-A (Detach) |
| SM-1: Command injection | SOUL Terminal Awareness | 05-C (Security, EERST) |
| SM-2: API key exposure | SOUL Terminal Awareness | 05-C (Keystore) |
| SM-3: ANSI escape injection | SOUL Terminal Awareness | 05-C (Filtering) |
| UX-1: Onboarding netwerk recovery | Onboarding Flow | 05-E (Retry logic) |
| UX-2: Sessienamen niet persistent | Session Management | 05-B (Persistence) |
| UX-3: Peek height landscape | UX Polish | 05-F (Insets) |

---

## Prioriteitsvolgorde voor implementatie

**Eerst aanpakken (blokkeren andere features):**
1. CP-3 — HyperOS permissies in onboarding (anders werkt niets op doeldevice)
2. SM-1 — Command injection whitelist (voor elk AI→terminal gebruik)
3. CP-6 — Bootstrap health check (onboarding moet recoverable zijn)

**Aanpakken bij implementatie van betreffende feature:**
4. CP-1 + CP-2 — Bij bottom sheet layout implementatie
5. CP-4 + PT-1 — Bij Pigeon bridge uitbreiding voor output
6. CP-5 — Bij SOUL terminal awareness (OSC 133 shell integration)
7. CP-7 — Bij Flutter + CoordinatorLayout integratie

**Aanpakken bij UX-fase:**
8. TD-1, TD-2, TD-3 — Tijdens refinement
9. PT-2, PT-3 — Bij performance profiling
10. SM-2, SM-3, UX-1, UX-2, UX-3 — UX polish fase

---

*Onderzoeksdatum: 2026-03-20*
*Milestone: v1.1 — Van terminal naar AI coding omgeving*
*Sources: Flutter GitHub issues, Material Components Android issues, Termux GitHub issues, Android developer docs, dontkillmyapp.com, embracethered.com (ANSI injection research), Trail of Bits (prompt injection → RCE)*
