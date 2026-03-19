---
id: todo-extra-keys-claude-code
title: Extra keys row optimaliseren voor Claude Code gebruik
priority: high
area: ui
---

Vervang de standaard Termux extra keys (ESC, -, Home, End, PgUp, PgDn) door een rij die
geoptimaliseerd is voor Claude Code en AI coder gebruik.

## Gewenste rij
`CTRL | ALT | TAB | ESC | ↑ | ↓ | / | ~ | |`

## Waarom
- CTRL en ALT staan nu niet prominent genoeg
- / en ~ zijn essentieel voor paden (~/soul-app, /data/data/...)
- Pijltjes voor command history navigatie
- | voor pipes in shell commando's
- Home/End/PgUp/PgDn zijn minder relevant bij Claude Code gebruik

## Aanpak
- `app/src/main/res/xml/termux_extra_keys.xml` aanpassen (of equivalent)
- Testen met Claude Code sessie
