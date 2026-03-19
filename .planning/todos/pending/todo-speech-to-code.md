---
id: todo-speech-to-code
title: Speech-to-code — inspreken in SOUL stuurt Claude Code aan
priority: low
area: ux/later-stadium
---

## Later stadium

Je spreekt in SOUL: "Voeg een login scherm toe aan de app."
SOUL vertaalt dit naar een Claude Code prompt en stuurt het naar de terminal sessie.

## Flow
- Microfoon knop in SOUL chat
- Spraak → tekst via Android SpeechRecognizer (on-device, privacy)
- SOUL interpreteert intentie en formuleert Claude Code prompt
- Bevestiging tonen aan gebruiker voor verzenden
- Verzenden naar Claude Code terminal sessie

## Waarom waardevol
- Coderen zonder typen — op de bank, in de auto (als passagier), onderweg
- Termly (concurrent) biedt dit al — SOUL moet dit ook hebben voor open source lancering
- Verlaagt drempel voor non-technical vibecoders

## Technisch
- Android SpeechRecognizer API (geen internet vereist)
- Integratie met Pigeon bridge sendInput()
- Optioneel: Whisper lokaal draaien voor betere kwaliteit
