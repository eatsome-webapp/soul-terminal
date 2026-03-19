---
id: todo-claude-code-auto-config
title: Claude Code automatisch configureren bij onboarding
priority: high
area: onboarding
---

Als gebruiker Claude Code kiest bij onboarding configureert SOUL alles automatisch.
Geen handmatige stappen, geen terminal kennis vereist.

## Wat geconfigureerd wordt
- `npm install -g @anthropic-ai/claude-code` via pkg/npm
- API key invoeren in SOUL chat → SOUL schrijft naar ~/.claude/config
- GitHub CLI authenticatie (gh auth login) via SOUL flow
- CLAUDE.md template aanmaken met project context
- proot-distro Ubuntu installeren indien gewenst

## UX
- Alles via conversatie in SOUL chat
- API key nooit zichtbaar in terminal of logs
- Na setup: "Claude Code is klaar. Open de terminal en typ 'claude' om te starten."

## Technisch
- API key opslaan via Android Keystore (niet plaintext)
- SOUL schrijft config files via Pigeon bridge
- npm global install via nodejs package in SOUL Terminal
