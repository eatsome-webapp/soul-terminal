# Phase 4: Terminal Enhancements - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Terminal features die power users verwachten: Kitty keyboard protocol ondersteuning zodat Neovim/Helix modifier keys correct herkennen, OSC9 escape sequence voor Android notificaties vanuit terminal commando's, en een command palette met fuzzy search over sessies en acties. Geen shell-integratie of AI features — puur terminal emulator verbeteringen.

</domain>

<decisions>
## Implementation Decisions

### Kitty keyboard protocol
- Practical subset implementeren — niet de volledige spec, focus op wat Neovim/Helix nodig hebben
- Mode 1 (disambiguate escape codes) + Mode 2 (report event types) ondersteunen
- Modes 3-5 (report alternate keys, report all keys as escape codes, report associated text) uitgesteld naar later
- Progressive enhancement via standaard CSI ? u query mechanism — apps detecteren en activeren protocol zelf
- Key release events rapporteren wanneer mode 2 actief (Neovim gebruikt dit voor modifier-only keys)
- Implementatie in KeyHandler.java + TerminalEmulator.java CSI handler
- XTVERSION response opnemen zodat apps terminal capabilities kunnen querien

### OSC9 desktop notifications
- Nieuwe case 9 in `TerminalEmulator.doOscSetTextParameters()` — format: `\033]9;body\007`
- Standard Android notification met titel (sessie naam) + body (OSC9 parameter text)
- Rate limiting: max 1 notificatie per 3 seconden per sessie — voorkomt spam bij loops
- Notificaties gegroepeerd per sessie — meerdere van zelfde sessie worden gestacked
- Tap op notificatie opent app en switcht naar de sessie die de notificatie stuurde
- Nieuwe callback `onDesktopNotification(String body)` in TerminalSessionClient interface
- Notificatie channel: apart channel "Terminal Notifications" (gebruiker kan apart muten)

### Command palette
- Trigger: Ctrl+Shift+P keyboard shortcut (VS Code conventie, herkenbaar voor developers)
- Overlay dialog met zoekbalk bovenaan en gefilterde resultatenlijst
- v1 doorzoekt: actieve sessies (naam, index) + ingebouwde acties (new session, kill session, toggle Flutter view, rename session)
- Command history zoeken uitgesteld naar v2
- UI: DialogFragment met RecyclerView + EditText filter
- Fuzzy matching: Claude's Discretion (simpele substring/contains match voldoende voor v1 scope)

### Claude's Discretion
- Exacte Kitty protocol CSI encoding details (volg de spec)
- Fuzzy matching algoritme keuze voor command palette
- Command palette max items en scroll gedrag
- Notification icon en styling details
- OSC9 extended format (titel;body) ondersteuning beslissen op basis van wat gangbaar is

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Kitty keyboard protocol
- Kitty keyboard protocol spec: https://sw.kovidgoyal.net/kitty/keyboard-protocol/ — Volledige protocolspecificatie, focus op modes 1-2
- `terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java` — Bestaande key mapping, TERMCAP_TO_KEYCODE, modifier handling — hier moet Kitty encoding toegevoegd worden
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` — ESC state machine, CSI handler — hier moet CSI ? u query/response en mode flags verwerkt worden
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — onKeyDown/onKeyUp callbacks — key release events moeten hier doorgestuurd worden

### OSC9 notifications
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` lines 1897-2040 — `doOscSetTextParameters()` — bestaande OSC handlers, case 9 toevoegen
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalSessionClient.java` — Callback interface, nieuwe `onDesktopNotification()` method toevoegen
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalOutput.java` — Output interface met bestaande callbacks (onBell, titleChanged)
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionClient.java` — Implementatie van callbacks, hier notification posting
- `termux-shared/src/main/java/com/termux/shared/notification/NotificationUtils.java` — Bestaande notification utilities

### Command palette
- `app/src/main/java/com/termux/app/TermuxActivity.java` — Main activity, shortcut registratie en dialog launch
- `app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java` — Key event handling, Ctrl+Shift+P interceptie
- `app/src/main/java/com/termux/app/terminal/TermuxSessionsListViewController.java` — Bestaande sessie lijst adapter, herbruikbaar voor palette data
- `app/src/main/java/com/termux/app/TermuxService.java` — Session management, sessie lijst ophalen

### Project context
- `.planning/REQUIREMENTS.md` — TERM-01 (Kitty), TERM-02 (OSC9), TERM-03 (command palette)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **KeyHandler.java**: Complete key-to-escape-sequence mapping — Kitty protocol voegt alternatieve encoding toe naast bestaande
- **TerminalEmulator ESC state machine**: Robuust en bewezen — OSC9 is simpele case toevoeging in bestaand switch statement
- **NotificationUtils**: Bestaande notification helper in termux-shared — herbruikbaar voor OSC9 notificaties
- **TermuxSessionsListViewController**: Session list adapter — data kan hergebruikt worden voor command palette sessie items
- **TerminalView onKeyDown/onKeyUp**: Bestaande key event routing — Kitty release events haken hier in

### Established Patterns
- **Callback interfaces**: TerminalSessionClient en TerminalOutput definiëren callbacks voor terminal events — nieuwe events volgen dit patroon
- **ESC state machine**: Byte-voor-byte processing met state transitions — alle escape sequence handling volgt dit patroon
- **Java codebase**: Alle terminal-emulator en app code is Java — nieuwe code ook in Java
- **Service binding**: TermuxActivity bindt aan TermuxService via ServiceConnection — command palette haalt sessie data via deze binding

### Integration Points
- **TerminalEmulator.doOscSetTextParameters()**: Case 9 toevoegen voor OSC9
- **TerminalEmulator CSI handler**: Kitty protocol mode flags en responses verwerken
- **KeyHandler.getCode()**: Kitty encoding als alternatief return pad
- **TerminalSessionClient interface**: Nieuwe callback methods
- **TermuxTerminalViewClient.onKeyDown()**: Ctrl+Shift+P shortcut interceptie
- **TermuxActivity**: DialogFragment launch voor command palette

</code_context>

<specifics>
## Specific Ideas

- Kitty keyboard protocol is de de-facto standaard voor moderne terminals (kitty, foot, WezTerm, ghostty) — Neovim en Helix detecteren het automatisch via CSI ? u query
- OSC9 volgt het iTerm2/ConEmu patroon — `printf '\033]9;build complete\007'` als simpele one-liner in scripts
- Command palette à la VS Code — Ctrl+Shift+P is universeel herkenbaar voor developers

</specifics>

<deferred>
## Deferred Ideas

- Kitty keyboard modes 3-5 (report alternate keys, report all keys, report associated text) — toekomstige terminal enhancement
- Command history zoeken in palette — v2 feature (SOUL-03 semantic search)
- Kitty graphics protocol (inline images) — v2 (ADVT-01)
- OSC9 met custom actions (notificatie met knoppen) — toekomstige enhancement
- Shell integration (OSC 133 command markers) — zou command detection verbeteren maar is eigen fase

</deferred>

---

*Phase: 04-terminal-enhancements*
*Context gathered: 2026-03-19*
