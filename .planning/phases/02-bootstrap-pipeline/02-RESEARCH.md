# Phase 2: Bootstrap Pipeline — Research

## Executive Summary

Phase 2 bouwt alle Termux bootstrap packages opnieuw met de `com.soul.terminal` package name prefix, host ze in een eigen apt repository via GitHub Releases, en koppelt de app via `app/build.gradle` aan die eigen repository. De kritieke uitdaging is dat termux binaries het prefix pad (`/data/data/com.soul.terminal/files/usr`) hardcoded ingebakken hebben tijdens compilatie — dit kan niet omzeild worden, de packages moeten echt opnieuw gebouwd worden. De aanpak is: fork termux-packages, pas `scripts/properties.sh` aan, bouw via Docker cross-compilatie in GitHub Actions, publiceer als GitHub Release, en update de checksums in `app/build.gradle`.

---

## Domain Analysis

### How Termux Bootstrap Works

De bootstrap is een zip-archief (`bootstrap-aarch64.zip`) dat het minimale Linux rootfs bevat voor Termux. Het mechanisme werkt in drie lagen:

**1. Build time (Gradle):** `downloadBootstraps()` in `app/build.gradle` downloadt de zip van GitHub Releases, valideert de SHA-256 checksum, en slaat hem op als `app/src/main/cpp/bootstrap-aarch64.zip`. Dit gebeurt automatisch bij elke Gradle build via de `afterEvaluate` hook die `downloadBootstraps` als dependency koppelt aan elke `javaCompileProvider`.

**2. Compile time (NDK):** `termux-bootstrap-zip.S` (assembly) embed de zip als binary blob in de native library via `.incbin "bootstrap-aarch64.zip"`. De `blob` en `blob_size` symbolen worden geexporteerd. Dit wordt gecompileerd als `libermux-bootstrap.so`.

**3. Runtime (Java):** Bij eerste app launch roept `TermuxInstaller.setupBootstrapIfNeeded()` via JNI `getZip()` aan (gedefinieerd in `termux-bootstrap.c`), laadt de zip bytes in memory, en extraheert alles naar `$STAGING_PREFIX` (`/data/data/com.soul.terminal/files/usr-staging`). Speciale behandeling:
- `SYMLINKS.txt` bevat symlinks in formaat `oldpath←newpath`, worden aangemaakt via `Os.symlink()`
- Bestanden in `bin/`, `libexec/`, en APT methode dirs krijgen chmod 0700
- Na succesvolle extractie: staging dir wordt hernoemd naar `$PREFIX`
- Optioneel: `etc/termux/bootstrap/termux-bootstrap-second-stage.sh` wordt uitgevoerd

**Prefix pad:** `TERMUX_PREFIX_DIR_PATH` = `/data/data/com.soul.terminal/files/usr` (al correct ingesteld in `TermuxConstants.java` door Phase 1). Android laat alleen de eigen app data directory aanmaken — het prefix pad moet matchen met de `applicationId`.

**Huidige download URL** (moet aangepast worden):
```
https://github.com/termux/termux-packages/releases/download/bootstrap-{version}/bootstrap-{arch}.zip
```

### termux-packages Build System

**Repository:** `https://github.com/termux/termux-packages`

**Centrale configuratie:** `scripts/properties.sh` — dit bestand definieert alle paden en package name variabelen. De kritieke variabelen (modern formaat):
- `TERMUX_APP__PACKAGE_NAME` — de Android package name (was vroeger `TERMUX_APP_PACKAGE`)
- `TERMUX_APP__DATA_DIR` — `/data/data/com.soul.terminal`
- `TERMUX__ROOTFS` — `/data/data/com.soul.terminal/files`
- `TERMUX__HOME` — `/data/data/com.soul.terminal/files/home`
- `TERMUX__PREFIX` — `/data/data/com.soul.terminal/files/usr`
- `TERMUX_REPO_APP__PACKAGE_NAME` — zelfde als package name

**Opgelet:** De variabelenamen zijn recent gewijzigd (properties.sh heeft nu een uitgebreid validatiemechanisme). De oude naam `TERMUX_APP_PACKAGE` bestond in oudere versies. Het GitHub Issues voorbeeld toont dat wijzigen van `TERMUX_APP__PACKAGE_NAME` automatisch `TERMUX_APP__DATA_DIR` aanpast via afleiding in het script (regel ~330). Controleer de exacte variabelen in de actuele master branch.

