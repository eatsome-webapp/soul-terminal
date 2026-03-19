---
phase: 02-bootstrap-pipeline
plan: 02-A
subsystem: infra
tags: [gpg, github-actions, termux-packages, bootstrap, docker, apt]

# Dependency graph
requires:
  - phase: 01-rebranding
    provides: com.soul.terminal application ID and Android project structure
provides:
  - eatsome-webapp/soul-packages fork of termux/termux-packages with com.soul.terminal package name
  - GPG keypair — private key in GitHub Secrets, public key in termux-keyring package
  - .github/workflows/bootstrap-build.yml — workflow_dispatch triggered aarch64 bootstrap CI pipeline
  - Bootstrap build infrastructure for subsequent plans
affects: [02-bootstrap-pipeline, 03-release-pipeline, soul-app bootstrap integration]

# Tech tracking
tech-stack:
  added: [gnupg, termux-packages fork, GitHub Actions Docker cross-compilation, softprops/action-gh-release]
  patterns: [GPG-signed bootstrap release artifacts, Docker-based cross-compilation via ghcr.io/termux/package-builder]

key-files:
  created:
    - "(eatsome-webapp/soul-packages) .github/workflows/bootstrap-build.yml"
    - "(eatsome-webapp/soul-packages) packages/termux-keyring/soul-terminal-repo.gpg"
  modified:
    - "(eatsome-webapp/soul-packages) scripts/properties.sh"
    - "(eatsome-webapp/soul-packages) packages/termux-keyring/build.sh"

key-decisions:
  - "eatsome-webapp is a user account, not an org — gh repo fork --org flag not supported, forked directly to eatsome-webapp"
  - "TERMUX_APP__NAMESPACE left as com.termux — Java namespace, per plan instructions (do not change Java paths)"
  - "CGCT_DEFAULT_PREFIX and CGCT_DIR left as com.termux — unrelated to bootstrap package name"
  - "TERMUX_REPO_APP derived paths updated explicitly (not auto-derived) since they are hardcoded constants"
  - "gnupg installed via pkg since not available in Termux by default"
  - "dpkg/gawk patch com.termux references are comment-only (examples/error messages), not package name references — left unchanged"

patterns-established:
  - "Bootstrap signing: GPG private key stored as SOUL_GPG_PRIVATE_KEY GitHub Secret, public key shipped in termux-keyring package"
  - "Bootstrap CI: workflow_dispatch only, 6-hour timeout, -I flag to download deps from upstream instead of building"

requirements-completed: [BOOT-01, CICD-04]

# Metrics
duration: 13min
completed: 2026-03-19
---

# Phase 02 Plan A: Fork termux-packages & Bootstrap CI Workflow Summary

**Forked termux/termux-packages as eatsome-webapp/soul-packages, rebranded to com.soul.terminal, generated RSA-4096 GPG keypair for apt signing, and created bootstrap-build.yml workflow with Docker cross-compilation and GitHub Releases publishing**

## Performance

- **Duration:** 13 min
- **Started:** 2026-03-19T09:19:11Z
- **Completed:** 2026-03-19T09:24:08Z
- **Tasks:** 6
- **Files modified:** 4 (in soul-packages fork)

## Accomplishments
- Fork `eatsome-webapp/soul-packages` created from `termux/termux-packages` with upstream remote configured
- `TERMUX_APP__PACKAGE_NAME` changed to `com.soul.terminal` — all derived paths (data dir, rootfs, home, prefix) auto-update
- RSA-4096 GPG keypair generated — private key stored as `SOUL_GPG_PRIVATE_KEY` GitHub Secret, public key added to termux-keyring package
- `bootstrap-build.yml` workflow created: builds aarch64 bootstrap via Docker, signs with GPG, publishes to GitHub Releases with SHA-256 checksum

## Task Commits

All tasks committed together in soul-packages fork:

1. **Tasks 02-A-01 through 02-A-06** — `5d40061` (feat: rebrand to com.soul.terminal with bootstrap CI workflow)

## Files Created/Modified

In `eatsome-webapp/soul-packages`:
- `scripts/properties.sh` — `TERMUX_APP__PACKAGE_NAME` and `TERMUX_REPO_APP__PACKAGE_NAME` changed to `com.soul.terminal`
- `packages/termux-keyring/soul-terminal-repo.gpg` — SOUL Terminal RSA-4096 public signing key
- `packages/termux-keyring/build.sh` — Added install step for soul-terminal-repo.gpg
- `.github/workflows/bootstrap-build.yml` — Bootstrap CI workflow with workflow_dispatch trigger

## Decisions Made
- `eatsome-webapp` is a user account (not org) — `gh repo fork --org` fails; forked directly to eatsome-webapp account. This matches the plan's intent (repo is at eatsome-webapp/soul-packages).
- `TERMUX_APP__NAMESPACE` left as `com.termux` — this is the Java namespace per plan's "Do NOT change Java package paths" instruction.
- `TERMUX_REPO_APP__DATA_DIR` and sibling vars updated explicitly since they are hardcoded (not auto-derived from `TERMUX_APP__PACKAGE_NAME`).
- dpkg/gawk patch file `com.termux` occurrences are comment-only (explaining error scenarios), not functional package name references — left unchanged.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] gnupg not installed in Termux**
- **Found during:** Task 02-A-04 (Generate GPG keypair)
- **Issue:** `gpg: command not found` — gnupg not installed in Termux by default
- **Fix:** `pkg install gnupg -y`
- **Files modified:** None (system package install)
- **Verification:** GPG key generation succeeded, both keys exported successfully
- **Committed in:** Part of task commit (no file change)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Necessary dependency install, no scope changes.

## Issues Encountered
None

## User Setup Required
None - all secrets automated via `gh secret set`.

## Next Phase Readiness
- Bootstrap build infrastructure complete
- `eatsome-webapp/soul-packages` fork is ready — Bootstrap Build workflow visible and active
- `SOUL_GPG_PRIVATE_KEY` secret is set in soul-packages repo
- Ready for plan 02-B (APT repository setup) and 02-C (first bootstrap build run)

---
*Phase: 02-bootstrap-pipeline*
*Completed: 2026-03-19*
