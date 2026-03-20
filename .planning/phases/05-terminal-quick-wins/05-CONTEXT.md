# Phase 5: Terminal Quick Wins - Context

**Gathered:** 2026-03-20
**Status:** Ready for planning

<domain>
## Phase Boundary

Pure Java/Android configuratiewijzigingen aan de terminal. Geen Flutter, geen Pigeon — snelle wins die de dagelijkse Claude Code workflow verbeteren en SOUL-branding doortrekken naar de terminal UI. Geen dependencies op andere v1.1 fasen.

</domain>

<decisions>
## Implementation Decisions

### Scrollback buffer
- Verhoog `DEFAULT_TERMINAL_TRANSCRIPT_ROWS` van 2000 naar 20000 in `TerminalEmulator.java`
- Max (`TERMINAL_TRANSCRIPT_ROWS_MAX`) is al 50000, dus 20000 past binnen bestaande grenzen

### Extra keys layout
- 2 rijen, geoptimaliseerd voor Claude Code workflow
- Rij 1 (meest-gebruikte Claude Code shortcuts): `ESC`, `TAB`, `CTRL+C`, `CTRL+D`, `CTRL+Z`, `CTRL+L`, `UP`
- Rij 2 (navigatie): `HOME`, `END`, `LEFT`, `DOWN`, `RIGHT`, `CTRL`, `ALT`
- Wijzig `DEFAULT_IVALUE_EXTRA_KEYS` in `TermuxPropertyConstants.java`

### Terminal kleurthema
- Alleen bg, fg en cursor wijzigen in `TerminalColorScheme.java` DEFAULT_COLORSCHEME array
- Achtergrond: `#0F0F23` (SOUL donkerblauw)
- Voorgrond: `#E0E0E0` (licht grijs)
- Cursor: `#6C63FF` (SOUL paars)
- ANSI 16 kleuren NIET aanpassen — risico op kapotte syntax highlighting in vim/neovim

### App chrome branding
- Drawer achtergrond: `#0F0F23` (consistent met terminal bg)
- Drawer icon tint: `#E0E0E0` (consistent met terminal fg)
- Extra keys achtergrond: `#0F0F23`
- Extra keys tekst: `#E0E0E0`
- Extra keys active state: `#6C63FF` (SOUL paars, vervangt huidige `red_400`)
- Extra keys active achtergrond: `#2A2A4A` (subtiel paars-grijs, beter bij SOUL thema dan `grey_500`)
- `colorPrimary` en `windowBackground`: `#0F0F23`
- Wijzigingen in zowel `values/themes.xml` als `values-night/themes.xml`

### Claude's Discretion
- Exacte hex waarde voor active achtergrondkleur (mits het past bij SOUL palette)
- Of extra keys text-all-caps aan of uit moet

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Terminal emulator
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` — `DEFAULT_TERMINAL_TRANSCRIPT_ROWS` (regel 151), `TERMINAL_TRANSCRIPT_ROWS_MAX` (regel 150)
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java` — `DEFAULT_COLORSCHEME` array, laatste 3 entries zijn fg/bg/cursor

### Extra keys configuratie
- `termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java` — `DEFAULT_IVALUE_EXTRA_KEYS` (regel 329)

### App theming
- `app/src/main/res/values/themes.xml` — Light theme: drawer kleuren, extra keys kleuren, colorPrimary
- `app/src/main/res/values-night/themes.xml` — Dark theme: zelfde attrs
- `app/src/main/res/values/attrs.xml` — Custom attr definities (termuxActivityDrawer*, extraKeysButton*)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `TerminalColorScheme.DEFAULT_COLORSCHEME` array: laatste 3 ints zijn fg, bg, cursor — direct aanpasbaar
- Theme attrs (`extraKeysButtonTextColor`, `termuxActivityDrawerBackground` etc.): al gedefinieerd, alleen waarden wijzigen
- Kleuren in `res/values/colors.xml`: mogelijk nieuwe SOUL kleuren toevoegen

### Established Patterns
- Terminal kleuren via hardcoded int array in `TerminalColorScheme` — ARGB format (`0xffRRGGBB`)
- App chrome via Android theme attributes in `themes.xml` — DayNight pattern met light en dark variant
- Extra keys via JSON-achtige string in properties constants — parsed door `ExtraKeysInfo`

### Integration Points
- `TermuxPropertyConstants.DEFAULT_IVALUE_EXTRA_KEYS` wordt geladen door `TermuxSharedProperties` als er geen user override is
- `TerminalColorScheme` wordt geladen bij terminal sessie start
- Theme XML wordt toegepast via `android:theme` op TermuxActivity

</code_context>

<specifics>
## Specific Ideas

- SOUL kleurpalet: bg `#0F0F23`, fg `#E0E0E0`, accent `#6C63FF` — consistent door hele app
- Extra keys moeten "één tik toegang" geven tot de meest-gebruikte Claude Code shortcuts (Esc voor menu, Tab voor autocomplete, Ctrl+C voor interrupt)
- Kleurthema en extra keys moeten app herstart overleven (dit is al het geval via defaults)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-terminal-quick-wins*
*Context gathered: 2026-03-20*
