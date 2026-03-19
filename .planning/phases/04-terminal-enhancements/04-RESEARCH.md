# Phase 4: Terminal Enhancements - Research

**Researched:** 2026-03-19
**Status:** Complete

## Overview

Phase 4 voegt drie onafhankelijke terminal-verbeteringen toe aan de SOUL Terminal fork van Termux:
1. **Kitty keyboard protocol** (TERM-01) — modes 1+2, zodat Neovim/Helix modifier keys correct herkennen
2. **OSC9 desktop notifications** (TERM-02) — terminal commando's kunnen Android notificaties triggeren
3. **Command palette** (TERM-03) — Ctrl+Shift+P opent een fuzzy search over sessies en acties

De drie features zijn volledig onafhankelijk van elkaar en kunnen parallel gepland en geïmplementeerd worden. Ze raken alle drie verschillende lagen van de codebase: de terminal-emulator library, de view laag, en de app laag.

---

## Feature 1: Kitty Keyboard Protocol (TERM-01)

### Current State

**KeyHandler.java** bevat de complete key-to-escape-sequence mapping. De huidige aanpak:
- `getCode(int keyCode, int keyMode, boolean cursorApp, boolean keypadApplication)` — hoofdfunctie die een escape string teruggeeft voor een keyCode + modifier combo
- `transformForModifiers(String start, int keymod, char lastChar)` — bouwt de modifier parameter in de standaard xterm stijl (`\033[1;Nm` waarbij N = 1-8 voor modifier-combinaties)
- Modifier bitmasks: `KEYMOD_SHIFT`, `KEYMOD_CTRL`, `KEYMOD_ALT`, `KEYMOD_NUM_LOCK`

**TerminalEmulator.java** verwerkt alle inkomende escape sequences:
- State machine met `ESC_CSI`, `ESC_CSI_QUESTIONMARK` etc. als states
- `doCsiQuestionMark(int b)` verwerkt `CSI ? ...` sequences — hier komen de DECSET modes binnen
- `doCsi(int b)` verwerkt standaard CSI — hier komt `CSI u` en `CSI > u` binnen
- `doCsiBiggerThan(int b)` verwerkt `CSI > ...` — bevat al DA2 (`c`) en modifyOtherKeys (`m`)
- Primary DA response: `\033[?64;1;2;6;9;15;18;21;22c` — al aanwezig (lijn 1628)

**TerminalView.java** — `onKeyDown()` en `onKeyUp()` zijn de entry points:
- `onKeyDown()` roept `mClient.onKeyDown()` aan (geeft de client kans te intercepteren), daarna `handleKeyCode()`
- `handleKeyCode()` roept `KeyHandler.getCode()` aan en stuurt het resultaat naar de terminal
- `onKeyUp()` heeft momenteel geen Kitty-gerelateerde logica — release events worden niet doorgestuurd

### Required Changes

**In TerminalEmulator.java:**

1. **Kitty mode flags** — nieuwe instance variabelen:
   ```java
   private int mKittyKeyboardMode = 0; // bitmask: bit 0=disambiguate, bit 1=report events
   ```

2. **CSI u query response** — in `doCsi(int b)`, in de bestaande `case 'u':` (lijn 861, momenteel "ignore"):
   ```
   CSI ? u  →  query current mode  →  respons: CSI ? <flags> u
   ```
   Kitty gebruikt `CSI = <flags> u` om modes te zetten en `CSI ? u` om te querien.

3. **CSI = u handler** — nieuw state `ESC_CSI_EQUALS` of afhandeling in bestaand parse pad:
   - `CSI = <flags> u` — set progressive enhancement flags (bit 0 = mode 1, bit 1 = mode 2)
   - `CSI > 0 u` — reset flags naar 0 (pop stack, maar we implementeren geen stack in v1)

4. **XTVERSION response** — in `doCsi(int b)`:
   - `CSI > 0 q` (XTVERSION) → respond: `\033P>|SOUL Terminal 1.0\033\\`
   - Apps (inclusief Neovim) querien dit voor terminal identificatie

