---
phase: 09
slug: soul-terminal-awareness
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 09 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Android instrumented tests (JUnit 4 + Espresso) for Java; Flutter test for Dart |
| **Config file** | `app/build.gradle` (androidTest), `flutter_module/pubspec.yaml` (test) |
| **Quick run command** | `cd flutter_module && flutter test test/services/awareness/` |
| **Full suite command** | `cd flutter_module && flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd flutter_module && flutter test test/services/awareness/`
- **After every plan wave:** Run `cd flutter_module && flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 09-01-01 | 01 | 1 | AWAR-05 | unit | `flutter test test/services/awareness/command_whitelist_test.dart` | ❌ W0 | ⬜ pending |
| 09-01-02 | 01 | 1 | AWAR-06 | unit | `flutter test test/services/awareness/secret_filter_test.dart` | ❌ W0 | ⬜ pending |
| 09-01-03 | 01 | 1 | AWAR-07 | unit | `flutter test test/services/awareness/ansi_stripper_test.dart` | ❌ W0 | ⬜ pending |
| 09-02-01 | 02 | 2 | AWAR-01 | manual | ADB install + test command | N/A | ⬜ pending |
| 09-02-02 | 02 | 2 | AWAR-02 | manual | ADB install + observe output stream | N/A | ⬜ pending |
| 09-02-03 | 02 | 2 | AWAR-03 | manual | OSC 133 prompt detection validation | N/A | ⬜ pending |
| 09-03-01 | 03 | 3 | AWAR-04 | manual | Visual inspection of indicator card | N/A | ⬜ pending |
| 09-03-02 | 03 | 3 | AWAR-08 | manual | Tap indicator → sheet opens | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `flutter_module/test/services/awareness/command_whitelist_test.dart` — stubs for AWAR-05 destructive pattern matching
- [ ] `flutter_module/test/services/awareness/secret_filter_test.dart` — stubs for AWAR-06 API key filtering
- [ ] `flutter_module/test/services/awareness/ansi_stripper_test.dart` — stubs for AWAR-07 ANSI escape stripping

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Command sent to terminal | AWAR-01 | Requires running terminal process | ADB install APK, send `ls -la` via SOUL, verify output in terminal |
| Output stream to Flutter | AWAR-02 | Requires Pigeon bridge + running app | Execute command, verify output appears in SOUL chat context |
| OSC 133 completion | AWAR-03 | Requires shell with OSC 133 configured | Configure PROMPT_COMMAND, run command, verify completion callback |
| UI indicator | AWAR-04 | Visual verification needed | Execute command, verify indicator card appears and disappears |
| Destructive command dialog | AWAR-05 | Requires native AlertDialog interaction | Send `rm -rf ~/test`, verify dialog appears, cancel and verify no execution |
| Sheet access from indicator | AWAR-08 | Requires touch interaction | Tap indicator card, verify sheet opens to half-expanded |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
