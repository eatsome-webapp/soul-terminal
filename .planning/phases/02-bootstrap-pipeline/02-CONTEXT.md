# Phase 2: Bootstrap Pipeline - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Alle bootstrap packages herbouwen met `com.soul.terminal` prefix en serveerbaar maken via eigen apt repository. Na deze fase installeert `pkg install` vanuit de eigen repo, zonder Termux fallback. Bootstrap laadt correct bij eerste app start.

</domain>

<decisions>
## Implementation Decisions

### Package source strategy
- Full fork van termux/termux-packages repository
- `TERMUX_APP_PACKAGE` in `scripts/properties.sh` wijzigen naar `com.soul.terminal`
- Prefix path wordt `/data/data/com.soul.terminal/files/usr` (al geconfigureerd in TermuxConstants.java)
- Alleen aarch64 architectuur bouwen (target device constraint)

### Repository hosting
- GitHub Releases als apt repository (zelfde aanpak als upstream Termux)
- Bootstrap zips als release assets uploaden
- `app/build.gradle` aanpassen: download URL wijzigen van `termux/termux-packages` naar eigen repo
- SHA-256 checksums updaten na elke bootstrap build

### Build approach
- Docker cross-compilatie in GitHub Actions (CICD-04)
- Gebruik termux-packages' bestaande `build-package.sh` infra met gewijzigde properties
- Handmatig triggerbare workflow (`workflow_dispatch`) — bootstrap rebuilds zijn zeldzaam
- aarch64-only builds (geen arm, i686, x86_64 nodig)

### Bootstrap scope
- Zelfde package set als upstream Termux bootstrap (apt, bash, command-not-found, dash, dpkg, gawk, grep, less, procps, psmisc, sed, tar, termux-exec, termux-keyring, termux-tools)
- Geen custom packages toevoegen in deze fase — dat is scope voor latere fases
- Bootstrap zip formaat ongewijzigd: `bootstrap-aarch64.zip` met `SYMLINKS.txt`

### Claude's Discretion
- Exacte GitHub Actions workflow structuur (jobs, caching, artifact handling)
- Docker image keuze voor cross-compilatie
- Hoe termux-packages fork up-to-date te houden met upstream
- CI caching strategie voor package builds

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Bootstrap mechanisme
- `app/build.gradle` lines 154-218 — Bootstrap download functie, checksums, versie, en download URL
- `app/src/main/cpp/termux-bootstrap-zip.S` — Bootstrap zip embedding als binary blob
- `app/src/main/cpp/termux-bootstrap.c` — JNI bridge voor bootstrap zip extraction
- `app/src/main/java/com/termux/app/TermuxInstaller.java` — Bootstrap extraction en installatie logica

### Package name configuratie
- `termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java` line 281 — `TERMUX_PACKAGE_NAME = "com.soul.terminal"` (al gewijzigd in Phase 1)
- `termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java` lines 223-254 — Documentatie over wat er moet wijzigen bij package name change

### Upstream referentie
- `https://github.com/termux/termux-packages` — Upstream packages repo (te forken)
- `https://github.com/termux/termux-packages/wiki/Building-packages` — Build documentatie

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `downloadBootstrap()` in `app/build.gradle` — Bestaande functie die bootstrap zips downloadt en checksum valideert. Hoeft alleen URL en checksums te wijzigen.
- `TermuxInstaller.java` — Complete bootstrap extraction logica. Hoeft niet te wijzigen, werkt al met de nieuwe prefix path.
- `termux-bootstrap-zip.S` — Assembly embedding. Hoeft niet te wijzigen, leest zip op basis van architectuur.

### Established Patterns
- Bootstrap zips worden gedownload tijdens Gradle build (niet runtime)
- Zips worden als binary blob in de native library embedded
- Bij eerste launch extract `TermuxInstaller` de zip naar `$PREFIX`
- SHA-256 checksums in `build.gradle` valideren integriteit

### Integration Points
- `app/build.gradle` `downloadBootstraps()` task — URL en checksums aanpassen
- GitHub Actions workflow — nieuwe `bootstrap-build.yml` workflow toevoegen
- Eigen fork van termux-packages — `properties.sh` aanpassen

</code_context>

<specifics>
## Specific Ideas

No specific requirements — standard bootstrap rebuild approach following upstream Termux patterns.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-bootstrap-pipeline*
*Context gathered: 2026-03-19*