**Build tool:** `build-package.sh` — bouwt individuele packages. Opties:
- `-a aarch64` — architectuur (default is al aarch64)
- `-f` — force rebuild
- `-I` — download dependencies van upstream repo in plaats van bouwen

**Build environment:** Docker container `ghcr.io/termux/package-builder` (ook beschikbaar als `termux/package-builder` op Docker Hub, ~2.4 GB). Bevat Ubuntu met alle cross-compilatie toolchains voor Android.

**Workflow:** `./scripts/run-docker.sh` start de container interactief. Inside de container: `./build-package.sh -a aarch64 bash` bouwt bash voor aarch64.

### Bootstrap Generation

Er zijn twee manieren om bootstrap zips te maken:

**Optie A: `scripts/generate-bootstraps.sh` (aanbevolen)** — Downloadt `.deb` packages van een bestaande apt repository en assembleert ze tot een bootstrap zip. Vereist een draaiende apt repo. Gebruik:
```bash
./scripts/generate-bootstraps.sh \
  --architectures aarch64 \
  --repository https://github.com/.../releases/download/apt-repo/ \
  --pm apt
```

**Optie B: `scripts/build-bootstraps.sh`** — Bouwt packages lokaal vanuit source en assembleert de zip. Dit is de "full build" aanpak. Momenteel "out of commission and pending a rewrite" (upstream status maart 2022), maar de community gebruikt `run-docker.sh` + individuele `build-package.sh` calls als alternatief.

**Bootstrap zip inhoud:**
- Alle bestanden van de bootstrap packages uitgepakt relatief aan `$PREFIX`
- `SYMLINKS.txt` in de root van de zip — bevat alle symlinks in formaat `target←linkpath`
- Zip formaat is standaard ZIP (niet tar.gz)
- Huidige grootte: ~23-25 MB per architectuur

**Minimum bootstrap packages** (zelfde als upstream Termux):
`apt`, `bash`, `command-not-found`, `dash`, `dpkg`, `gawk`, `grep`, `less`, `procps`, `psmisc`, `sed`, `tar`, `termux-exec`, `termux-keyring`, `termux-tools`

**Kritieke waarschuwing:** Packages zoals `bash`, `dash`, `dpkg`, en `apt` bevatten patches die het prefix pad controleren (`verify-prefix.patch`) als beveiligingsmechanisme. Ze weigeren te draaien als het echte prefix pad niet matcht het pad waarvoor ze gecompileerd zijn. Dit is de reden waarom upstream Termux bootstrap packages niet werken met `com.soul.terminal` — de hardcoded string is `/data/data/com.termux/files/usr`.

### Apt Repository Structure

Een Termux-compatibele apt repository heeft de volgende structuur:

```
/apt/termux-main/
├── dists/
│   └── stable/
│       ├── InRelease          (GPG-gesigneerd)
│       ├── Release
│       └── main/
│           ├── binary-aarch64/
│           │   ├── Packages
│           │   └── Packages.gz
│           └── binary-all/
│               ├── Packages
│               └── Packages.gz
└── pool/
    └── main/
        └── {package-name}_{version}_{arch}.deb
```

**`sources.list` in de bootstrap:** Het bootstrap-pakket `termux-keyring` + `apt` configureren `/data/data/com.soul.terminal/files/usr/etc/apt/sources.list`. Dit bestand bevat de URL van de eigen repository. Het wordt ingebakken in de bootstrap packages zelf.

**GitHub Releases als apt server:** Upstream Termux host packages op `packages.termux.dev`. Voor eigen gebruik kan GitHub Releases de `.deb` bestanden en de `Packages` index hosten. De URL structuur moet overeenkomen met wat `apt` verwacht. Een alternatief is `aptly` (tool) om een repository te genereren en te uploaden.

**GPG signing:** Apt repositories vereisen GPG signing voor de `InRelease` file. `termux-keyring` package bevat de public key. Voor eigen fork: eigen GPG keypair genereren, public key in `termux-keyring` package opnemen, private key als GitHub Secret bewaren.

### Changes Required for com.soul.terminal

**In de fork van termux-packages (`scripts/properties.sh`):**
```bash
# Oud (upstream):
TERMUX_APP__PACKAGE_NAME="com.termux"

# Nieuw:
TERMUX_APP__PACKAGE_NAME="com.soul.terminal"
# TERMUX_APP__DATA_DIR, TERMUX__ROOTFS, TERMUX__HOME, TERMUX__PREFIX
# worden automatisch afgeleid van TERMUX_APP__PACKAGE_NAME
```

