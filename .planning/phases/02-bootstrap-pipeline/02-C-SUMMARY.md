---
phase: 02-bootstrap-pipeline
plan: 02-C
subsystem: infra
tags: [gradle, bootstrap, aarch64, github-actions, adb, apt]

# Dependency graph
requires:
  - phase: 02-bootstrap-pipeline/02-B
    provides: bootstrap-aarch64.zip (SHA-256: 3b3a19d8...) op GitHub Releases, apt-repo Release index

provides:
  - app/build.gradle wijst naar eatsome-webapp/soul-packages voor bootstrap download
  - Alleen aarch64 geconfigureerd (arm/i686/x86_64 verwijderd)
  - Gradle ABI splits: alleen arm64-v8a + universal
  - debug_build.yml: vereenvoudigd (geen matrix, alleen aarch64)
  - Debug APK succesvol gebouwd via GitHub Actions (run 23289491183)
  - APK artifact: soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal.apk
affects: [02-bootstrap-pipeline/02-C-device-test, soul-terminal APK installatie, pkg install verificatie]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "aarch64-only builds: ABI splits + downloadBootstraps task + workflow matrix allemaal consistent aarch64"
    - "soul-packages bootstrap URL: github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-{version}/bootstrap-{arch}.zip"

key-files:
  created:
    - "(soul-terminal relay) .github/workflows/debug_build.yml — vereenvoudigd naar aarch64-only, geen matrix"
  modified:
    - "(soul-terminal relay) app/build.gradle — URL naar soul-packages, versie 2026.03.19-r1+soul-terminal, aarch64-only, ABI splits arm64-v8a only"

key-decisions:
  - "Relay repo (eatsome-webapp/soul-terminal, master branch) is de correcte repo voor build.gradle wijzigingen — niet de lokale soul-terminal dir die naar soul-app wijst"
  - "ABI splits verwijderd voor x86/x86_64/armeabi-v7a — NDK buildde bootstrap-arm.zip incbin die niet gedownload werd (blocking error)"
  - "Workflow matrix verwijderd (was apt-android-7 + apt-android-5) — soul-terminal gebruikt één bootstrap zonder packageVariant"
  - "abiFilters arm64-v8a toegevoegd in externalNativeBuild — beperkt NDK build tot alleen arm64-v8a"
  - "APK installatie + bootstrap test (02-C-04, 02-C-05) vereist ADB wireless debugging — niet beschikbaar in proot; UAT door user"

patterns-established:
  - "aarch64-only bootstrap: downloadBootstraps zonder packageVariant if/else, directe versie string"

requirements-completed: [BOOT-03, BOOT-05]

# Metrics
duration: 45min
completed: 2026-03-19
---

# Phase 02-C: Integrate Bootstrap into soul-terminal App Summary

**Bootstrap URL naar soul-packages omgezet, aarch64-only builds geconfigureerd in Gradle + workflow, debug APK succesvol gebouwd op GitHub Actions**

## Performance

- **Duration:** 45 min
- **Started:** 2026-03-19T09:52:00Z
- **Completed:** 2026-03-19T10:10:00Z
- **Tasks:** 3 van 5 volledig geautomatiseerd (02-C-04 en 02-C-05 vereisen ADB verbinding)
- **Files modified:** 2 (app/build.gradle, .github/workflows/debug_build.yml)

## Accomplishments

- `app/build.gradle` wijst nu naar `eatsome-webapp/soul-packages` voor bootstrap download
- Versie en checksum bijgewerkt: `2026.03.19-r1+soul-terminal` + SHA-256 `3b3a19d8...`
- Alleen aarch64 geconfigureerd — arm/i686/x86_64 volledig verwijderd uit Gradle + workflow
- Debug APK succesvol gebouwd op GitHub Actions (run 23289491183, 2m15s)
- APK artifact beschikbaar: `soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal.apk`

## Task Commits

Commits in eatsome-webapp/soul-terminal repo (master branch):

1. **Task 02-C-01: Update download URL** — `3fa9f8c` feat(02-C-01)
2. **Task 02-C-02: Update version en checksums** — `dd03454` feat(02-C-02)
3. **Task 02-C-03 auto-fix: ABI splits + workflow** — `0bbc408` fix(02-C-03)

## Files Created/Modified

