---
id: todo-scrollback-buffer
title: Scrollback buffer verhogen naar 20.000 regels
priority: high
area: terminal
---

Claude Code en AI tools produceren veel output. De standaard Termux buffer van 2000 regels
is te klein — je verliest context en code snippets die net buiten beeld zijn.

## Aanpak
- Default verhogen naar 20.000 regels in TermuxPropertyConstants
- Optioneel: instelling beschikbaar maken in Settings > Terminal

## Locatie
`termux-shared/src/main/java/com/termux/shared/settings/properties/TermuxPropertyConstants.java`
— zoek op `IVALUE_TERMINAL_TRANSCRIPT_ROWS_DEFAULT`