5. **Key encoding aanpassen** — `KeyHandler.getCode()` heeft een nieuw codepath nodig wanneer Kitty mode actief is:
   - Kitty mode 1 (disambiguate): encode alle special keys als `CSI keycode ; modifiers u`
   - Kitty mode 2 (report event types): voeg event type toe (1=press, 2=repeat, 3=release)
   - Normale keys (printable chars) met modifiers: `CSI keycode ; modifiers u` (bijv. Ctrl+A = `CSI 97 ; 5 u`)

**In TerminalView.java:**

6. **onKeyUp doorsturen** — wanneer Kitty mode 2 actief:
   - `onKeyUp()` moet het emulator informeren zodat release events gestuurd worden
   - Nu doet `onKeyUp()` vrijwel niets voor terminal-gebonden keys

**In KeyHandler.java (of nieuw KittyKeyEncoder.java):**

7. **Kitty encoding functie** — nieuwe methode `getKittyCode(int keyCode, int keyMode, int eventType)`:
   - eventType: 1 (press, default), 2 (repeat), 3 (release)
   - Unicode codepoint als keycode, of functionele key codes per spec
   - Format: `CSI unicode ; modifiers u` voor gewone keys
   - Format: `CSI keynum ; modifiers ~ ` voor function keys (Kitty hergebruikt deels legacy format)

### Implementation Approach

De cleanste aanpak is het toevoegen van een `mKittyKeyboardMode` veld aan `TerminalEmulator` en dit veld doorgeven aan een nieuwe `getKittyCode()` methode in `KeyHandler`. De `TerminalView` moet `mEmulator.getKittyMode()` checken voordat het `handleKeyCode()` roept.

Concrete stappen:
1. `TerminalEmulator`: voeg `mKittyKeyboardMode` toe, handle `CSI = N u` (set), `CSI ? u` (query), `CSI > u` (reset), `CSI > 0 q` (XTVERSION)
2. `KeyHandler`: voeg `getKittyCode(keyCode, keyMode, eventType)` toe met mode 1 en 2 encoding
3. `TerminalView.handleKeyCode()`: check emulator Kitty mode, delegeer naar Kitty encoder indien actief
4. `TerminalView.onKeyUp()`: stuur release event via de Kitty encoder wanneer mode 2 actief

De Kitty keyboard protocol spec definieert de key numbers voor functional keys:
- Pijltjes, F1-F12, Insert, Delete, Home, End, PgUp, PgDn hebben vaste Kitty keynummers
- Modifier encoding: Shift=1, Alt=2, Ctrl=4, Super=8 (opgeteld + 1 als Kitty parameter)

### Risks

- **Android key event model verschilt van PC** — `onKeyUp` wordt niet altijd gefired voor soft keyboard input. Kitty mode 2 (release events) werkt alleen betrouwbaar met fysieke keyboards. Dit is acceptabel — Neovim gebruikt releases voornamelijk voor modifier-only keys (die sowieso alleen via hardware keyboard komen).
- **Bestaande `case 'u'` in `doCsi`** — al aanwezig maar doet niets (lijn 861). De `CSI = N u` sequence vereist een nieuw prefix-karakter (`=`). Dit is een ander CSI intermediate character dan de huidige state machine verwerkt. Vereist een nieuwe state `ESC_CSI_EQUALS` of afhandeling als speciale intermediate byte in de parser.
- **Kitty modifier encoding verschilt van xterm** — xterm gebruikt `N+1` als modifier parameter (Shift=2, Alt=3, Ctrl=5), Kitty gebruikt bitmask `N+1` (Shift=1+1=2 maar anders berekend). Zorgvuldige implementatie vereist.
- **Regressie risico** — `KeyHandler.getCode()` is kritiek pad voor alle toetsinvoer. Nieuwe code mag niets breken als Kitty mode niet actief is.

