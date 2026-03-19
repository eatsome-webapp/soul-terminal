---
id: todo-mcp-android-server
title: Android MCP server — Claude Code krijgt Android superpowers
priority: low
area: mcp/later-stadium
---

## Later stadium — niet voor v1.x

Een MCP server die draait op het Android apparaat en Claude Code in de terminal
toegang geeft tot Android APIs. Dit is het grote differentiator voor open source lancering.

## MCP tools (fase 1)
- get_project_context() — huidige SOUL projectstatus
- notify_user(message) — push notificatie
- request_permission(message) — native dialog
- log_decision(context) — opslaan in SOUL geheugen
- get_calendar() — beschikbaarheid vandaag

## MCP tools (fase 2)
- get_contacts(name) — contactpersonen
- track_metric(key, value) — groei bijhouden
- post_update(platform, message) — via OpenClaw
- send_email / send_whatsapp — communicatie

## Technisch
- Node.js MCP server draait in SOUL Terminal (eigen sessie)
- Claude Code verbindt via ~/.claude/mcp_config.json
- Pigeon bridge verbindt MCP server met Android APIs
- Automatisch gestart door SOUL bij eerste Claude Code sessie

## Impact
Maakt SOUL Terminal tot de krachtigste mobiele AI coding omgeving ter wereld.
Claude Code op telefoon = Claude Code op server + Android superpowers.
