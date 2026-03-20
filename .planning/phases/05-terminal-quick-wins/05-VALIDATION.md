---
phase: 05
slug: terminal-quick-wins
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-20
---

# Phase 05 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual verification + grep-based checks (no test framework — pure config changes) |
| **Config file** | none — no test framework needed |
| **Quick run command** | `grep -n "DEFAULT_TERMINAL_TRANSCRIPT_ROWS\|DEFAULT_IVALUE_EXTRA_KEYS\|COLOR_INDEX_DEFAULT" terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java` |
| **Full suite command** | `cd /data/data/com.termux/files/home/soul-terminal && grep -c "20000" terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java && grep -c "soul_accent" app/src/main/res/values/themes.xml && grep -c "0x0F0F23" terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run quick grep verification
- **After every plan wave:** Run full grep suite
- **Before `/gsd:verify-work`:** Full suite must show expected values
- **Max feedback latency:** 1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | TERM-04 | grep | `grep "20000" terminal-emulator/src/main/java/com/termux/terminal/TerminalEmulator.java` | N/A | ⬜ pending |
| 05-01-02 | 01 | 1 | TERM-05 | grep | `grep "CTRL C" termux-shared/src/main/java/com/termux/shared/termux/settings/properties/TermuxPropertyConstants.java` | N/A | ⬜ pending |
| 05-01-03 | 01 | 1 | TERM-06 | grep | `grep "0xff0F0F23\|0xffE0E0E0\|0xff6C63FF" terminal-emulator/src/main/java/com/termux/terminal/TerminalColorScheme.java` | N/A | ⬜ pending |
| 05-01-04 | 01 | 1 | TERM-07 | grep | `grep "soul_accent\|soul_bg" app/src/main/res/values/themes.xml app/src/main/res/values-night/themes.xml` | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No test framework needed — all changes are verifiable via grep on source files and CI build success.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 20k scrollback works in Claude Code session | TERM-04 | Requires running app with long output | Open app, run `seq 25000`, scroll up, verify output not truncated |
| Extra keys one-tap access | TERM-05 | Requires physical device | Open app, verify ESC/TAB/Ctrl+C buttons visible and functional |
| SOUL theme visible at startup | TERM-06 | Requires visual inspection | Open app, verify dark bg with purple cursor |
| Drawer/extra keys SOUL branding | TERM-07 | Requires visual inspection | Open drawer, verify purple accent colors |
| Settings survive app restart | TERM-04..07 | Requires app lifecycle test | Change no settings, kill app, reopen, verify defaults persist |

---

## Validation Sign-Off

- [ ] All tasks have automated grep verification
- [ ] Sampling continuity: every task has verification
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
