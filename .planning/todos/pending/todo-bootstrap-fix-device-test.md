---
id: todo-bootstrap-fix-device-test
title: Bootstrap fix testen op device — pkg install moet werken
priority: critical
area: bootstrap
---

De bootstrap rebuild (com.soul.terminal prefix) loopt nu op GitHub Actions.
Zodra die klaar is:

1. SHA-256 checksum uit de build log halen
2. `app/build.gradle` updaten: versie + checksum
3. Nieuwe APK bouwen + downloaden
4. Installeren en testen: `pkg install curl` moet werken
5. Requirements BOOT-05 markeren als done in PROJECT.md

## Status
Bootstrap build gestart: 2026-03-19, run #23314381938
Wachten op: GitHub Actions resultaat
