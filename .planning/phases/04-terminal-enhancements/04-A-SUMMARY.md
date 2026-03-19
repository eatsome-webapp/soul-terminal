---
phase: 04-terminal-enhancements
plan: A
subsystem: terminal-emulator
tags: [kitty-keyboard-protocol, terminal, key-events, escape-sequences, android]

requires:
  - phase: 03-flutter-integration
    provides: working terminal emulator base with TerminalEmulator, KeyHandler, TerminalView

provides:
  - Kitty keyboard protocol mode 1 (disambiguate escape codes) support
  - Kitty keyboard protocol mode 2 (report event types) support
  - CSI = N u (set mode), CSI ? u (query mode), CSI > u (reset mode) handlers
  - XTVERSION response identifying as "SOUL Terminal 1.0"
  - getKittyCode() encoding for functional keys and printable chars with modifiers

affects: [neovim-integration, helix-integration, terminal-key-handling]

tech-stack:
  added: []
  patterns:
    - "Kitty keyboard protocol: CSI u format for all functional keys"
    - "Kitty mode stored as int bitmask per emulator, reset on terminal reset"

key-files:
  created: []
  modified:
    - terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java
    - terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java
    - terminal-view/src/main/java/com/termux/view/TerminalView.java

key-decisions:
  - "ESC_CSI_EQUALS = 20 als state constant — next available integer na ESC_CSI_EXCLAMATION = 19"
  - "mKittyKeyboardMode & 0x03 — alleen bits 0+1 ondersteund in v1 (modes 1+2)"
  - "isTildeKey() returns false — CSI u format voor alle keys (Kitty spec staat dit toe)"
  - "Printable char Kitty encoding alleen wanneer modified char verschilt van unmodified char"

requirements-completed: [TERM-01]

duration: 25min
completed: 2026-03-19
---

# Phase 4 Plan A: Kitty Keyboard Protocol (Modes 1+2) Summary

**Kitty keyboard protocol modes 1+2 geïmplementeerd in TerminalEmulator, KeyHandler en TerminalView — Neovim/Helix kunnen protocol detecteren via CSI ? u en modifier keys worden als CSI u sequences gerapporteerd**

## Performance

- **Duration:** 25 min
- **Started:** 2026-03-19T09:45:00Z
- **Completed:** 2026-03-19T10:10:00Z
- **Tasks:** 4
- **Files modified:** 3

## Accomplishments

- Kitty mode state (mKittyKeyboardMode) opgeslagen in TerminalEmulator, reset bij terminal reset
- CSI = N u (set), CSI ? u (query), CSI > u (reset), CSI > 0 q (XTVERSION) handlers toegevoegd
- getKittyCode() methode in KeyHandler: F1-F12, pijltjestoetsen, Home/End, PgUp/PgDn, Esc, Enter, Tab, Backspace
- handleKeyCode() in TerminalView probeert Kitty encoding vóór standaard getCode() fallback
- Key release events (eventType=3) worden gestuurd via onKeyUp() wanneer mode 2 actief is
- Printable characters met modifiers encoded als CSI codepoint ; modifiers+1 u wanneer mode 1 actief

## Task Commits

1. **Task 04-A-01: TerminalEmulator Kitty state + CSI handlers** - `9964e4a` (feat)
2. **Task 04-A-02: KeyHandler getKittyCode() methode** - `314f795` (feat)
3. **Task 04-A-03: TerminalView key event routing** - `e99d769` (feat)
4. **Task 04-A-04: Printable character Kitty encoding** - `3e20fe0` (feat)

## Files Created/Modified

- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` — ESC_CSI_EQUALS state, mKittyKeyboardMode veld, getKittyKeyboardMode() getter, CSI handlers
- `terminal-emulator/src/main/java/com/termux/terminal/KeyHandler.java` — getKittyCode(), mapKeyCodeToKittyNumber(), isTildeKey() methoden
- `terminal-view/src/main/java/com/termux/view/TerminalView.java` — Kitty routing in handleKeyCode() en onKeyUp(), printable char encoding in onKeyDown()

## Decisions Made

- **ESC_CSI_EQUALS = 20**: volgende beschikbare integer na ESC_CSI_EXCLAMATION = 19
- **mKittyKeyboardMode & 0x03**: alleen bits 0 en 1 ondersteunen in v1; modes 3+ (report all keys, report associated text) vereisen meer werk
- **isTildeKey() returns false**: CSI u format voor alle keys — Kitty spec staat dit toe en vereenvoudigt implementatie
- **Printable char check**: `unicodeChar != event.getUnicodeChar(event.getMetaState())` detecteert of modifier de character verandert

## Deviations from Plan

Geen — plan exact gevolgd als geschreven.

**Total deviations:** 0
**Impact on plan:** Geen scope creep, geen onverwachte wijzigingen.

## Issues Encountered

Geen.

## User Setup Required

Geen — geen externe service configuratie vereist.

## Next Phase Readiness

- Kitty keyboard protocol modes 1+2 klaar voor testen met Neovim/Helix via GitHub Actions build
- Verificatie vereist: `printf '\033[?u'` → `\033[?0u`, `printf '\033[=1u'` → mode actief, `printf '\033[>0q'` → `SOUL Terminal 1.0`
- Volgende plan in fase 04 kan voortbouwen op Kitty foundation

## Self-Check: PASSED

- TerminalEmulator.java bevat `ESC_CSI_EQUALS = 20` ✓
- TerminalEmulator.java bevat `mKittyKeyboardMode = 0` ✓
- TerminalEmulator.java bevat `getKittyKeyboardMode()` ✓
- TerminalEmulator.java bevat `mKittyKeyboardMode = flags & 0x03` ✓
- TerminalEmulator.java bevat `mSession.write("\033[?" + mKittyKeyboardMode + "u")` ✓
- TerminalEmulator.java bevat `SOUL Terminal 1.0` ✓
- TerminalEmulator.java bevat `case ESC_CSI_EQUALS:` ✓
- KeyHandler.java bevat `getKittyCode()` ✓
- KeyHandler.java bevat `mapKeyCodeToKittyNumber()` ✓
- KeyHandler.java bevat `case KEYCODE_ESCAPE: return 27` ✓
- KeyHandler.java bevat `case KEYCODE_F1: return 57364` ✓
- KeyHandler.java bevat `int kittyMod = 0` ✓
- KeyHandler.java bevat `sb.append(';')` ✓
- TerminalView.java bevat `term.getKittyKeyboardMode()` ✓
- TerminalView.java bevat `KeyHandler.getKittyCode(keyCode, keyMod, 1, kittyMode)` ✓
- TerminalView.java bevat `KeyHandler.getKittyCode(keyCode, keyMod, 3, term.getKittyKeyboardMode())` ✓
- TerminalView.java bevat `int kittyMode = term.getKittyKeyboardMode()` ✓
- TerminalView.java bevat `"\033[" + unicodeChar + ";" + (kittyMod + 1) + "u"` ✓
- TerminalView.java bevat `termForKitty.getKittyKeyboardMode()` ✓
- TerminalView.java bevat `event.getUnicodeChar(0)` in Kitty block ✓

---
*Phase: 04-terminal-enhancements*
*Completed: 2026-03-19*
