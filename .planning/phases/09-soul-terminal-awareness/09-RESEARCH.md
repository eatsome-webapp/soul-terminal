# Phase 9: SOUL Terminal Awareness — Research

**Gathered:** 2026-03-21
**Status:** Ready for planning

---

## Executive Summary

De codebase is in een goede staat voor Phase 9. De Pigeon bridge bestaat en werkt (7 HostApi methods, 3 FlutterApi methods). SoulBridgeController heeft al debounced output streaming. OSC-parser in TerminalEmulator is goed begrepen — OSC 133 toevoegen is één case in een bestaande switch. De grootste onbekende is de integratie aan de Dart-kant: `SoulBridgeApi` implementatie zit nu in `SoulApp` (root widget) maar heeft geen routing naar een `SoulAwarenessService`. Die verbinding moet worden gebouwd. Security whitelist moet volledig in Java worden gebouwd vóórdat `sendInput` via Pigeon beschikbaar is.

**Kritieke bevinding:** `SoulBridgeController.java` bestaat en is correct geïmplementeerd, maar wordt **nergens aangeroepen** — hij is niet verbonden aan `TermuxTerminalSessionActivityClient.onTextChanged()`. De debounced output-streaming werkt dus nog niet end-to-end.

---

## Codebase Analysis

### Current Pigeon Bridge State

**Pigeon definitie** (`flutter_module/pigeons/terminal_bridge.dart`):

HostApi (`TerminalBridgeApi`) — 7 methoden, alle geïmplementeerd in Java:
- `executeCommand(String command)` — schrijft raw string + "\n" naar terminal
- `getTerminalOutput(int lines)` — leest transcript, geeft laatste N regels terug
- `createSession()` → `int` — maakt nieuwe TermuxSession aan
- `listSessions()` → `List<SessionInfo>` — lijst van actieve sessies
- `closeSession(int id)` — sluit sessie via `finishIfRunning()`
- `switchSession(int id)` — switcht via `TermuxTerminalSessionActivityClient.switchToSession()`
- `renameSession(int id, String name)` — zet `mSessionName` direct

FlutterApi (`SoulBridgeApi`) — 3 methoden, Dart-implementatie in `SoulApp` (root widget):
- `onTerminalOutput(String output)` — huidige implementatie: alleen logger call, geen routing
- `onSessionChanged(SessionInfo info)` — huidige implementatie: alleen logger call
- `onSessionListChanged(List<SessionInfo> sessions)` — **niet geïmplementeerd** in `SoulApp` (methode ontbreekt — zou compilefout geven)

**Java-kant setup** (`TermuxActivity.setupPigeonBridges()`):
- `TerminalBridgeImpl` aangemaakt en geregistreerd ✓
- `mSoulBridgeApi` (FlutterApi-caller) aangemaakt maar **niet doorgegeven** aan `SoulBridgeController` ✓ bruikbaar
- `SoulBridgeController` bestaat als klasse maar wordt **nergens geïnstantieerd of aangeroepen** — dode code

**Dart-kant** (`flutter_module/lib/generated/terminal_bridge.g.dart`):
- `SessionInfo` data class met `id`, `name`, `isRunning`
- `TerminalBridgeApi` Dart-caller volledig gegenereerd (alle 7 methoden)
- `SoulBridgeApi` abstract klasse met `setUp()` static methode (Pigeon FlutterApi patroon)
- `List<String>` wordt door Pigeon out-of-the-box ondersteund als `List<Object?>` met `.cast<String>()`

**Wat ontbreekt voor Phase 9:**
1. `runCommand(String executable, List<String> args)` method in HostApi definitie + Java implementatie
2. `sendInput(int sessionId, String text)` method — of `executeCommand` hernoemen/uitbreiden
3. `onCommandCompleted(int sessionId)` callback in FlutterApi (voor OSC 133)
4. `SoulBridgeController` verbinden aan `onTextChanged()` callback
5. `onSessionListChanged` implementatie in `SoulApp`

### Terminal Emulator OSC Handling

**Locatie:** `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java`

