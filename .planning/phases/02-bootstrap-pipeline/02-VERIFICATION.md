---
phase: 02-bootstrap-pipeline
verified_by: claude-code
verified_date: 2026-03-19
verdict: PARTIAL — automated steps complete, device test pending
---

# Phase 02 Verification: Bootstrap Pipeline

**Phase goal:** Alle packages herbouwd met `com.soul.terminal` prefix en serveerbaar via eigen apt repository.
**Requirements scope:** BOOT-01, BOOT-02, BOOT-03, BOOT-04, BOOT-05, CICD-04

---

## Requirement Verification

### BOOT-01 — Fork van termux-packages met `com.soul.terminal` prefix in properties.sh
**Plan:** 02-A | **Status: PASS**

Verified via 02-A-SUMMARY.md:
- `eatsome-webapp/soul-packages` fork aangemaakt van `termux/termux-packages`
- `TERMUX_APP__PACKAGE_NAME` gewijzigd naar `"com.soul.terminal"` in `scripts/properties.sh`
- `TERMUX_REPO_APP__PACKAGE_NAME` eveneens bijgewerkt
- GPG keypair (RSA-4096) aangemaakt; `SOUL_GPG_PRIVATE_KEY` opgeslagen als GitHub Secret
- Public key toegevoegd als `packages/termux-keyring/soul-terminal-repo.gpg`
- Commit `5d40061` in soul-packages fork bevestigt alle wijzigingen

### BOOT-02 — Bootstrap packages gebouwd voor aarch64 via Docker cross-compilatie
**Plan:** 02-B | **Status: PASS (with deviation)**

Verified via 02-B-SUMMARY.md:
- Bootstrap succesvol gebouwd via GitHub Actions (CI run, 4e poging geslaagd)
- Afwijking: Docker/FUSE niet beschikbaar op GitHub Actions runners — opgelost door `generate-bootstraps.sh` direct op host te draaien (packages worden van upstream `packages-cf.termux.dev` gedownload)
- Resultaat: `bootstrap-aarch64.zip` met 196 bestanden (79 packages) — gepubliceerd als GitHub Release `bootstrap-2026.03.19-r1+soul-terminal`
- SHA-256: `3b3a19d8111fca244c6cf76376b589d7a56aa41df54de9272b7590f83538b9ce`
- Geen `com.termux` referenties aangetroffen in zip contents (0 matches)
- GPG handtekening aanwezig als `bootstrap-aarch64.zip.asc`

### BOOT-03 — Bootstrap checksums bijgewerkt in app/build.gradle
**Plan:** 02-C | **Status: PASS**

Verified via directe bestandsinspectie van `/data/data/com.termux/files/home/relay/soul-relay/soul-terminal/app/build.gradle` (regel 198, 226-231):

```groovy
def remoteUrl = "https://github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-" + version + "/bootstrap-" + arch + ".zip"
```

```groovy
task downloadBootstraps() {
    doLast {
        def version = "2026.03.19-r1+soul-terminal"
        downloadBootstrap("aarch64", "3b3a19d8111fca244c6cf76376b589d7a56aa41df54de9272b7590f83538b9ce", version)
    }
}
```

- URL wijst naar `eatsome-webapp/soul-packages` (niet meer `termux/termux-packages`)
- Versie: `2026.03.19-r1+soul-terminal`
- Checksum (64 hex chars): `3b3a19d8111fca244c6cf76376b589d7a56aa41df54de9272b7590f83538b9ce`
- Checksum komt exact overeen met `.planning/phases/02-bootstrap-pipeline/bootstrap-checksums.txt`
- Alleen aarch64 — arm/i686/x86_64 calls verwijderd

### BOOT-04 — Eigen apt repository opgezet (GitHub Releases of CDN)
**Plan:** 02-B | **Status: PASS**

Verified via 02-B-SUMMARY.md:
- GitHub Release `apt-repo` aangemaakt in `eatsome-webapp/soul-packages`
- Bevat: `Packages`, `Packages.gz`, `Release` (79 packages, gefilterd uit upstream termux-main)
- Publiek toegankelijk via:
  `https://github.com/eatsome-webapp/soul-packages/releases/download/apt-repo/Packages`
- Beperking: Packages index bevat upstream packages (geen eigen .deb builds); packages blijven van upstream komen via `apt upgrade`. Dit is conform het plan (BOOT-04 vereist de repository, niet eigen builds van alle packages).

### BOOT-05 — `pkg install` werkt correct met eigen repository
**Plan:** 02-C (tasks 02-C-04, 02-C-05) | **Status: HUMAN_NEEDED**

Tasks 02-C-04 (APK installatie) en 02-C-05 (pkg install test) vereisen ADB wireless debugging en handmatige interactie met de draaiende app. Dit kan niet geautomatiseerd worden vanuit proot.

Wat wel is geverifieerd (geautomatiseerd):
- Debug APK gebouwd via GitHub Actions (run 23289491183, 2m15s, `"success"`)
- APK artifact: `soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal.apk`
- `downloadBootstraps` Gradle task geslaagd — bootstrap-aarch64.zip gedownload en checksum geverifieerd

Wat handmatig geverifieerd moet worden:
1. `adb install soul-terminal_*_universal.apk` slaagt
2. App opent, bootstrap extraheert zonder errors
3. `echo $PREFIX` in terminal → `/data/data/com.soul.terminal/files/usr`
4. `pkg update` slaagt (geen GPG errors, geen "Failed to fetch")
5. `pkg install python` slaagt, `which python3` → `/data/data/com.soul.terminal/files/usr/bin/python3`

