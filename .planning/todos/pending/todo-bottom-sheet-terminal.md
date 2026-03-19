---
id: todo-bottom-sheet-terminal
title: Terminal als native bottom sheet in SOUL app
priority: high
area: ux/architecture
---

## Doel
Flutter (SOUL chat) is het standaard scherm. Terminal schuift omhoog als native bottom sheet.
Naadloze overgang, terminal draait altijd door op achtergrond.

## Architectuur
- TermuxActivity: FrameLayout met twee lagen
  - Laag 1 (onder): TerminalView (altijd actief, ook als verborgen)
  - Laag 2 (boven): FlutterFragment (SOUL chat UI)
- Swipe omhoog op Flutter view → Java slideUp animatie op TerminalView
- Swipe omlaag in terminal → Java slideDown, Flutter weer zichtbaar
- Pigeon message: showTerminal() / hideTerminal() vanuit Flutter
- Terminal krijgt focus bij openen, Flutter herneemt focus bij sluiten

## Animatie specs
- Duur: 280ms
- Easing: FastOutSlowIn (Material standaard)
- Handle bar bovenaan terminal sheet (zoals Android bottom sheets)
- Backdrop: lichte dimming van SOUL UI tijdens sliding

## Wat NIET mag
- Geen Flutter PlatformView voor terminal (performance)
- Terminal process mag NOOIT stoppen als sheet dicht is
- Geen Activity switch — alles binnen één TermuxActivity

## Deeltaken
- [ ] Layout refactor: FrameLayout met terminal onder Flutter
- [ ] Java slide animatie implementeren
- [ ] Gesture detector op Flutter kant (swipe up trigger)
- [ ] Pigeon API uitbreiden: showTerminal / hideTerminal / isTerminalVisible
- [ ] Handle bar UI element toevoegen aan terminal sheet
- [ ] Back button gedrag: sluit sheet (niet app)
- [ ] State bewaren bij roteren