**OSC flow:**
1. Terminal output → `doOsc(int b)` (regel ~2020) — dispatcht op terminatiekarakter (BEL=7, ESC=27)
2. → `doOscSetTextParameters(String bellOrStringTerminator)` (regel 2050)
3. Parseert `\033]<value>;<textParameter><terminator>`
4. Switch op `value` — huidige cases: 0/1/2 (title), 4 (colors), 9 (notification), 10/11/12 (fg/bg/cursor color), 52 (clipboard), 104/110/111/112/119 (reset colors)
5. `default:` → `unknownParameter(value)` — logt warning, gaat verder

**OSC 133 toevoegen:**
```java
case 133:
    // Shell prompt marker (OSC 133). Format: \033]133;D\007
    // D = command finished. A = prompt start, B = command start, C = command end.
    if ("D".equals(textParameter) || textParameter.startsWith("D;")) {
        mSession.onCommandFinished();
    }
    break;
```

**Callback chain:** OSC 9 (desktop notification) is het exacte model:
- `TerminalEmulator` → `mSession.onDesktopNotification(body)` (delegate naar `TerminalOutput`)
- `TerminalSession.onDesktopNotification(body)` → `mClient.onDesktopNotification(this, body)`
- `TermuxTerminalSessionActivityClient.onDesktopNotification(session, body)` — doet echte werk

**Wat toegevoegd moet worden:**

In `TerminalOutput` (abstract klasse):
```java
public abstract void onCommandFinished();
```

In `TerminalSession`:
```java
@Override
public void onCommandFinished() {
    mClient.onCommandFinished(this);
}
```

In `TerminalSessionClient` (interface):
```java
void onCommandFinished(@NonNull TerminalSession session);
```

In `TermuxTerminalSessionActivityClient`:
```java
@Override
public void onCommandFinished(@NonNull TerminalSession session) {
    // Notify Flutter via Pigeon
    mActivity.onCommandFinished(session);
}
```

**Let op:** `TerminalOutput` is de abstracte superklasse van `TerminalSession`. Beide moeten de methode krijgen. `TermuxTerminalSessionClientBase` (in termux-shared) implementeert ook `TerminalSessionClient` — die moet een lege default krijgen of ook de methode implementeren.

### Session Management

**Hoe dedicated awareness sessie aanmaken:**

`TermuxService.createTermuxSession(String executablePath, String[] arguments, String stdin, String workingDirectory, boolean isFailSafe, String sessionName)` — dit is de publieke API. Aanroepen met:
- `executablePath = null` → gebruikt default shell
- `sessionName = "SOUL"` → herkenbaar label in tab bar
- Index ophalen via `getIndexOfSession(newSession.getTerminalSession())`

**Belangrijke details:**
- Session leven in `TermuxService`, niet view-bound — overleven sheet minimize
- Max 8 sessies (`MAX_SESSIONS = 8` in `TermuxTerminalSessionActivityClient`)
- Session is geselecteerd via `switchToSession(index)` — awareness sessie moet niet automatisch geselecteerd worden (gebruiker zit al in een andere sessie)
- `finishIfRunning()` sluit sessie — awareness sessie moet niet closable zijn door gebruiker (tab bar long-press moet deze tab overslaan)

**Sessie identificatie probleem:** Sessies worden geïndexeerd op positie (`int id`), maar positie verandert als eerdere sessies gesloten worden. Voor awareness sessie is een stabiele reference nodig — bewaar `TerminalSession` object reference, niet index.

### Output Pipeline

**Huidige state:**

`SoulBridgeController.onTerminalTextChanged(TerminalSession session)`:
- 100ms debounce via `Handler.postDelayed()`
- Leest `session.getEmulator().getScreen().getTranscriptText()`
- Splitst op `\n`, pakt laatste 50 regels
- Stuurt via `mSoulBridge.onTerminalOutput(lastLines, reply -> {})`

**Verbinding ontbreekt:** `onTextChanged()` in `TermuxTerminalSessionActivityClient` roept `SoulBridgeController` niet aan. De controller is ook nooit geïnstantieerd.

**`getTranscriptText()` werking** (`TerminalBuffer.java` regel 40):
```java
public String getTranscriptText() {
    return getSelectedText(0, -getActiveTranscriptRows(), mColumns, mScreenRows).trim();
}
```
Geeft volledige scrollback + scherm terug als plain text, zonder ANSI codes (buffer slaat al gerenderd tekst op, ANSI is al verwerkt door de emulator).

