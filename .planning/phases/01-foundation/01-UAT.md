---
status: testing
phase: 01-foundation
source: 01-A-SUMMARY.md
started: 2026-03-19T05:30:00Z
updated: 2026-03-19T05:30:00Z
---

## Current Test

number: 1
name: CI Build slaagt
expected: |
  GitHub Actions workflow draait succesvol door. APK-artifact wordt aangemaakt
  met de naam soul-terminal_* (niet termux-app_*). Geen compile-fouten.
awaiting: user response

## Tests

### 1. CI Build slaagt
expected: GitHub Actions workflow draait succesvol door. APK-artifact wordt aangemaakt met de naam soul-terminal_* (niet termux-app_*). Geen compile-fouten.
result: [pending]

### 2. Package name: com.soul.terminal
expected: Na installatie toont `adb shell pm list packages | grep soul` het pakket com.soul.terminal. Het pakket com.termux verschijnt NIET.
result: [pending]

### 3. App-naam: SOUL Terminal
expected: In de launcher en app-info (Instellingen → Apps) staat de naam "SOUL Terminal", niet "Termux".
result: [pending]

### 4. Versie 1.0.0
expected: In app-info (Instellingen → Apps → SOUL Terminal) staat versie 1.0.0 (build 1).
result: [pending]

### 5. Foreground service start zonder crash
expected: Open de SOUL Terminal app. Er verschijnt een persistent notificatie ("SOUL Terminal service running" of vergelijkbaar). Geen crash, ook niet op Android 14.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0

## Gaps

[none yet]