**In `app/build.gradle` van soul-terminal:**
- Download URL aanpassen van `termux/termux-packages` naar `eatsome-webapp/soul-packages` (of vergelijkbaar)
- Versie string aanpassen
- SHA-256 checksums bijwerken na elke build

**In `TermuxConstants.java`:** Al correct (Phase 1 heeft `TERMUX_PACKAGE_NAME = "com.soul.terminal"` gezet). Alle afgeleiden (`TERMUX_FILES_DIR_PATH`, `TERMUX_PREFIX_DIR_PATH`) zijn correct.

---

## Technical Approach

### BOOT-01: Fork termux-packages met nieuwe prefix

**Stappen:**
1. Fork `termux/termux-packages` naar `eatsome-webapp/soul-packages` (of eigen GitHub account)
2. Clone de fork lokaal (in GitHub Actions, niet lokaal op telefoon)
3. Wijzig `scripts/properties.sh`: stel `TERMUX_APP__PACKAGE_NAME="com.soul.terminal"` in
4. Verifieer dat alle afgeleiden correct zijn (DATA_DIR, ROOTFS, HOME, PREFIX)
5. Commit en push de fork

**Aandachtspunten:**
- De variabelenamen in properties.sh zijn de afgelopen jaren gewijzigd. Lees de actuele versie zorgvuldig
- Sommige packages bevatten hardcoded `com.termux` strings in patches — zoek deze op met `grep -r "com\.termux" packages/` en pas ze aan
- `termux-exec` is kritiek: het intercept `execve()` calls en herconfigureert dynamische linker paden. Moet met correct prefix gebouwd worden
- `termux-keyring` moet de eigen GPG public key bevatten

**Upstream sync strategie:** Periodiek `git fetch upstream && git merge upstream/master` — bootstrap packages veranderen zelden (maandelijks of minder). Merge conflicts in `properties.sh` zijn het enige verwachte pijnpunt.

### BOOT-02: Docker cross-compilatie voor aarch64

**Aanpak in GitHub Actions:**

```yaml
- name: Build bootstrap packages
  run: |
    docker run --rm \
      -v "${{ github.workspace }}:/home/builder/termux-packages" \
      ghcr.io/termux/package-builder \
      bash -c "cd /home/builder/termux-packages && \
        ./build-package.sh -a aarch64 -I apt bash dash dpkg \
          command-not-found gawk grep less procps psmisc sed tar \
          termux-exec termux-keyring termux-tools"
```

**Docker image:** `ghcr.io/termux/package-builder` (GitHub Container Registry). Dit is de officieel ondersteunde image, ~2.4 GB. Ubuntu-based met Android NDK en cross-compilers voor alle 4 architecturen.

**Caching:** GitHub Actions cache voor de Docker image layers en de gebouwde `.deb` bestanden. De `debs/` directory in termux-packages bevat gebouwde packages — cache deze tussen runs.

**Enkel aarch64:** De `-a aarch64` flag beperkt de build. Geen arm, i686, x86_64 nodig.

**Verwachte buildtijd:** 1-3 uur voor het volledige bootstrap package set (eerste build). Gecached: veel sneller.

### BOOT-03: Bootstrap checksums bijwerken in app/build.gradle

**Huidige code** (regels 205-213 in `app/build.gradle`):
```groovy
task downloadBootstraps() {
    doLast {
        def version = "2024.06.17-r1+apt-android-7"
        downloadBootstrap("aarch64", "91a90661597fe14bb3c3563f5f65b243c0baaec42f2bc3d2243ff459e3942fb6", version)
        // arm, i686, x86_64 downloads — niet meer nodig (aarch64-only)
    }
}
```

**Aanpassingen:**
1. `version` string wijzigen naar eigen release tag formaat (bijv. `"2026.03.20-r1+soul-terminal"`)
2. Download URL in `downloadBootstrap()` functie aanpassen (regel 177):
   ```groovy
   def remoteUrl = "https://github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-" + version + "/bootstrap-" + arch + ".zip"
   ```
3. Checksums bijwerken na elke bootstrap build
4. Optioneel: arm/i686/x86_64 verwijderen (aarch64-only build)

