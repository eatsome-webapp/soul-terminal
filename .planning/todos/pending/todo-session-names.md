---
id: todo-session-names
title: Sessienamen tonen in toolbar (bijv. "claude", "flutter", "git")
priority: medium
area: ui
---

Bij meerdere terminalsessies is het niet duidelijk welke sessie welke is.
Voor Claude Code gebruik wil je snel kunnen zien: welke tab is de claude sessie?

## Gedrag
- Sessie krijgt automatisch een naam op basis van het draaiende process
- Of: gebruiker kan sessie handmatig benoemen (lang indrukken op tab)
- Naam zichtbaar in de sessies-sidebar

## Aanpak
- TermuxService/TermuxSession uitbreiden met naam-tracking
- Process-naam uitlezen via /proc/$PID/cmdline