In `eatsome-webapp/soul-terminal` (relay repo):
- `app/build.gradle` — URL, versie, checksum, ABI splits bijgewerkt
- `.github/workflows/debug_build.yml` — matrix verwijderd, aarch64-only validatie

## Decisions Made

- **Relay repo is de juiste locatie:** De lokale `soul-terminal` directory heeft remote `soul-app` (Flutter app); de Termux-fork code zit in `relay/soul-relay/soul-terminal` met remote `eatsome-webapp/soul-terminal`.
- **ABI splits verwijderd:** De NDK probeerde bootstrap-arm.zip te incbin'en voor armeabi-v7a split — file bestaat niet meer (aarch64-only). Oplossing: splits beperkt tot arm64-v8a.
- **Workflow matrix verwijderd:** De matrix (apt-android-7 + apt-android-5) was niet relevant meer — soul-terminal heeft één vaste bootstrap zonder packageVariant selectie.
- **APK installatie UAT:** Tasks 02-C-04 en 02-C-05 vereisen ADB wireless debugging die niet beschikbaar is in proot-sessie. User moet APK handmatig installeren en bootstrap testen.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Repo mismatch] Wijzigingen in verkeerde repo gedaan**
- **Found during:** Task 02-C-01 (URL update)
- **Issue:** Eerste poging deed wijzigingen in lokale soul-terminal dir (remote: soul-app). Dit is de Flutter app, niet de Termux fork.
- **Fix:** Wijzigingen herhaald in relay/soul-relay/soul-terminal (remote: eatsome-webapp/soul-terminal)
- **Files modified:** relay/soul-relay/soul-terminal/app/build.gradle
- **Verification:** git remote -v toont eatsome-webapp/soul-terminal.git
- **Committed in:** 3fa9f8c, dd03454

**2. [Rule 3 - Blocking] bootstrap-arm.zip incbin error**
- **Found during:** Task 02-C-03 (eerste CI build run 23289347361)
- **Issue:** `error: Could not find incbin file 'bootstrap-arm.zip'` — NDK bouwde armeabi-v7a split maar die bootstrap wordt niet langer gedownload
- **Fix:** ABI splits in build.gradle beperkt tot arm64-v8a; workflow matrix verwijderd en validatie aangepast naar universal + arm64-v8a
- **Files modified:** app/build.gradle, .github/workflows/debug_build.yml
- **Verification:** Tweede CI build (run 23289491183) slaagt in 2m15s
- **Committed in:** 0bbc408

---

**Total deviations:** 2 auto-fixed (1 repo mismatch, 1 blocking NDK error)
**Impact on plan:** Beide fixes noodzakelijk. Geen scope creep.

## Issues Encountered

- ADB wireless debugging niet beschikbaar in proot-sessie — tasks 02-C-04 en 02-C-05 kunnen niet geautomatiseerd worden. APK is gebouwd en gedownload op /tmp/apk-test/. User moet:
  1. `adb connect 127.0.0.1:<CONN_PORT>` (na wireless debugging activeren in Developer options)
  2. `adb install /tmp/apk-test/soul-terminal_*/soul-terminal_*_universal.apk`
  3. App openen, eerste bootstrap extractie afwachten
  4. `echo $PREFIX` in terminal — verwacht `/data/data/com.soul.terminal/files/usr`
  5. `pkg update && pkg install python` — verwacht download van eigen soul-packages repo

## User Setup Required

**ADB installatie en bootstrap test zijn handmatig vereist:**

1. Developer options → Wireless debugging → inschakelen
2. In Termux (buiten proot): `adb connect 127.0.0.1:<CONN_PORT>`
3. APK installeren:
   ```
   adb install /tmp/apk-test/soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal/soul-terminal_v1.0.0+0bbc408-soul-terminal-github-debug_universal.apk
   ```
4. App openen → eerste launch bootstrap extractie afwachten
5. Verificatie in terminal:
   ```
   echo $PREFIX
   # Verwacht: /data/data/com.soul.terminal/files/usr
   pkg update
   pkg install python
   ```

## Next Phase Readiness

- Bootstrap integratie in build.gradle volledig — URL, versie, checksum correct
- Debug APK gebouwd en klaar voor installatie
- ADB verificatie (02-C-04/05) door user te doen
- Na succesvolle bootstrap verificatie: Phase 02 volledig (3/3 plans)

---
*Phase: 02-bootstrap-pipeline*
*Completed: 2026-03-19*