---

## Feature 2: OSC9 Desktop Notifications (TERM-02)

### Current State

**TerminalEmulator.doOscSetTextParameters()** (lijnen 1897-2039) is de OSC handler:
- Parst het OSC getal (bijv. `9`) en de tekst parameter na de `;`
- Bestaande cases: 0/1/2 (title), 4 (color), 10/11/12 (fg/bg/cursor color), 52 (clipboard), 104/110/111/112/119 (reset colors)
- `case 9` bestaat niet — valt nu door naar `default: unknownParameter(value)`

**TerminalSessionClient.java** interface heeft momenteel:
- `onBell()`, `onCopyTextToClipboard()`, `onPasteTextFromClipboard()`, `onColorsChanged()`, `onTitleChanged()`, `onTextChanged()`, `onTerminalCursorStateChange()`, `onSessionFinished()`
- Geen `onDesktopNotification()` methode

**TerminalOutput.java** heeft vergelijkbare callbacks maar als abstracte methoden op de output kant.

**TermuxTerminalSessionClient.java** implementeert `TerminalSessionClient`:
- `onBell()` is al geïmplementeerd (lijnen 197-211) en post audio/vibration feedback
- Heeft toegang tot `mActivity` (de `TermuxActivity`) voor Android context
- Dit is de juiste plek voor notification posting

**NotificationUtils.java** in termux-shared biedt:
- `geNotificationBuilder()` — bouwt een `Notification.Builder` met titel, tekst, intents, mode
- `setupNotificationChannel()` — maakt een notification channel aan (vereist voor Android 8+)
- Ondersteunt `NOTIFICATION_MODE_SILENT` voor stille notificaties

### Required Changes

1. **TerminalSessionClient interface** — nieuwe methode toevoegen:
   ```java
   void onDesktopNotification(TerminalSession session, String body);
   ```

2. **TermuxTerminalSessionClientBase** — default implementatie (no-op):
   ```java
   @Override
   public void onDesktopNotification(TerminalSession session, String body) {}
   ```

3. **TerminalEmulator.doOscSetTextParameters()** — nieuwe case 9:
   ```java
   case 9:
       mClient.onDesktopNotification(/* session */, textParameter);
       break;
   ```
   Opmerking: `mClient` is `TerminalSessionClient`, maar `mSession` is `TerminalOutput`. De emulator heeft geen directe referentie naar de `TerminalSession`. Kijk naar hoe `onBell` via `mSession.onBell()` op `TerminalOutput` gaat vs. hoe `onCopyTextToClipboard` via `mSession.onCopyTextToClipboard()` gaat — die gaat ook via `TerminalOutput` en daarna door naar de client. Dus de aanroep gaat via `mSession.onDesktopNotification(textParameter)` op `TerminalOutput` (nieuw), die doorgaat naar `TerminalSession.onDesktopNotification()`, die de client aanroept.

4. **TerminalOutput.java** — nieuwe abstracte methode:
   ```java
   public abstract void onDesktopNotification(String body);
   ```

5. **TermuxTerminalSessionClient** — echte implementatie:
   - Notification channel aanmaken (eenmalig in `onCreate()` of on-demand)
   - Rate limiting: `Map<String, Long> mLastNotificationTime` per sessie
   - Notification bouwen met `NotificationUtils.geNotificationBuilder()`
   - `PendingIntent` die de app opent en de juiste sessie selecteert
   - Notificatie groepering via `setGroup(sessionId)`

6. **Rate limiting** — implementatie in `TermuxTerminalSessionClient`:
   ```java
   private final Map<String, Long> mLastNotificationTime = new HashMap<>();
   private static final long NOTIFICATION_RATE_LIMIT_MS = 3000;
   ```

### Implementation Approach

De implementatie volgt precies het patroon van `onBell` en `onCopyTextToClipboard`:

