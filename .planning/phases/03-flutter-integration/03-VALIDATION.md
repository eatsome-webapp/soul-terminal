---
phase: 3
slug: flutter-integration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | ADB logcat + shell commands (no unit test framework — native Android integration) |
| **Config file** | none — manual verification via ADB |
| **Quick run command** | `adb logcat -d \| grep -i "flutter\|pigeon\|soul"` |
| **Full suite command** | `adb shell am start -n com.soul.terminal/.app.TermuxActivity && adb logcat -d \| grep -iE "flutter\|pigeon\|engine"` |
| **Estimated runtime** | ~15 seconds |

---

## Sampling Rate

- **After every task commit:** Run `adb logcat -d | grep -i "flutter|pigeon|soul"` via CI APK install
- **After every plan wave:** Full build + install + logcat verification
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds (build + install + verify)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-A-01 | A | 1 | FLUT-01 | file check | `ls flutter_module/pubspec.yaml` | ❌ W0 | ⬜ pending |
| 03-B-01 | B | 1 | — | build | `./gradlew assembleDebug` | ✅ | ⬜ pending |
| 03-C-01 | C | 2 | FLUT-02 | logcat | `adb logcat \| grep FlutterEngine` | ❌ W0 | ⬜ pending |
| 03-C-02 | C | 2 | FLUT-03, FLUT-05 | manual | Toggle button test | ❌ W0 | ⬜ pending |
| 03-C-03 | C | 2 | FLUT-04 | logcat | `adb logcat \| grep "No implementation found"` (should be empty) | ❌ W0 | ⬜ pending |
| 03-D-01 | D | 3 | PIGB-01 | file check | `ls app/src/main/java/com/termux/bridge/` | ❌ W0 | ⬜ pending |
| 03-D-02 | D | 3 | PIGB-02 | manual | Execute command via Flutter UI | ❌ W0 | ⬜ pending |
| 03-D-03 | D | 3 | PIGB-03 | logcat | Debounce timing verification | ❌ W0 | ⬜ pending |
| 03-D-04 | D | 3 | PIGB-04 | manual | Bidirectional bridge test | ❌ W0 | ⬜ pending |
| 03-D-05 | D | 3 | PIGB-05 | manual | cmd-proxy replacement verification | ❌ W0 | ⬜ pending |
| 03-E-01 | E | 1 | CICD-03 | CI | `gh run list --workflow debug_build.yml` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `flutter_module/` — Flutter module directory with pubspec.yaml and lib/main.dart
- [ ] `flutter_module/pigeons/terminal_bridge.dart` — Pigeon schema definition
- [ ] `app/src/main/java/com/termux/bridge/` — Generated Pigeon Java files

*Most verification is manual via ADB — no unit test framework needed for integration-level work.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Toggle lag-free | FLUT-03, FLUT-05 | Visual performance — can't automate "no lag" check | Toggle 5x, observe transition speed |
| Terminal stays active during Flutter view | FLUT-05 | Process state requires interactive check | Run long process, toggle to Flutter, toggle back, verify process still running |
| Output debounce rate | PIGB-03 | Timing verification needs logcat analysis | Run rapid output command, count SoulBridge calls per second in logcat |
| cmd-proxy fully replaced | PIGB-05 | Functional equivalence test | Run each historical cmd-proxy command via Pigeon instead |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