**Cruciale bevinding:** `getTranscriptText()` geeft geen ANSI escape codes terug — de emulator heeft die al verwerkt tijdens het renderen. De terminal buffer bevat plain tekst + kleur-metadata. ANSI stripping op het transcriptpatroon is dus minder relevant dan verwacht. Maar: sommige terminalprogramma's (Claude Code, vim) schrijven ook control characters die als tekst in de buffer terechtkomen. Stripping blijft nodig.

---

## Technical Approach

### 1. Structured Command API (AWAR-01)

**Pigeon definitie uitbreiden** (`flutter_module/pigeons/terminal_bridge.dart`):

```dart
/// Send raw input to a specific terminal session (voor awareness sessie).
void sendInput(int sessionId, String text);

/// Run a command structured (executable + args) in the awareness session.
void runCommand(int sessionId, String executable, List<String> args);
```

**Java implementatie** (`TerminalBridgeImpl`):

`sendInput(Long sessionId, String text)`:
- Zoek session op index (of sla awareness session reference op)
- `session.write(text)` — zonder automatische `\n` (runCommand voegt die toe)

`runCommand(Long sessionId, String executable, List<String> args)`:
1. Valideer tegen destructieve patronen (AWAR-05) — gooi SecurityException als geblokkeerd
2. Bouw command string: `executable + " " + args.join(" ")` — maar met shell quoting
3. Schrijf naar terminal: `session.write(commandString + "\n")`

**Pigeon en `List<String>`:** Pigeon ondersteunt `List<String>` natively als `List<Object?>` in Java. Geen extra code nodig — gegenereerde Java heeft `List<String>` cast automatisch.

**Alternatief: security op Dart-kant?** Context besluit (09-CONTEXT.md): pattern matching op structured args, niet raw string. Beste locatie: **Java-kant** (`TerminalBridgeImpl.runCommand()`) omdat:
1. Security moet niet afhankelijk zijn van Dart-code die omzeild kan worden
2. Java-kant is de "gate" voor alle terminaltoegang
3. AlertDialog vanuit Java is eenvoudiger (mActivity beschikbaar)

**Shell injection risico:** `runCommand(executable, args[])` is structured maar uiteindelijk schrijft het naar een shell. Als `executable = "bash"` en `args = ["-c", "rm -rf /"]` — dan pakt de blacklist dit op `args` door te scannen. De executable+args worden samengevoegd en als string naar shell geschreven — dit is inherent een shell-context.

### 2. Output Stream (AWAR-02)

**Aanpassingen nodig:**

1. `SoulBridgeController` instantiëren in `TermuxActivity` (naast `mTerminalBridgeImpl`)
2. `SoulBridgeController.setup(messenger)` aanroepen in `setupPigeonBridges()`
3. `SoulBridgeController` doorgeven aan `TermuxTerminalSessionActivityClient`
4. In `TermuxTerminalSessionActivityClient.onTextChanged()`:
   ```java
   mSoulBridgeController.onTerminalTextChanged(changedSession);
   ```
5. Awareness-sessie filtering: alleen output van de awareness sessie streamen naar SOUL? Of alle sessies? — context zegt "awareness sessie" maar voor AWAR-02 ("SOUL ontvangt terminal output stream") is het logischer om de awareness sessie te targeten

**SoulBridgeApi.onTerminalOutput ontvangen in Dart:**
- Nu: `SoulApp.onTerminalOutput()` logt alleen → moet output doorrouten naar `SoulAwarenessService`
- `SoulAwarenessService` (nieuw) moet geregistreerd zijn als provider
- `SoulApp` heeft toegang via `ProviderContainer` (UncontrolledProviderScope patroon)

### 3. OSC 133 Prompt Detection (AWAR-03)

**Implementatievolgorde:**

