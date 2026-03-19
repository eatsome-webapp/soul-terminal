---
id: todo-auto-setup-dev-env
title: Auto-setup developer omgeving bij eerste start
priority: high
area: onboarding
---

Bij eerste start vraagt SOUL welke tools je gebruikt. Daarna installeert SOUL
automatisch de benodigde packages zonder dat de gebruiker de terminal hoeft te kennen.

## Flow
1. SOUL onboarding: "Wat gebruik je voor development?"
2. Opties: Claude Code / andere AI coder / alleen terminal
3. SOUL installeert op achtergrond: nodejs, git, python, openssh
4. Voortgang zichtbaar in SOUL chat ("python installeren... klaar")
5. Klaar: "Je omgeving is klaar. Zeg maar wat je wil bouwen."

## Packages per profiel
- **Claude Code gebruiker**: nodejs, git, openssh, gh (GitHub CLI)
- **Python developer**: python, git, openssh, pip
- **Algemeen**: git, curl, openssh, htop

## Technisch
- SOUL stuurt pkg install commando's via Pigeon bridge op achtergrond
- Foreground service blijft actief tijdens installatie
- Errors worden afgevangen en gemeld in SOUL chat
