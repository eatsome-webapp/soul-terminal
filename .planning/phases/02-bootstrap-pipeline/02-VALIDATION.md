---
phase: 2
slug: bootstrap-pipeline
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Shell scripts + GitHub Actions |
| **Config file** | none — bootstrap validation is manual/CI-based |
| **Quick run command** | `grep -q "com.soul.terminal" termux-packages/scripts/properties.sh` |
| **Full suite command** | `gh workflow run bootstrap-build.yml && gh run watch` |
| **Estimated runtime** | ~30-60 minutes (Docker cross-compilation) |

---

## Sampling Rate

- **After every task commit:** Run quick validation (file checks, grep patterns)
- **After every plan wave:** Run full CI workflow if applicable
- **Before `/gsd:verify-work`:** Full bootstrap build + APK install test
- **Max feedback latency:** 60 seconds for local checks, 60 minutes for CI builds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-A-01 | A | 1 | BOOT-01 | file check | `grep "com.soul.terminal" scripts/properties.sh` | ❌ W0 | ⬜ pending |
| 02-B-01 | B | 1 | BOOT-02 | CI build | `gh workflow run bootstrap-build.yml` | ❌ W0 | ⬜ pending |
| 02-C-01 | C | 2 | BOOT-03 | file check | `grep -c "sha256" app/build.gradle` | ✅ | ⬜ pending |
| 02-D-01 | D | 2 | BOOT-04 | manual | Verify apt repo accessible via URL | ❌ W0 | ⬜ pending |
| 02-E-01 | E | 3 | BOOT-05 | manual | `pkg install python` on device | ❌ | ⬜ pending |
| 02-F-01 | F | 1 | CICD-04 | CI check | `gh workflow view bootstrap-build.yml` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Fork termux-packages repo with modified properties.sh
- [ ] `.github/workflows/bootstrap-build.yml` — CI workflow for building bootstrap
- [ ] GPG key generation for apt repository signing

*Bootstrap phase is infrastructure — most validation is CI-based and manual device testing.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Bootstrap extraction on first launch | BOOT-02 | Requires fresh app install on device | Install APK, verify no Termux fallback errors |
| `pkg install` from own repo | BOOT-05 | Requires running app with working bootstrap | Run `pkg install python` in SOUL Terminal |
| APK builds with new bootstrap | BOOT-03 | Requires CI pipeline | Push commit, verify GH Actions succeeds |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s for local checks
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
