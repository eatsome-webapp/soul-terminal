---
id: todo-native-permission-dialogs
title: Native Android dialogs voor Claude Code permissie-prompts
priority: medium
area: ux/ai-integration
---

Claude Code vraagt regelmatig bevestiging: "Do you want to proceed?", "Allow file deletion?".
Nu moet de gebruiker de terminal openen en ja/nee typen. Dit kan veel beter.

## Gedrag
- SOUL herkent permissie-prompt in terminal output via patroon-matching
- Native Android dialog verschijnt bovenop wat de gebruiker ook doet
- Gebruiker tikt "Ja" of "Nee"
- SOUL stuurt antwoord naar terminal via Pigeon bridge
- Optioneel: "Altijd toestaan voor deze sessie"

## Patronen om te herkennen
- "Do you want to proceed? (y/n)"
- "Allow Claude to [actie]? (yes/no)"
- "Are you sure? (y/n)"
- Aanpasbaar via instellingen

## Technisch
- Output stream monitoren via SoulBridgeApi.onTerminalOutput()
- Regex matching op bekende Claude Code prompts
- showPermissionDialog() Pigeon call → Java toont AlertDialog
- Antwoord via sendInput(sessionId, "y\n") of ("n\n")