1. `TerminalOutput` abstract class: voeg `onCommandFinished()` toe
2. `TerminalSession`: implementeer door te delegeren naar `mClient`
3. `TerminalSessionClient` interface: voeg `onCommandFinished(@NonNull TerminalSession)` toe
4. `TermuxTerminalSessionClientBase` (termux-shared): lege implementatie toevoegen (om downstream compilers niet te breken)
5. `TermuxTerminalSessionActivityClient`: override, notify via `mActivity`
6. `TermuxActivity`: roep `mSoulBridgeController.onCommandFinished(session)` aan
7. `SoulBridgeController`: nieuwe methode `onCommandFinished()` die Pigeon callback vuurt
8. Pigeon: `onCommandCompleted(int sessionId)` toevoegen aan `SoulBridgeApi` (FlutterApi)
9. `SoulApp` (Dart): `onCommandCompleted()` implementeren → `SoulAwarenessService`
10. `TerminalEmulator.doOscSetTextParameters()`: case 133 toevoegen

**OSC 133 formaat:**
- `\033]133;A\007` — prompt start (voor prompt verschijnt)
- `\033]133;B\007` — command start (gebruiker heeft enter gedrukt)
- `\033]133;C\007` — command output start
- `\033]133;D\007` — command finished (shell klaar, volgende prompt verschijnt)

Wij wachten op `D` (command finished). `A` is ook nuttig voor "shell is klaar" detectie maar `D` is het correcte signaal.

**Shell configuratie (Phase 10 dependency):**
- bash: `PROMPT_COMMAND='printf "\033]133;D\007"'`
- zsh: `precmd() { printf "\033]133;D\007" }`

OSC 133 werkt alleen als de shell dit emits. Phase 9 implementeert de parser; Phase 10 (onboarding) configureert de shell. Voor Phase 9 testen: handmatig in awareness sessie `printf "\033]133;D\007"` typen.

**Timeout fallback:** Als OSC 133 nooit komt (shell niet geconfigureerd), blokkeer queue dan na 30 seconden met een timeout.

### 4. UI Indicator (AWAR-04)

**Bestaande widgets als model:**

`TaskProgressCard` (`flutter_module/lib/ui/chat/widgets/task_progress_card.dart`):
- Container met `CircularProgressIndicator` (16x16, strokeWidth 2)
- `LinearProgressIndicator`
- Tekst voor huidige stap
- Mono font output blok (optioneel)

`AutonomousSessionIndicator` (`flutter_module/lib/ui/chat/widgets/autonomous_session_indicator.dart`):
- Pulserende dot animatie via `AnimationController` (1500ms, repeat reverse)
- Elapsed timer

**Terminal indicator widget (`TerminalCommandIndicator`):**

Nieuw widget, stijl vergelijkbaar met `TaskProgressCard`:
- `Container` met `colorScheme.surfaceContainerHigh` achtergrond
- `CircularProgressIndicator` (16x16)
- Tekst: `"Uitvoeren in terminal..."` + command naam
- `GestureDetector.onTap` → `_openTerminalSheet()`
- Verdwijnt (getoond/verborgen via `SoulAwarenessService` state) na `onCommandCompleted`

**Integratie in ChatScreen:**
- `ChatScreen` observeert `soulAwarenessProvider` via `ref.watch()`
- Als state is `executing`: toon `TerminalCommandIndicator` boven message input
- Plaatsing: in de `Column` van `ChatScreen.build()`, boven `MessageInput`

**Sheet openen vanuit Flutter:**
- `TerminalBridgeApi` moet een nieuwe HostApi method krijgen: `openTerminalSheet()`
- Java: `mActivity.getBottomSheetBehavior().setState(STATE_HALF_EXPANDED)` via main thread handler
- Alternatief: MethodChannel buiten Pigeon — maar Pigeon is de vastgestelde patroon

### 5. Security Whitelist (AWAR-05)

**Locatie:** Java-kant, in `TerminalBridgeImpl.runCommand()`, vóór schrijven naar terminal

**Destructieve patronen (uit CONTEXT.md):**
```
rm -rf
dd if=
mkfs
git reset --hard
:(){:|:&};:
chmod -R 777
> /dev/sda
```

**Pattern matching op args array (niet op gecombineerde string):**
```java
private static final String[][] DESTRUCTIVE_PATTERNS = {
    {"rm", "-rf"},
    {"dd", "if="},     // 'if=' als prefix van een arg
    {"mkfs"},
    {"git", "reset", "--hard"},
    {"chmod", "-R", "777"},
};
```

