---
id: todo-ux-polish
title: UX polish terminal sheet — hoge standaard voor open source lancering
priority: medium
area: ux
---

## Details die het verschil maken

### Handle bar & sheet gedrag
- Pill-vormige handle bar bovenaan sheet (standaard Material bottom sheet)
- Gedeeltelijk openen mogelijk: 40% hoogte voor snelle check, volledig voor werk
- Velocity-based: snel omhoog = altijd full screen, langzaam = tussenpositie

### Keyboard gedrag
- Terminal sheet past hoogte aan bij softceyboard (resize, niet pan)
- SOUL chat scrollt weg achter keyboard (standaard Flutter gedrag)

### Haptic feedback
- Lichte trillingen bij openen/sluiten sheet
- Trillen bij sessie switch

### Visuele continuïteit
- Terminal sheet heeft licht doorzichtige achtergrond bij gedeeltelijke hoogte
- Blur effect achter sheet (SOUL UI wazig zichtbaar)

### Landscape mode
- Terminal sheet wordt side drawer in landscape (schuift van rechts)
- SOUL chat links, terminal rechts — split view op tablets

### Toegankelijkheid
- Content descriptions op alle knoppen
- TalkBack support voor sheet open/dicht