### CICD-04 — Bootstrap build als aparte workflow (zeldzaam, handmatig te triggeren)
**Plan:** 02-A | **Status: PASS**

Verified via 02-A-SUMMARY.md:
- `.github/workflows/bootstrap-build.yml` aangemaakt in `eatsome-webapp/soul-packages`
- Trigger: `workflow_dispatch` met `version_tag` input — handmatig te triggeren, geen automatische triggers
- Workflow succesvol uitgevoerd in 02-B (bewijs dat workflow werkend is)
- `gh workflow list --repo eatsome-webapp/soul-packages` toont "Bootstrap Build" als actieve workflow

---

## Success Criteria Check (ROADMAP)

| # | Criterium | Status |
|---|-----------|--------|
| 1 | `pkg install python` installeert vanuit eigen repository met correcte prefix | HUMAN_NEEDED |
| 2 | Bootstrap packages laden succesvol bij eerste app start (geen Termux fallback) | HUMAN_NEEDED |
| 3 | GitHub Actions workflow kan handmatig getriggerd worden om bootstrap packages te rebuilden | PASS |

---

## Must-Haves Check per Plan

### Plan 02-A must_haves
| Must-have | Status |
|-----------|--------|
| Fork repo eatsome-webapp/soul-packages bestaat en is toegankelijk | PASS |
| TERMUX_APP__PACKAGE_NAME is `"com.soul.terminal"` in scripts/properties.sh | PASS |
| Alle derived paths resolven naar /data/data/com.soul.terminal/files/usr | PASS (auto-derived) |
| GPG keypair — private key in GitHub Secrets, public key in termux-keyring package | PASS |
| bootstrap-build.yml workflow bestaat met workflow_dispatch trigger | PASS |
| Workflow bouwt aarch64-only via (aangepaste) CI cross-compilatie | PASS (via generate-bootstraps.sh) |
| Workflow publiceert bootstrap zip naar GitHub Releases met SHA-256 checksum | PASS |

### Plan 02-B must_haves
| Must-have | Status |
|-----------|--------|
| bootstrap-aarch64.zip gebouwd met com.soul.terminal prefix en gepubliceerd op GitHub Releases | PASS |
| SHA-256 checksum bekend en geregistreerd | PASS (`3b3a19d8...`, in bootstrap-checksums.txt) |
| Apt repository metadata (Packages, Packages.gz) gehost en toegankelijk | PASS |
| sources.list in bootstrap wijst naar eigen apt repository URL | PASS |
| Alle .deb packages in bootstrap set beschikbaar voor download | PASS (79 packages via apt-repo release) |

### Plan 02-C must_haves
| Must-have | Status |
|-----------|--------|
| app/build.gradle downloadt bootstrap van eatsome-webapp/soul-packages | PASS |
| SHA-256 checksum in build.gradle matcht de werkelijke bootstrap-aarch64.zip | PASS |
| Alleen aarch64 geconfigureerd (één downloadBootstrap call) | PASS |
| Debug APK bouwt succesvol met nieuwe bootstrap | PASS (run 23289491183) |
| Bootstrap extraheert correct bij eerste app launch | HUMAN_NEEDED |
| pkg install werkt tegen eigen apt repository | HUMAN_NEEDED |

---

## Deviations Summary

| Afwijking | Plan | Impact | Opgelost |
|-----------|------|--------|---------|
| Docker/FUSE niet beschikbaar op GitHub Actions | 02-B | Blocking | Ja — generate-bootstraps.sh direct op host |
| generate-bootstraps.sh profile.d mkdir bug | 02-B | Blocking | Ja — mkdir -p patch in fork |
| SYMLINKS.txt niet meer aanwezig in moderne bootstrap | 02-B | Non-blocking | Ja — verificatiestap aangepast |
| bootstrap-arm.zip incbin error (ABI splits) | 02-C | Blocking | Ja — splits beperkt tot arm64-v8a |
| Wijzigingen in verkeerde repo (soul-app vs soul-terminal relay) | 02-C | Blocking | Ja — herhaald in correcte relay repo |

---

## Phase Verdict

**PARTIAL PASS** — alle geautomatiseerde stappen zijn geslaagd. De phase kan als functioneel compleet beschouwd worden voor CI/build doeleinden. Device-side verificatie (BOOT-05 en ROADMAP criteria 1 en 2) vereist handmatige ADB test.

**Aanbeveling:** Voer device test uit zodra ADB wireless debugging beschikbaar is:
```bash
# In Termux (buiten proot):
adb install /tmp/apk-test/soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal/soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal.apk
# App openen, wachten op bootstrap extractie
# In SOUL Terminal:
echo $PREFIX   # verwacht: /data/data/com.soul.terminal/files/usr
pkg update
pkg install python
which python3  # verwacht: /data/data/com.soul.terminal/files/usr/bin/python3
```

---

## Discrepanties met REQUIREMENTS.md

REQUIREMENTS.md traceability tabel toont BOOT-01..05 en CICD-04 als "Not Started" — dit is een stale snapshot uit de initiële definitie. Op basis van de SUMMARY bestanden zijn de werkelijke statussen:

| Requirement | REQUIREMENTS.md | Werkelijk |
|-------------|-----------------|-----------|
| BOOT-01 | Not Started | Complete |
| BOOT-02 | Not Started | Complete |
| BOOT-03 | Not Started | Complete |
| BOOT-04 | Not Started | Complete |
| BOOT-05 | Not Started | Pending device test |
| CICD-04 | Not Started | Complete |

REQUIREMENTS.md moet bijgewerkt worden om de checkbox status te reflecteren.

---

*Verification created: 2026-03-19*
*Verifier: claude-code (automated code inspection + SUMMARY cross-reference)*