```
TerminalEmulator.doOscSetTextParameters() case 9
  → mSession.onDesktopNotification(body)        [TerminalOutput]
  → TerminalSession.onDesktopNotification(body) [overschrijft TerminalOutput]
  → mClient.onDesktopNotification(this, body)   [TerminalSessionClient]
  → TermuxTerminalSessionClient.onDesktopNotification() [post Android notification]
```

Voor de notification channel: een nieuw channel `"terminal_notifications"` met naam `"Terminal Notifications"` en importance `IMPORTANCE_DEFAULT`. Dit wordt aangemaakt in `TermuxTerminalSessionClient.onCreate()`.

De `PendingIntent` voor tap-to-open: Intent naar `TermuxActivity` met een extra `EXTRA_SESSION_ID` die de sessie identificeert. `TermuxActivity.onNewIntent()` behandelt dit.

Notificatie ID per sessie: gebruik `sessionIndex * 1000` (vermijdt conflicten met de bestaande foreground notification die een vaste ID heeft).

### Risks

- **TerminalOutput vs TerminalSessionClient routing** — het pad via `TerminalOutput` vereist wijzigingen in 4 bestanden (interface, base class, TerminalSession, TerminalOutput). Niet complex maar foutgevoelig door het aantal stappen. Test elke laag apart.
- **Android notification permission (POST_NOTIFICATIONS)** — vereist op Android 13+ (API 33+). SOUL Terminal target SDK 34. De app moet de permissie aanvragen. Controleer of `TermuxActivity` dit al doet voor de foreground notification of dat dit nieuw toegevoegd moet worden.
- **Rate limiting thread safety** — `mLastNotificationTime` wordt aangesproken vanuit de terminal thread (parser) maar de map wordt beheerd in de main thread client. Synchroniseer of gebruik `ConcurrentHashMap`.
- **Notificatie ID collision** — de bestaande foreground service notification heeft een vaste ID. Kies IDs voor OSC9 notifications buiten het bestaande bereik.

---

## Feature 3: Command Palette (TERM-03)

### Current State

**TermuxTerminalViewClient.onKeyDown()** (lijnen 231-276) — verwerkt toetsencombinaties:
- Intercepteert `Ctrl+Alt+*` combinaties voor sessie switching, drawer openen, rename etc.
- `handleVirtualKeys()` verwerkt volume-knoppen
- Geen `Ctrl+Shift+P` interceptie aanwezig

**TermuxActivity.java** — de main activity:
- Heeft binding naar `TermuxService` via `mTermuxService`
- Bevat `mTermuxSessionListViewController` die de drawer sessie lijst beheert
- Is het juiste punt voor het tonen van een `DialogFragment`

**TermuxSessionsListViewController.java** — `ArrayAdapter<TermuxSession>`:
- Beheert de sessie lijst in de navigation drawer
- Data source: `mTermuxService.mTermuxSessions` (de List<TermuxSession>)
- Kan hergebruikt worden als data bron voor het command palette

**TermuxService.java** — bevat `mTermuxSessions` (List<TermuxSession>):
- Sessie namen zijn beschikbaar via `TermuxSession.getTerminalSession().mSessionName`

### Required Changes

1. **Ctrl+Shift+P interceptie in TermuxTerminalViewClient.onKeyDown()**:
   ```java
   if (e.isCtrlPressed() && e.isShiftPressed() && keyCode == KeyEvent.KEYCODE_P) {
       mActivity.showCommandPalette();
       return true;
   }
   ```
   Dit moet vóór de `Ctrl+Alt+*` check plaatsen.

2. **CommandPaletteItem data class** (nieuw, eenvoudig POJO):
   ```java
   class CommandPaletteItem {
       String label;
       String subtitle; // optioneel
       Runnable action;
   }
   ```

