---
id: todo-path-tap-copy
title: Bestandspaden en URLs aanklikbaar maken (tap-to-copy / open)
priority: medium
area: ui
---

Claude Code print veel bestandspaden in zijn output (bijv. `~/soul-app/lib/main.dart:42`).
Nu moet je die handmatig selecteren. Aanklikbaar maken verhoogt de snelheid enorm.

## Gedrag
- Lang indrukken op een pad → context menu: "Kopieer pad" / "Open in editor"
- URL's in output → tap opent browser

## Aanpak
- TerminalView.java uitbreiden met URL/pad detectie regex
- Bestaande OSC8 hyperlink ondersteuning als basis gebruiken indien aanwezig

## Prioriteit
Medium — handig maar niet blokkerend
