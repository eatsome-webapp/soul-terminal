---
phase: 4
slug: terminal-enhancements
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Android Instrumented Tests (JUnit 4 + Espresso) + JUnit unit tests |
| **Config file** | `app/build.gradle` (testImplementation deps) |
| **Quick run command** | `./gradlew :terminal-emulator:test` |
| **Full suite command** | `./gradlew test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `./gradlew :terminal-emulator:test`
- **After every plan wave:** Run `./gradlew test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-A-01 | A | 1 | TERM-01 | unit | `./gradlew :terminal-emulator:test --tests "*KittyKeyboard*"` | ❌ W0 | ⬜ pending |
| 04-B-01 | B | 1 | TERM-02 | unit | `./gradlew :terminal-emulator:test --tests "*Osc9*"` | ❌ W0 | ⬜ pending |
| 04-C-01 | C | 2 | TERM-03 | manual | Manual test — launch app, Ctrl+Shift+P | ❌ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `terminal-emulator/src/test/java/com/termux/terminal/KittyKeyboardProtocolTest.java` — unit tests for Kitty CSI u encoding
- [ ] `terminal-emulator/src/test/java/com/termux/terminal/Osc9NotificationTest.java` — unit tests for OSC9 parsing
- [ ] JUnit 4 already in deps — no framework install needed

*Note: Command palette (TERM-03) requires instrumented/manual testing — DialogFragment cannot be unit tested without Android framework.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Kitty key events in Neovim | TERM-01 | Requires running Neovim in terminal and pressing modifier keys | 1. Install neovim 2. Open file 3. Press Ctrl+Shift+A, verify correct handling |
| OSC9 Android notification appears | TERM-02 | Requires Android notification system | 1. Run `printf '\033]9;test notification\007'` 2. Verify Android notification appears |
| Command palette opens and searches | TERM-03 | Requires full app UI | 1. Press Ctrl+Shift+P 2. Verify palette opens 3. Type to filter 4. Select item |
| Notification tap opens correct session | TERM-02 | Requires Android activity lifecycle | 1. Trigger OSC9 from session 2 2. Tap notification 3. Verify app opens on session 2 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
