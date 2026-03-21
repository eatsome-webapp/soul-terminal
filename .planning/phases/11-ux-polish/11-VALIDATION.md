---
phase: 11
slug: ux-polish
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 11 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Android instrumented tests (Gradle) + manual device testing |
| **Config file** | app/build.gradle (androidTest configuration) |
| **Quick run command** | `grep -r "contentDescription\|EFFECT_TICK\|RenderEffect\|onFling" app/src/main/` |
| **Full suite command** | `./gradlew :app:assembleDebug` (compilation verification) |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick grep verification
- **After every plan wave:** Run `./gradlew :app:assembleDebug`
- **Before `/gsd:verify-work`:** Full build must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 11-01-01 | 01 | 1 | UXPL-01 | grep | `grep -n "path.*regex\|file.*path.*detect" app/src/main/java/com/termux/app/terminal/TermuxTerminalViewClient.java` | ❌ W0 | ⬜ pending |
| 11-02-01 | 02 | 1 | UXPL-02 | grep | `grep -n "promptDialog\|y/N\|yesno" app/src/main/java/com/termux/app/terminal/TermuxTerminalSessionActivityClient.java` | ❌ W0 | ⬜ pending |
| 11-03-01 | 03 | 1 | UXPL-03 | grep | `grep -n "velocityY\|FLING_THRESHOLD\|onFling" app/src/main/java/com/termux/app/TermuxActivity.java` | ❌ W0 | ⬜ pending |
| 11-03-02 | 03 | 1 | UXPL-04 | grep | `grep -n "RenderEffect\|createBlurEffect\|setRenderEffect" app/src/main/java/com/termux/app/TermuxActivity.java` | ❌ W0 | ⬜ pending |
| 11-03-03 | 03 | 1 | UXPL-05 | grep | `grep -n "VibrationEffect\|EFFECT_TICK\|EFFECT_CLICK" app/src/main/java/com/termux/app/TermuxActivity.java` | ❌ W0 | ⬜ pending |
| 11-04-01 | 04 | 2 | UXPL-06 | file | `test -f app/src/main/res/layout-land/activity_termux.xml` | ❌ W0 | ⬜ pending |
| 11-04-02 | 04 | 2 | UXPL-07 | grep | `grep -c "contentDescription" app/src/main/res/layout/activity_termux.xml` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- No test framework installation needed — validation is via compilation (assembleDebug) and grep
- Existing infrastructure covers compilation verification

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Long-press path shows dialog | UXPL-01 | Requires touch interaction on device | Long-press a file path in terminal output, verify dialog appears with Copy/Open |
| Y/N dialog appears for Claude prompt | UXPL-02 | Requires Claude Code running and asking y/n | Run Claude Code, trigger a y/n prompt, verify native dialog appears |
| Fling velocity expands sheet | UXPL-03 | Requires gesture on device | Swipe up fast on handle, verify sheet goes full screen |
| Blur visible behind sheet | UXPL-04 | Visual verification | Open sheet, verify SOUL chat is blurred behind it |
| Haptic pulse on sheet/tab | UXPL-05 | Tactile verification | Expand/collapse sheet, switch tab, verify vibration felt |
| Landscape side-by-side layout | UXPL-06 | Requires device rotation | Rotate device, verify 60/40 split layout |
| TalkBack navigation works | UXPL-07 | Requires TalkBack enabled | Enable TalkBack, navigate all interactive elements |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
