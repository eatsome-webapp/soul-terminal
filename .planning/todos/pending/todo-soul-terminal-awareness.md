---
id: todo-soul-terminal-awareness
title: SOUL krijgt bewustzijn van terminal — kan lezen en schrijven
priority: high
area: ai-integration
---

## Doel
SOUL kan zelfstandig de terminal gebruiken. Commando uitvoeren, output lezen,
reageren op fouten — zonder dat de gebruiker de sheet hoeft te openen.

## Wat SOUL moet kunnen
- Commando sturen naar actieve sessie (stdin inject)
- Output lezen van een sessie (stdout stream)
- Weten welke sessies actief zijn
- Nieuwe sessie aanmaken voor een specifieke taak
- Detecteren of een commando klaar is (prompt verschijnt)

## Pigeon API (aanvulling op session management)
- sendInput(sessionId, text) — stuurt tekst als alsof gebruiker typt
- subscribeToOutput(sessionId) — stream van output updates
- waitForPrompt(sessionId, timeoutMs) — wacht tot sessie klaar is

## UX
- Als SOUL een commando uitvoert: kleine indicator in SOUL chat ("uitvoeren in terminal...")
- Gebruiker kan altijd de terminal sheet openen om te zien wat er gebeurt
- SOUL vraagt NOOIT toestemming voor read-only operaties
- SOUL vraagt WEL toestemming voor destructieve commando's (rm, git reset etc.)

## Privacy / veiligheid
- SOUL leest geen sessies die de gebruiker niet heeft aangemaakt via SOUL
- API keys en wachtwoorden worden niet gelogd in SOUL memory
