---
phase: 06
slug: app-merge
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-20
---

# Phase 06 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | dart analyze + flutter test + CI build verification |
| **Config file** | flutter_module/analysis_options.yaml |
| **Quick run command** | `cd flutter_module && dart analyze lib/` |
| **Full suite command** | `cd flutter_module && flutter test && cd .. && ./gradlew assembleDebug` |
| **Estimated runtime** | ~120 seconds (dart analyze ~10s, flutter test ~30s, gradle ~80s) |

---

## Sampling Rate

- **After every task commit:** Run `cd flutter_module && dart analyze lib/`
- **After every plan wave:** Run `cd flutter_module && flutter test && cd .. && ./gradlew assembleDebug`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 06-01-01 | 01 | 1 | MERG-01 | static | `find flutter_module/lib -name "*.dart" \| wc -l` (>= 240) | N/A | ⬜ pending |
| 06-01-02 | 01 | 1 | MERG-02 | static | `cd flutter_module && flutter pub get` exits 0 | N/A | ⬜ pending |
| 06-02-01 | 02 | 1 | MERG-03 | static | `grep -c "READ_CONTACTS\|READ_CALENDAR\|ForegroundService\|NotificationListener" app/src/main/AndroidManifest.xml` >= 4 | N/A | ⬜ pending |
| 06-02-02 | 02 | 1 | MERG-04 | static | `grep "UncontrolledProviderScope" flutter_module/lib/main.dart` | N/A | ⬜ pending |
| 06-03-01 | 03 | 2 | MERG-05 | static | `grep "getApplicationDocumentsDirectory" flutter_module/lib/core/` confirms path resolution | N/A | ⬜ pending |
| 06-03-02 | 03 | 2 | MERG-06 | static | `grep "soul_foreground" flutter_module/lib/` confirms separate channel ID | N/A | ⬜ pending |
| 06-04-01 | 04 | 2 | MERG-07 | analysis | `cd flutter_module && dart analyze lib/` exits 0 | N/A | ⬜ pending |
| 06-04-02 | 04 | 2 | MERG-08 | CI | GitHub Actions debug_build.yml passes green | N/A | ⬜ pending |
| 06-04-03 | 04 | 2 | MERG-09 | static | `grep "ApiKeyService\|flutter_secure_storage" flutter_module/lib/` confirms key storage | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- Existing infrastructure covers all phase requirements (dart analyze, flutter pub get, CI build).

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| SOUL chat UI visible at app start | MERG-07 | Requires physical device/emulator | Install APK → open app → verify SOUL chat UI is main screen |
| API key survives restart | MERG-09 | Requires Android Keystore on device | Enter API key → force stop → reopen → verify key loaded |
| Both services run simultaneously | MERG-06 | Requires running services check | `adb shell dumpsys activity services \| grep -E "TermuxService\|ForegroundService"` |
| Database writes to correct path | MERG-05 | Requires device file system check | `adb shell run-as com.soul.terminal ls files/` |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