Maar: `runCommand("bash", ["-c", "rm -rf /"])` omzeilt dit. De gecombineerde string moet OOK gescand worden. Aanbeveling: scan zowel individuele args als de gecombineerde executable+args string.

**AlertDialog aanmaken vanuit Java:**
```java
new AlertDialog.Builder(mActivity)
    .setTitle("Destructief commando")
    .setMessage("SOUL wil uitvoeren: " + commandDescription + "\nWeet je het zeker?")
    .setPositiveButton("Uitvoeren", (dialog, which) -> {
        // Stuur command naar terminal
        executeAfterConfirmation(session, commandString);
    })
    .setNegativeButton("Annuleren", null)
    .setCancelable(false)
    .show();
```

**Async probleem:** `runCommand()` is een Pigeon-methode (synchroon vanuit Dart). AlertDialog is asynchroon. Oplossing: `runCommand()` retourneert direct (void), dialoog blokkeert UI maar Flutter is al teruggekeerd. Na bevestiging gaat command door via lokale callback. Flutter wacht op `onCommandCompleted` — die komt later (na bevestiging en uitvoering).

**Alternatieven voor confirmation flow:**
- Java AlertDialog (meest direct, blokkeert native UI)
- Pigeon callback naar Dart → Flutter AlertDialog → Pigeon call terug (complexer, maar native Flutter look)
- Context besluit: "Native Android AlertDialog" — Java aanpak

### 6. API Key Filtering (AWAR-06)

**Locatie:** Dart-kant, in `SoulAwarenessService`, vóór opslag in SOUL memory/context

**Terminal toont altijd ongewijzigd** — filtering alleen op het pad naar AI context.

**Regex patronen:**

```dart
static final List<RegExp> _sensitivePatterns = [
  // Anthropic API keys
  RegExp(r'sk-ant-[a-zA-Z0-9\-_]{20,}'),
  // OpenAI API keys
  RegExp(r'sk-[a-zA-Z0-9]{32,}'),
  // GitHub tokens
  RegExp(r'gh[ps]_[a-zA-Z0-9]{36,}'),
  RegExp(r'github_pat_[a-zA-Z0-9_]{82}'),
  // Generic API key assignments
  RegExp(r'(?:API_KEY|TOKEN|SECRET|PASSWORD)\s*=\s*\S{8,}', caseSensitive: false),
  // Bearer tokens in headers
  RegExp(r'Bearer\s+[a-zA-Z0-9\-_\.]+\.[a-zA-Z0-9\-_\.]+\.[a-zA-Z0-9\-_]+'),
  // Basic auth passwords (base64)
  RegExp(r'Authorization:\s*Basic\s+[a-zA-Z0-9+/=]{16,}'),
];

String filterSensitiveData(String output) {
  String filtered = output;
  for (final pattern in _sensitivePatterns) {
    filtered = filtered.replaceAll(pattern, '[FILTERED]');
  }
  return filtered;
}
```

**Risico false positives:** `sk-[a-zA-Z0-9]{32,}` kan false positives geven op willekeurige strings van 32+ tekens. Afweging: false positive (gefilterde output) is beter dan false negative (API key in memory).

### 7. ANSI Stripping (AWAR-07)

**Bevinding:** `getTranscriptText()` geeft al plain tekst terug — ANSI escape codes zijn verwerkt door de emulator. De buffer bevat tekst zonder `\033[...m` sequences.

**Maar toch nodig voor:**
- Cursor-move sequences die als control characters in buffer kunnen zitten
- Bracketed paste markers
- Applicaties die control sequences in hun output embedden (bijv. tmux)

**Dart-side regex aanpak:**
```dart
static final _ansiEscapePattern = RegExp(
  r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1B\\))',
);

String stripAnsi(String input) {
  return input.replaceAll(_ansiEscapePattern, '');
}
```

Dit patroon dekt:
- CSI sequences: `\033[` gevolgd door parameters en final byte
- OSC sequences: `\033]` tot BEL of ST
- Enkele tekens: `\033` gevolgd door `@-Z` of `\-_`

**Staatsmachine vs regex:** Regex is voldoende voor normale terminaltekst. Een volledig-correct staatsmachine (zoals de terminal emulator zelf) is niet nodig voor AI context stripping — false positives zijn acceptabel.