**Checksum workflow:** Na de GitHub Actions bootstrap build: `sha256sum bootstrap-aarch64.zip` output committen naar `app/build.gradle`. Dit kan geautomatiseerd worden via een workflow die een PR opent met de nieuwe checksum.

### BOOT-04: Apt repository opzetten

**Aanpak: GitHub Releases met apt repository structuur**

De eenvoudigste aanpak voor een kleine fork is `generate-bootstraps.sh` aanroepen na het bouwen van de packages — maar dit vereist een live apt server. De kip-en-ei: je hebt een apt server nodig om de bootstrap te genereren.

**Alternatief: build-bootstraps benadering (directe zip bouw)**

In plaats van `generate-bootstraps.sh` (dat een live apt server vereist), gebruik `build-bootstraps.sh` of bouw de packages individueel en assembleer de zip handmatig:

```bash
# Na build-package.sh runs hebben we .deb bestanden in debs/
# Assembleer bootstrap zip uit de .deb bestanden:
mkdir -p bootstrap-staging
for deb in debs/apt_*.deb debs/bash_*.deb ...; do
    dpkg-deb --extract "$deb" bootstrap-staging/
done
# Genereer SYMLINKS.txt
find bootstrap-staging -type l > symlinks.txt
# Maak zip
cd bootstrap-staging && zip -r ../bootstrap-aarch64.zip .
```

**Volledige apt repository voor `pkg install`:**

Voor BOOT-05 (`pkg install python` werkt) is een volledige apt repository nodig. Gebruik `aptly` of handmatige Packages index generatie:

```bash
# Genereer Packages index
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-aarch64/Packages
gzip -k dists/stable/main/binary-aarch64/Packages
# Sign Release
apt-ftparchive release dists/stable/ > dists/stable/Release
gpg --clearsign -o dists/stable/InRelease dists/stable/Release
```

**GitHub Releases hosting:** Upload `Packages`, `Packages.gz`, `.deb` bestanden, en `InRelease` als GitHub Release assets. De URL structuur moet kloppen met wat `apt` verwacht in `sources.list`.

**`sources.list` configuratie:** Wordt ingebakken in het `termux-tools` of `apt` package van de bootstrap. De `sources.list` moet wijzen naar de eigen GitHub Releases URL.

**GPG:** Genereer eenmalig een GPG keypair, sla de private key op als GitHub Secret (`BOOTSTRAP_GPG_PRIVATE_KEY`), en include de public key in `termux-keyring`.

### BOOT-05: Verificatie dat `pkg install` werkt

**Testprocedure:**
1. Installeer de debug APK op het device via ADB
2. Open de app — bootstrap installatie start automatisch
3. Controleer logcat: `adb logcat | grep TermuxInstaller`
4. Open terminal in de app
5. Voer uit: `pkg update && pkg install python`
6. Controleer: `python3 --version`

**Indicatoren van succes:**
- `which python3` geeft `/data/data/com.soul.terminal/files/usr/bin/python3`
- `apt list --installed` toont packages zonder errors
- `pkg` commando werkt zonder "no such file" errors

**Valkuilen:**
- `termux-exec` verkeerd gebouwd: segfaults of "wrong prefix" errors bij elke shell command
- `sources.list` wijst naar verkeerde URL: `E: Failed to fetch`
- GPG key niet vertrouwd: `W: GPG error: ... NO_PUBKEY`
- Checksum mismatch in Gradle: bootstrap wordt niet gedownload, app heeft geen `$PREFIX`

### CICD-04: GitHub Actions workflow

**Workflow bestand:** `.github/workflows/bootstrap-build.yml` (in soul-terminal repo of soul-packages fork repo)

**Aanbevolen locatie:** In de `soul-packages` fork repo — bootstrap builds zijn onafhankelijk van de app.

**Workflow ontwerp:**

