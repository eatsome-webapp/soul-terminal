---
phase: 08
slug: session-management
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 08 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Android Instrumentation Tests (AndroidJUnit4) + manual APK testing |
| **Config file** | `app/build.gradle` (androidTestImplementation) |
| **Quick run command** | `grep -rn "SessionTabBar\|TabLayout\|closeSession\|switchSession" app/src/main/java/` |
| **Full suite command** | GitHub Actions CI build + manual APK install |
| **Estimated runtime** | ~5 minutes (CI build) |

---

## Sampling Rate

- **After every task commit:** Run `grep -rn "SessionTabBar\|TabLayout\|closeSession\|switchSession" app/src/main/java/`
- **After every plan wave:** GitHub Actions CI build
- **Before `/gsd:verify-work`:** Full CI build must be green + manual APK test
- **Max feedback latency:** 300 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | SESS-01 | code check | `grep -l "TabLayout" app/src/main/res/layout/activity_termux.xml` | ❌ W0 | ⬜ pending |
| 08-01-02 | 01 | 1 | SESS-02 | code check | `grep -l "proc.*cmdline\|/proc/" app/src/main/java/` | ❌ W0 | ⬜ pending |
| 08-01-03 | 01 | 1 | SESS-03 | code check | `grep -l "addNewSession\|new_session" app/src/main/java/` | ✅ | ⬜ pending |
| 08-02-01 | 02 | 1 | SESS-04 | code check | `grep -rn "renameSession\|closeSession\|context.menu\|PopupMenu" app/src/main/java/` | ❌ W0 | ⬜ pending |
| 08-02-02 | 02 | 1 | SESS-05 | code check | `grep -rn "GestureDetector\|onFling\|swipe" app/src/main/java/` | ❌ W0 | ⬜ pending |
| 08-03-01 | 03 | 2 | SESS-06 | code check | `grep -rn "closeSession\|switchSession\|renameSession" flutter_module/pigeons/terminal_bridge.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- Existing infrastructure covers build validation (GitHub Actions CI)
- No additional test framework needed — validation is via code inspection + CI build + manual APK testing

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Tab bar visible in expanded/half-expanded sheet | SESS-01 | Visual layout check | Open APK, expand sheet, verify tab bar between handle and terminal |
| Process name shows in tab | SESS-02 | Runtime process check | Open session, run `python3`, verify tab shows "python3" within 3s |
| New session via + button | SESS-03 | UI interaction | Tap + button, verify new tab appears with empty terminal |
| Long press rename/close | SESS-04 | UI interaction | Long press tab, verify context menu with rename + close options |
| Swipe between sessions | SESS-05 | Gesture interaction | Create 2+ sessions, swipe left/right on terminal area, verify session switch |
| Pigeon session control | SESS-06 | Integration test | Flutter calls createSession/closeSession via Pigeon, verify terminal responds |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 300s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