### 8. Sheet Access (AWAR-08)

**Java kant:**

`TermuxActivity.getBottomSheetBehavior()` is al public (`public BottomSheetBehavior<View> getBottomSheetBehavior()` — regel 1267).

Nieuwe Pigeon HostApi method: `openTerminalSheet()`
```java
@Override
public void openTerminalSheet() {
    new Handler(Looper.getMainLooper()).post(() -> {
        if (mActivity != null && mActivity.getBottomSheetBehavior() != null) {
            mActivity.getBottomSheetBehavior().setState(
                BottomSheetBehavior.STATE_HALF_EXPANDED
            );
        }
    });
}
```

**Dart kant:**

`TerminalCommandIndicator.onTap`:
```dart
final bridge = TerminalBridgeApi();
await bridge.openTerminalSheet();
```

De gebruiker kan altijd ook handmatig de drag handle omhoog slepen (AWAR-08 is al deels geborgd door bestaande sheet UX).

---

## Risks and Pitfalls

### R1: TerminalOutput abstracte klasse in terminal-emulator module

`TerminalOutput` is een abstracte klasse in de `terminal-emulator` module. Elke nieuwe abstracte methode (bijv. `onCommandFinished()`) verplicht `TerminalSession` hem te implementeren, maar ook `MockTerminalOutput` in de testklasse `TerminalTestCase`. Tests breken als de mock niet bijgewerkt wordt.

**Oplossing:** Voeg een default (lege) implementatie toe in `TerminalOutput`:
```java
public void onCommandFinished() { /* default: no-op */ }
```
Dan hoeft alleen `TerminalSession` hem te overschrijven, niet de mock.

### R2: TermuxTerminalSessionClientBase in termux-shared

`TermuxTerminalSessionClientBase` in de `termux-shared` module implementeert `TerminalSessionClient`. Als `onCommandFinished()` aan de interface toegevoegd wordt, moet ook deze klasse een implementatie krijgen. Dit is een module die niet door ons gecontroleerd wordt (upstream merge risk).

**Oplossing:** Voeg de methode toe als `default void onCommandFinished(TerminalSession s) {}` in de interface (Java 8+ default methods). Dan hoeven implementors niets te wijzigen.

### R3: Pigeon code handmatig gegenereerd

Uit STATE.md: "Pigeon code handmatig gegenereerd (cmd-proxy token unavailable) — exact v22.7.0 patroon gevolgd". Bij nieuwe Pigeon methods moet de generated code handmatig uitgebreid worden. Pattern is gedocumenteerd in de bestaande gegenereerde files — consistent houden is essentieel.

**Specifiek voor `List<String>` in Pigeon HostApi:**
```java
// Java gegenereerde method signature:
void runCommand(@NonNull Long sessionId, @NonNull String executable, @NonNull List<String> args);
```
Pigeon stuurt `List<Object?>` over de wire, cast naar `List<String>` in Java. Dart stuurt `List<String>` als `List<Object?>`.

### R4: SoulBridgeController is dode code

`SoulBridgeController` is volledig geïmplementeerd maar nergens verbonden. Bij Phase 9 moet dit bevestigd worden — mogelijk oud code van Phase 3 die nooit geactiveerd is. Het is ook mogelijk dat de controller intentioneel uitgesteld is naar Phase 9. In elk geval: activeren door instantiëren + verbinden in `setupPigeonBridges()`.

### R5: onSessionListChanged niet geïmplementeerd in SoulApp

`SoulBridgeApi` abstract class heeft 3 methoden. `SoulApp implements SoulBridgeApi` moet alle 3 implementeren. `onSessionListChanged` ontbreekt in de huidige `main.dart`. Dit is een compilefout die opgelost moet worden — waarschijnlijk een lapse uit Phase 8.

### R6: Awareness sessie index instabiliteit

Session ID's zijn positie-indices die veranderen als sessies verwijderd worden. Als de awareness sessie op index 2 zit en sessie 0 of 1 gesloten wordt, schuift de index op. Bewaar altijd een directe `TerminalSession` object reference, niet een index.

### R7: AlertDialog op non-main thread

