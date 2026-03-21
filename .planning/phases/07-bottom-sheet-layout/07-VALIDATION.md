---
phase: 07
slug: bottom-sheet-layout
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 07 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Android instrumented tests (androidTest) + local unit tests |
| **Config file** | `app/build.gradle` (testInstrumentationRunner) |
| **Quick run command** | `./gradlew :app:testDebugUnitTest` |
| **Full suite command** | `./gradlew :app:connectedDebugAndroidTest` |
| **Estimated runtime** | ~60 seconds (unit), ~180 seconds (instrumented) |

---

## Sampling Rate

- **After every task commit:** CI debug build (`./gradlew assembleDebug`) — compilation is the primary gate
- **After every plan wave:** Install APK on device, manual verification of sheet states
- **Before `/gsd:verify-work`:** Full manual test of all 6 LAYT requirements
- **Max feedback latency:** 120 seconds (CI build time)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 07-01-01 | 01 | 1 | LAYT-01 | manual | CI build green | N/A | ⬜ pending |
| 07-01-02 | 01 | 1 | LAYT-02 | manual | CI build green | N/A | ⬜ pending |
| 07-01-03 | 01 | 1 | LAYT-03 | manual | CI build green | N/A | ⬜ pending |
| 07-02-01 | 02 | 1 | LAYT-04 | manual | CI build green | N/A | ⬜ pending |
| 07-02-02 | 02 | 1 | LAYT-05 | manual | CI build green | N/A | ⬜ pending |
| 07-03-01 | 03 | 2 | LAYT-06 | manual | CI build green + device test | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers compilation validation. Phase 7 is primarily an Android layout/view refactor — automated UI testing requires instrumented tests with Espresso which is out of scope for this phase. CI build success is the primary automated gate.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| SOUL chat visible as main screen at app start | LAYT-01 | Visual state requires device | Install APK, open app, verify SOUL chat is fullscreen with only handle bar visible |
| Handle bar drag to half-expanded | LAYT-02 | Touch gesture requires device | Drag handle bar upward, verify terminal slides to ~40% screen height |
| 4 sheet states work correctly | LAYT-03 | Multi-state gesture testing | Test hidden→collapsed→half→expanded transitions, verify each state dimensions |
| Keyboard doesn't overlap terminal | LAYT-04 | IME behavior requires device | Open keyboard in expanded/half-expanded sheet, verify no UI overlap |
| Back button closes sheet to peek | LAYT-05 | Hardware button requires device | In expanded sheet, press back, verify sheet goes to collapsed/peek |
| Terminal process survives sheet cycles | LAYT-06 | Process state requires device | Run `sleep 999` in terminal, cycle sheet states, verify process still running |

---

## Validation Sign-Off

- [ ] All tasks have CI build as automated verify gate
- [ ] Manual test checklist covers all 6 LAYT requirements
- [ ] CI build validates compilation after each plan wave
- [ ] Device APK install validates visual behavior
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