3. **CommandPaletteDialogFragment** (nieuw, `DialogFragment`):
   - Layout: `DialogFragment` met `EditText` (zoekveld bovenaan) + `RecyclerView` (resultaten)
   - `RecyclerView.Adapter` met simple twee-regel list items
   - `TextWatcher` op EditText die de lijst filtert bij elke keystroke
   - Fuzzy matching: `String.contains(query.toLowerCase())` is voldoende voor v1 (beslissing uit CONTEXT.md)
   - ESC of buiten klikken sluit het dialoog

4. **CommandPaletteDataProvider** (of inline in Fragment):
   Items om te doorzoeken:
   - Sessies: voor elke `TermuxSession`: label = sessiename of "Session N", action = `switchToSession(session)`
   - Ingebouwde acties:
     - "New session" → `addNewSession(false, null)`
     - "Kill session" → sluit huidige sessie
     - "Rename session" → `renameSession(currentSession)`
     - "Toggle Flutter view" (vooruit kijken naar Phase 3, maar nu al placeholder)

5. **TermuxActivity.showCommandPalette()** (nieuwe methode):
   ```java
   public void showCommandPalette() {
       CommandPaletteDialogFragment fragment = CommandPaletteDialogFragment.newInstance(getItems());
       fragment.show(getFragmentManager(), "command_palette");
   }
   ```

### Implementation Approach

**UI structuur** — minimale implementatie:
```
CommandPaletteDialogFragment extends DialogFragment
  ├── EditText (search input)
  └── RecyclerView
        └── CommandPaletteAdapter extends RecyclerView.Adapter
              └── CommandPaletteViewHolder
```

**Filtering** — inline in de adapter bij `filter(query)` aanroep vanuit TextWatcher. Geen externe library nodig: `item.label.toLowerCase().contains(query.toLowerCase())`.

**Dialoog styling** — voor consistentie met de rest van de Termux UI: gebruik `AlertDialog` of een `DialogFragment` met het bestaande Material theme. Geen custom achtergrond kleur nodig in v1.

**Fragment Manager** — `TermuxActivity` extends `Activity` (niet `AppCompatActivity`). Gebruik `getFragmentManager()` (Android framework, niet AndroidX) en `extends DialogFragment` (android.app, niet androidx).

**Key shortcut registratie** — in `TermuxTerminalViewClient.onKeyDown()`. Het bestaande `Ctrl+Alt+*` pattern toont dat dit de juiste plek is. `Ctrl+Shift+P` heeft geen conflict met bestaande shortcuts.

### Risks

- **Fragment Manager** — `TermuxActivity` extends `android.app.Activity`, niet `AppCompatActivity`. Dit betekent `android.app.DialogFragment` (deprecated maar functioneel) of refactoring naar AppCompatActivity. Check of andere dialogs in het project al `android.app.DialogFragment` gebruiken (`TextInputDialogUtils` is al in gebruik — check of dat ook het framework DialogFragment is).
- **Ctrl+Shift+P op soft keyboard** — de meeste Android soft keyboards leveren geen `Ctrl+Shift+P` event. Dit is een feature voor externe keyboards. Dat is acceptabel: de command palette is bewust een power-user feature.
- **Fragment lifecycle bij scherm rotatie** — als de gebruiker het scherm roteert terwijl het palette open is, kan de activity opnieuw aangemaakt worden. Zorg dat `CommandPaletteDialogFragment` retainInstance correct afhandelt of dat er geen crash optreedt.
- **Sessie data toegang** — de fragment heeft toegang nodig tot de sessie lijst. Geef dit mee via `newInstance(ArrayList<CommandPaletteItem>)` zodat de fragment zelf geen verwijzing naar Activity of Service nodig heeft (betere lifecycle).

---

## Cross-Cutting Concerns

### Build modules

De drie features raken verschillende Gradle modules:
- `terminal-emulator` — Kitty keyboard (TerminalEmulator, KeyHandler), OSC9 (TerminalEmulator, TerminalOutput, TerminalSessionClient)
- `terminal-view` — Kitty keyboard (TerminalView)
- `termux-shared` — OSC9 (TermuxTerminalSessionClientBase)
- `app` — alle drie (TermuxTerminalViewClient, TermuxTerminalSessionClient, TermuxActivity + nieuw CommandPaletteDialogFragment)

