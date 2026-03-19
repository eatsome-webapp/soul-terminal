---
id: todo-session-management
title: Vlekkeloos sessie management voor terminal
priority: high
area: ux/terminal
---

## Doel
Meerdere terminal sessies beheren vanuit zowel de terminal sheet als vanuit SOUL.
Claude Code, git, python — elk in een eigen benoemde sessie.

## Features
- Named sessions: naam gebaseerd op draaiend process (claude, bash, python)
- Persistent sessions: app herstarten = sessies nog actief (via foreground service)
- Quick switcher: swipe links/rechts binnen terminal sheet of via tab bar
- SOUL kan via Pigeon sessies aanmaken, selecteren en output lezen
- Sessie status zichtbaar: actief (groen), wachtend (grijs), error (rood)

## Sessie switcher UI
- Tab bar bovenin terminal sheet met sessienamen
- Lang indrukken op tab → hernoemen of sluiten
- + knop voor nieuwe sessie
- Maximaal 8 gelijktijdige sessies

## Pigeon API uitbreidingen
- getSessions() → List<SessionInfo>
- createSession(name, command) → SessionInfo
- switchSession(sessionId)
- closeSession(sessionId)
- getSessionOutput(sessionId) → String (laatste N regels)
