---
phase: 05
plan: 01
status: complete
completed: 2026-03-20
---

# Plan 05-01: Terminal defaults en SOUL branding

## Result
Scrollback buffer verhoogd naar 20.000 regels, extra keys geoptimaliseerd voor Claude Code workflows, SOUL kleurthema ingesteld als terminal default (bg #0F0F23, fg #E0E0E0, cursor #6C63FF), en SOUL branding doorgevoerd in zowel light als night theme voor drawer en extra keys.

## Tasks
| # | Task | Status |
|---|------|--------|
| 1 | Scrollback buffer verhogen naar 20.000 regels | complete |
| 2 | Extra keys layout optimaliseren voor Claude Code | complete |
| 3 | SOUL kleurthema als terminal default instellen | complete |
| 4 | SOUL kleuren toevoegen aan colors.xml | complete |
| 5 | SOUL branding in light theme (values/themes.xml) | complete |
| 6 | SOUL branding in dark/night theme (values-night/themes.xml) | complete |

## Key Files Modified
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java`: DEFAULT_TERMINAL_TRANSCRIPT_ROWS 2000 -> 20000
- `termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java`: Extra keys layout met Claude Code shortcuts (^C, ^D, ^Z, ^L macros)
- `terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java`: Foreground/background/cursor naar SOUL kleuren
- `termux-shared/src/main/res/values/colors.xml`: soul_bg, soul_fg, soul_accent, soul_accent_dim toegevoegd
- `app/src/main/res/values/themes.xml`: Volledige SOUL branding, ButtonBarStyle.Light -> Dark
- `app/src/main/res/values-night/themes.xml`: Identieke SOUL branding als light theme

## Self-Check: PASSED
- Task 1: DEFAULT_TERMINAL_TRANSCRIPT_ROWS = 20000 (1 match), MAX = 50000 ongewijzigd (1 match)
- Task 2: CTRL C (1), CTRL D (1), Claude Code optimized (1), macro syntax aanwezig
- Task 3: 0xffE0E0E0 (1), 0xff0F0F23 (1), 0xff6C63FF (1)
- Task 4: soul_bg (1), soul_fg (1), soul_accent (2 incl. soul_accent_dim), soul_accent_dim (1)
- Task 5: soul_accent (4), soul_bg (3), soul_accent_dim (1), soul_fg (2), ButtonBarStyle.Dark (1), red_400 (0)
- Task 6: soul_accent (4), soul_bg (3), soul_accent_dim (1), soul_fg (2), red_400 (0)