Pigeon HostApi callbacks komen aan op de main thread (Looper.getMainLooper()). AlertDialog aanmaken op de main thread is correct. Maar de callback na bevestiging (confirm-knop) loopt ook op main thread — terminal write is thread-safe. Geen probleem verwacht.

### R8: OSC 133 timing

OSC 133 `D` wordt verstuurd bij elke shell prompt, ook na handmatige commando's van de gebruiker. Als de gebruiker zelf iets typt terwijl SOUL wacht op OSC 133, kan een vroegtijdig `D` de wacht-queue onterecht deblokkeren. Mitigatie: track of SOUL het laatste commando gestuurd heeft via een flag.

### R9: Flutter TerminalScreen vs awareness

`flutter_module/lib/ui/terminal/` bevat een `TerminalScreen` met zijn eigen `TerminalSessionsProvider` (voor xterm.js/WebSocket sessies uit de oude SOUL app). Dit is **los van** de native Termux terminal. Deze Dart-kant terminal code is obsoleet in de soul-terminal context. Niet interfereren met — maar ook niet verwarren bij de indicator implementatie.

---

## Validation Architecture

### AWAR-01 Validatie
- `SoulAwarenessService.runCommand("ls", ["-la"])` via Pigeon → terminal toont `ls -la` uitvoer
- Whitelist test: `runCommand("rm", ["-rf", "~/test"])` → AlertDialog verschijnt, commando wordt NIET gestuurd totdat bevestigd

### AWAR-02 Validatie
- `SoulBridgeController.onTerminalOutput()` ontvangt callbacks bij terminal activiteit
- Flutter log: "Terminal output received: N chars" verschijnt bij typen in terminal
- Debounce: snel typen → max 10 callbacks/sec

### AWAR-03 Validatie
- Handmatig `printf "\033]133;D\007"` typen in awareness sessie → `onCommandCompleted` Pigeon callback aangeroepen
- Wacht-queue gaat niet door vóór OSC 133 ontvangen

### AWAR-04 Validatie
- `SoulAwarenessService` start command → ChatScreen toont indicator card met commando naam + spinner
- Na OSC 133 completion → indicator verdwijnt

### AWAR-05 Validatie
- `runCommand("rm", ["-rf", "/"])` → AlertDialog (nooit direct uitgevoerd)
- `runCommand("git", ["reset", "--hard"])` → AlertDialog
- `runCommand("ls", ["-la"])` → direct uitgevoerd, geen dialoog

### AWAR-06 Validatie
- Typ `echo sk-ant-api03-testkey123456` in terminal → `getTranscriptText()` geeft dit terug → na filtering: `echo [FILTERED]` in SOUL context
- Terminal zelf toont ongewijzigde output

### AWAR-07 Validatie
- `TerminalOutput` met embedded ANSI: `\033[31mHello\033[0m` → na `stripAnsi()`: `Hello`
- Edge case: OSC sequence in output → gestript

### AWAR-08 Validatie
- Tap op terminal indicator card → sheet opent naar half-expanded
- Drag handle altijd zichtbaar en bruikbaar ongeacht indicator staat

---

## Key Technical Decisions for Planner

1. **`onCommandFinished()` als default interface method** (niet abstract) — voorkomt breaking change in `TermuxTerminalSessionClientBase`

2. **Security check in Java `TerminalBridgeImpl.runCommand()`** — niet in Dart — Java is de gate

3. **`SoulBridgeController` activeren** door instantiëren in `setupPigeonBridges()` en doorgeven aan `TermuxTerminalSessionActivityClient`

4. **Awareness sessie reference bewaren als `TerminalSession` object**, niet als index

5. **`openTerminalSheet()` als nieuwe Pigeon HostApi method** — consistent met bestaand patroon

6. **`onCommandCompleted(int sessionId)` als nieuwe Pigeon FlutterApi method** — toegevoegd aan `SoulBridgeApi`

7. **ANSI stripping in Dart** (`SoulAwarenessService`) — Java stuurt raw transcript

8. **API key filtering in Dart** (`SoulAwarenessService`) — Java stuurt ongefiltered

---

*Research completed: 2026-03-21*
*Phase: 09-soul-terminal-awareness*