Volgorde van implementatie per feature: bibliotheek-lagen eerst, daarna app-laag.

### Java (geen Kotlin, geen AndroidX voor dialogs)

De volledige codebase is Java. Alle nieuwe code moet ook Java zijn. Voor dialogs: gebruik `android.app.DialogFragment` of `AlertDialog.Builder` — niet AndroidX.

### Geen automatische tests in de bestaande codebase

Er is geen bestaand test framework opgezet. Validatie is handmatig (zie Validation Architecture).

---

## Validation Architecture

### TERM-01: Kitty Keyboard Protocol

**Testomgeving:** Neovim of Helix geïnstalleerd in de Termux bootstrap (via pkg).

**Stap-voor-stap validatie:**

1. **Protocol detectie** — start Neovim, voer `:checkhealth` uit. Neovim rapporteert of Kitty keyboard protocol actief is. Zonder onze implementatie: "not supported". Met implementatie: "active (mode 1+2)".

2. **Modifier keys** — in Neovim:
   - `Ctrl+Shift+F` moet werken (in standaard xterm encoding werkt dit niet correct)
   - Modifier-only keys (`Ctrl` indrukken zonder andere key) — in mode 2 moet Neovim dit zien

3. **XTVERSION query** — vanuit shell: `printf '\033[>0q'` — respons moet `SOUL Terminal 1.0` bevatten

4. **CSI u query** — vanuit shell: `printf '\033[?u'` — respons moet de huidige mode flags tonen

5. **Regressie** — normale Bash/Zsh sessie zonder Neovim/Helix: pijltjes, F-toetsen, Tab, Enter moeten nog steeds correct werken

**Automatable test:** Een eenvoudig shell script kan `printf` gebruiken om escape sequences te sturen en de respons te lezen via `read -t`. Dit kan lokaal getest worden in de terminal zelf.

### TERM-02: OSC9 Notifications

**Validatie commando** (in elke shell sessie):
```bash
printf '\033]9;Build complete!\007'
```

**Verwacht resultaat:**
1. Een Android notificatie verschijnt met:
   - Titel: sessiename (bijv. "Session 1")
   - Body: "Build complete!"
2. Tikken op de notificatie opent SOUL Terminal en switcht naar de juiste sessie

**Rate limiting test:**
```bash
for i in $(seq 1 10); do printf '\033]9;Spam $i\007'; done
```
Verwacht: maximaal 1 notificatie per 3 seconden (dus ~3-4 notificaties zichtbaar, niet 10).

**Permission test:** eerste keer sturen van OSC9 sequence — als POST_NOTIFICATIONS niet verleend is, moet de app een permission request tonen (Android 13+).

**Multi-sessie test:** stuur OSC9 vanuit sessie 1 én sessie 2 — notificaties moeten gegroepeerd zijn per sessie.

### TERM-03: Command Palette

**Keyboard shortcut test:**
1. Verbind een extern toetsenbord (of gebruik Hacker's Keyboard soft keyboard)
2. Druk `Ctrl+Shift+P`
3. Verwacht: command palette dialoog verschijnt met zoekbalk en lijst

**Zoekfunctionaliteit:**
1. Typ "new" — verwacht: "New session" verschijnt in gefilterde lijst
2. Typ "sess" — verwacht: alle sessie items verschijnen
3. Typ volledig random string — verwacht: lege lijst, geen crash

**Actie uitvoering:**
1. Selecteer "New session" — verwacht: nieuwe terminalsessie aangemaakt, palette gesloten
2. Selecteer een sessie item — verwacht: geswitcht naar die sessie, palette gesloten

**Sluiten:**
1. Tik buiten het dialoog — verwacht: dialoog sluit
2. (Als extern keyboard) ESC of Back — verwacht: dialoog sluit

---

## RESEARCH COMPLETE