```yaml
name: Bootstrap Build

on:
  workflow_dispatch:
    inputs:
      version_tag:
        description: "Release tag (e.g. 2026.03.20-r1+soul-terminal)"
        required: true

jobs:
  build-packages:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4

      - name: Cache built packages
        uses: actions/cache@v4
        with:
          path: debs/
          key: bootstrap-debs-${{ hashFiles('packages/**') }}

      - name: Build bootstrap packages via Docker
        run: |
          docker run --rm \
            -v "$PWD:/home/builder/termux-packages" \
            ghcr.io/termux/package-builder \
            bash -c "cd /home/builder/termux-packages && \
              ./build-package.sh -a aarch64 -f -I \
                apt bash dash dpkg command-not-found gawk grep \
                less procps psmisc sed tar termux-exec \
                termux-keyring termux-tools"

      - name: Assemble bootstrap zip
        run: |
          ./scripts/build-bootstraps.sh --architectures aarch64
          # of handmatige zip assembly uit debs/

      - name: Compute SHA-256
        run: sha256sum bootstrap-aarch64.zip

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: bootstrap-${{ github.event.inputs.version_tag }}
          files: bootstrap-aarch64.zip
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Build apt repository
        run: |
          # Genereer Packages index, sign met GPG
          # Upload als release assets

  notify-app-repo:
    needs: build-packages
    runs-on: ubuntu-24.04
    steps:
      - name: Create PR in soul-terminal with new checksums
        # Optioneel: automatisch PR openen met nieuwe checksums
```

**Caching strategie:**
- GitHub Actions cache voor `debs/` directory (gebouwde .deb files)
- Cache key based op `hashFiles('packages/**')` — alleen invalideren als package definitie wijzigt
- Docker image wordt gecached door GitHub Actions runner (~30 min pull bespaard)

**Triggers:** Alleen `workflow_dispatch` (handmatig). Bootstrap rebuilds zijn zeldzaam — alleen nodig bij:
- Beveiligingspatches in bootstrap packages
- Nieuwe versie van apt/bash/dpkg
- Toevoegen van nieuwe packages aan de bootstrap set

---

## Risks and Mitigations

| Risico | Kans | Impact | Mitigatie |
|--------|------|--------|-----------|
| `verify-prefix` patches weigeren verkeerd prefix | Hoog | Hoog | `com.termux` strings in patches opsporen en aanpassen voor de fork |
| `build-bootstraps.sh` is "out of commission" upstream | Medium | Medium | Gebruik individuele `build-package.sh` calls + handmatige zip assembly, of `generate-bootstraps.sh` met eigen apt server |
| Docker build duurt >6 uur (GitHub Actions timeout) | Medium | Medium | Bouw packages in parallelle matrix jobs per package; cache aggressief |
| GPG signing setup complex | Medium | Laag | Genereer keypair eenmalig; documenteer proces; bewaar als GitHub Secret |
| apt repository URL structuur klopt niet | Laag | Hoog | Test met `curl` tegen GitHub Releases URL vóór integratie |
| `termux-exec` verkeerd gecompileerd | Laag | Hoog | Test elke binary met `readelf -d` om te controleren op correct RPATH |
| `sources.list` URL hardcoded in bootstrap | Medium | Medium | Controleer welk package `sources.list` bevat en zorg dat URL correct is voor eigen repo |

**Grootste risico: de `verify-prefix` patch.** Packages zoals `bash`, `dash`, `dpkg`, `coreutils` bevatten obfuscated checks op het prefix pad. Als `properties.sh` correct is ingesteld, handelt de build system dit automatisch af via `@TERMUX_PREFIX@` substituties in patches. Maar een handmatige check is verstandig.

---

## Validation Architecture

| Requirement | Validatie | Bewijs |
|-------------|-----------|--------|
| **BOOT-01** Fork met correcte prefix | `grep TERMUX_APP__PACKAGE_NAME scripts/properties.sh` in fork geeft `com.soul.terminal` | Screenshot of CI output |
| **BOOT-02** Docker cross-compilatie werkt | GitHub Actions build succesvol; `debs/bash_*_aarch64.deb` aanwezig | CI log + artifact |
| **BOOT-03** Checksums bijgewerkt | `downloadBootstraps` task slaagt zonder checksum error in Gradle build | Gradle build log |
| **BOOT-04** Apt repository bereikbaar | `curl https://github.com/.../releases/.../Packages` geeft geldige package lijst | HTTP response |
| **BOOT-05** `pkg install` werkt | Op echte device: `pkg install python && python3 --version` slaagt | Device test |
| **CICD-04** Workflow handmatig triggerbaar | `gh workflow run bootstrap-build.yml` slaagt | GitHub Actions UI |

**Integratietest sequence:**
1. Bouw bootstrap zip in CI
2. Upload naar GitHub Releases als test release
3. Update checksum in `app/build.gradle`
4. Bouw debug APK (download bootstraps task valideert checksum)
5. Installeer APK via ADB
6. Observeer logcat tijdens eerste launch
7. Test `pkg install python` in terminal

---

## RESEARCH COMPLETE
