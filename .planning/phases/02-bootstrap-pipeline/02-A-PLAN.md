---
phase: 2
plan: "02-A"
name: "Fork termux-packages & Bootstrap CI Workflow"
wave: 1
depends_on: []
requirements_addressed: [BOOT-01, CICD-04]
files_modified:
  - "(new repo) eatsome-webapp/soul-packages: scripts/properties.sh"
  - "(new repo) eatsome-webapp/soul-packages: .github/workflows/bootstrap-build.yml"
  - "(new repo) eatsome-webapp/soul-packages: packages/termux-keyring/build.sh"
autonomous: true
---

# Plan 02-A: Fork termux-packages & Bootstrap CI Workflow

<objective>
Create a fork of termux/termux-packages as eatsome-webapp/soul-packages, change TERMUX_APP__PACKAGE_NAME to "com.soul.terminal" in scripts/properties.sh, set up a GPG keypair for apt signing, and create a GitHub Actions workflow (workflow_dispatch) that builds bootstrap packages for aarch64 via Docker cross-compilation. This plan creates the entire build infrastructure needed by subsequent plans.
</objective>

<task id="02-A-01" title="Fork termux-packages to eatsome-webapp/soul-packages">
<read_first>
- https://github.com/termux/termux-packages (upstream repo structure — use `gh repo view`)
</read_first>
<action>
Fork `termux/termux-packages` to `eatsome-webapp/soul-packages` using the GitHub CLI:

```bash
gh repo fork termux/termux-packages --org eatsome-webapp --fork-name soul-packages --clone=false
```

Then clone it shallowly for editing:
```bash
gh repo clone eatsome-webapp/soul-packages -- --depth 1
```

Configure the upstream remote for future syncing:
```bash
cd soul-packages
git remote add upstream https://github.com/termux/termux-packages.git
```
</action>
<acceptance_criteria>
- `gh repo view eatsome-webapp/soul-packages --json name` returns `{"name":"soul-packages"}`
- The repo contains `scripts/properties.sh` (verify with `ls scripts/properties.sh`)
- `git remote -v` shows both `origin` (eatsome-webapp/soul-packages) and `upstream` (termux/termux-packages)
</acceptance_criteria>
</task>

<task id="02-A-02" title="Change TERMUX_APP__PACKAGE_NAME in properties.sh">
<read_first>
- soul-packages/scripts/properties.sh (read FULL file to understand current variable names and derivation logic)
- /data/data/com.termux/files/home/soul-terminal/termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java (lines 220-290 for reference on what TERMUX_PACKAGE_NAME is set to)
</read_first>
<action>
In `scripts/properties.sh`, find the line that sets `TERMUX_APP__PACKAGE_NAME` (or the equivalent variable — name may vary by version). Change it from:

```bash
TERMUX_APP__PACKAGE_NAME="com.termux"
```

to:

```bash
TERMUX_APP__PACKAGE_NAME="com.soul.terminal"
```

The derived variables (`TERMUX_APP__DATA_DIR`, `TERMUX__ROOTFS`, `TERMUX__HOME`, `TERMUX__PREFIX`) should auto-derive from this change. Verify by reading the derivation logic in properties.sh.

Also search for any other occurrences of `com.termux` that need changing:
- Check `TERMUX_REPO_APP__PACKAGE_NAME` — set to `com.soul.terminal` if present
- Run `grep -rn "com\.termux" scripts/` to find other references (excluding comments)

Do NOT change Java package paths (those are source code paths, not Android package names).
</action>
<acceptance_criteria>
- `grep 'TERMUX_APP__PACKAGE_NAME=' scripts/properties.sh` contains `"com.soul.terminal"`
- `grep -c 'com\.termux' scripts/properties.sh` returns 0 (no remaining com.termux references for package name — Java import paths excluded)
- Derived paths resolve to `/data/data/com.soul.terminal/files/usr` (verify by reading the derivation block)
</acceptance_criteria>
</task>

<task id="02-A-03" title="Scan and fix hardcoded com.termux in bootstrap package patches">
<read_first>
- soul-packages/packages/bash/ (any .patch files)
- soul-packages/packages/dpkg/ (any .patch files)
- soul-packages/packages/apt/ (any .patch files and build.sh)
- soul-packages/packages/termux-exec/build.sh
- soul-packages/packages/termux-tools/build.sh
</read_first>
<action>
Search for hardcoded `com.termux` strings in the bootstrap package definitions that would need updating:

```bash
grep -rn "com\.termux" packages/apt/ packages/bash/ packages/dash/ packages/dpkg/ \
  packages/command-not-found/ packages/gawk/ packages/grep/ packages/less/ \
  packages/procps/ packages/psmisc/ packages/sed/ packages/tar/ \
  packages/termux-exec/ packages/termux-keyring/ packages/termux-tools/
```

For each match found:
- If it's a hardcoded package name reference (e.g., in `build.sh`, `.patch`, or `.subpackage.sh` files), replace `com.termux` with `com.soul.terminal`
- If it's a Java import path or source code reference, leave it unchanged
- Pay special attention to `termux-tools` (contains `sources.list` template) and `termux-exec` (prefix verification)

Document each changed file. The build system handles most substitutions via `@TERMUX_PREFIX@` macros, but some files may have literal strings.
</action>
<acceptance_criteria>
- `grep -rn "com\.termux" packages/termux-tools/` returns no matches for package name references (Java paths excluded)
- `grep -rn "com\.termux" packages/termux-exec/` returns no matches for package name references
- All `.patch` files in bootstrap packages have been reviewed (logged which were changed vs unchanged)
</acceptance_criteria>
</task>

<task id="02-A-04" title="Generate GPG keypair and configure termux-keyring">
<read_first>
- soul-packages/packages/termux-keyring/build.sh
- soul-packages/packages/termux-keyring/ (all files — understand how public keys are packaged)
</read_first>
<action>
Generate a GPG keypair for SOUL Terminal apt repository signing:

```bash
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: SOUL Terminal
Name-Email: soul-terminal@eatsome-webapp.github.io
Expire-Date: 0
EOF
```

Export the keys:
- Private key: `gpg --armor --export-secret-keys soul-terminal@eatsome-webapp.github.io > soul-terminal-signing.key`
- Public key: `gpg --armor --export soul-terminal@eatsome-webapp.github.io > soul-terminal-repo.gpg`

Store the private key as GitHub Secret in soul-packages repo:
```bash
gh secret set SOUL_GPG_PRIVATE_KEY --repo eatsome-webapp/soul-packages < soul-terminal-signing.key
```

Place the public key in the termux-keyring package (replace or add alongside existing Termux keys):
- Add `soul-terminal-repo.gpg` to `packages/termux-keyring/` directory
- Update `packages/termux-keyring/build.sh` to install this key to `$TERMUX_PREFIX/share/termux-keyring/` and add it to the apt trusted keyring

Delete the local private key file after uploading to GitHub Secrets.
</action>
<acceptance_criteria>
- `gh secret list --repo eatsome-webapp/soul-packages` includes `SOUL_GPG_PRIVATE_KEY`
- File `packages/termux-keyring/soul-terminal-repo.gpg` exists in the repo
- `grep "soul-terminal" packages/termux-keyring/build.sh` returns at least one match showing the key is installed
</acceptance_criteria>
</task>

<task id="02-A-05" title="Create bootstrap-build.yml GitHub Actions workflow">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/.github/workflows/debug_build.yml (existing workflow pattern reference)
- soul-packages/scripts/properties.sh (verify variable names)
- soul-packages/scripts/build-bootstraps.sh (understand bootstrap assembly options)
- soul-packages/scripts/generate-bootstraps.sh (alternative bootstrap generation)
</read_first>
<action>
Create `.github/workflows/bootstrap-build.yml` in the soul-packages repo with `workflow_dispatch` trigger:

```yaml
name: Bootstrap Build

on:
  workflow_dispatch:
    inputs:
      version_tag:
        description: "Release version tag (e.g., 2026.03.20-r1+soul-terminal)"
        required: true
        type: string

jobs:
  build-bootstrap:
    runs-on: ubuntu-24.04
    timeout-minutes: 360

    steps:
      - name: Clone repository
        uses: actions/checkout@v4

      - name: Cache built packages
        uses: actions/cache@v4
        with:
          path: |
            debs/
            output/
          key: bootstrap-debs-${{ hashFiles('packages/**') }}
          restore-keys: |
            bootstrap-debs-

      - name: Build bootstrap packages via Docker
        run: |
          docker run --rm \
            -v "$PWD:/home/builder/termux-packages" \
            -w /home/builder/termux-packages \
            ghcr.io/termux/package-builder \
            bash -c "./build-package.sh -a aarch64 -I \
              apt bash command-not-found dash dpkg gawk grep \
              less procps psmisc sed tar \
              termux-exec termux-keyring termux-tools"

      - name: Assemble bootstrap zip
        run: |
          docker run --rm \
            -v "$PWD:/home/builder/termux-packages" \
            -w /home/builder/termux-packages \
            ghcr.io/termux/package-builder \
            bash -c "./scripts/generate-bootstraps.sh --architectures aarch64"

      - name: Compute SHA-256
        id: checksum
        run: |
          CHECKSUM=$(sha256sum bootstrap-aarch64.zip | cut -d' ' -f1)
          echo "sha256=$CHECKSUM" >> "$GITHUB_OUTPUT"
          echo "Bootstrap aarch64 SHA-256: $CHECKSUM"

      - name: Import GPG key
        env:
          GPG_PRIVATE_KEY: ${{ secrets.SOUL_GPG_PRIVATE_KEY }}
        run: |
          echo "$GPG_PRIVATE_KEY" | gpg --batch --import

      - name: Sign bootstrap zip
        run: |
          gpg --batch --yes --detach-sign --armor bootstrap-aarch64.zip

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: "bootstrap-${{ github.event.inputs.version_tag }}"
          name: "Bootstrap ${{ github.event.inputs.version_tag }}"
          body: |
            Bootstrap packages for SOUL Terminal (com.soul.terminal)
            Architecture: aarch64
            SHA-256: ${{ steps.checksum.outputs.sha256 }}
          files: |
            bootstrap-aarch64.zip
            bootstrap-aarch64.zip.asc
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Output checksum for app integration
        run: |
          echo "============================================"
          echo "UPDATE app/build.gradle in soul-terminal with:"
          echo "  version: \"${{ github.event.inputs.version_tag }}\""
          echo "  checksum: \"${{ steps.checksum.outputs.sha256 }}\""
          echo "============================================"
```

Key design decisions:
- `timeout-minutes: 360` (6 hours) for first-time full builds
- `-I` flag on build-package.sh to download dependencies from upstream instead of building them
- Cache `debs/` directory between runs
- GPG signing of the bootstrap zip
- SHA-256 checksum output for copy-paste into soul-terminal's build.gradle
</action>
<acceptance_criteria>
- File `.github/workflows/bootstrap-build.yml` exists in soul-packages repo
- `grep "workflow_dispatch" .github/workflows/bootstrap-build.yml` returns a match
- `grep "ghcr.io/termux/package-builder" .github/workflows/bootstrap-build.yml` returns a match
- `grep "bootstrap-aarch64.zip" .github/workflows/bootstrap-build.yml` returns at least 2 matches
- `grep "SOUL_GPG_PRIVATE_KEY" .github/workflows/bootstrap-build.yml` returns a match
- `grep "softprops/action-gh-release" .github/workflows/bootstrap-build.yml` returns a match
- Workflow contains `version_tag` input parameter
</acceptance_criteria>
</task>

<task id="02-A-06" title="Commit and push fork changes">
<read_first>
- soul-packages/scripts/properties.sh (verify all changes are correct)
- soul-packages/.github/workflows/bootstrap-build.yml (verify workflow file)
</read_first>
<action>
Stage all modified files in the soul-packages fork:
- `scripts/properties.sh`
- `packages/termux-keyring/` changes
- Any modified `.patch` or `build.sh` files from task 02-A-03
- `.github/workflows/bootstrap-build.yml`

Commit with message: "feat: rebrand to com.soul.terminal with bootstrap CI workflow"

Push to `eatsome-webapp/soul-packages` main branch.

Verify the workflow is visible:
```bash
gh workflow list --repo eatsome-webapp/soul-packages
```
</action>
<acceptance_criteria>
- `gh workflow list --repo eatsome-webapp/soul-packages` includes "Bootstrap Build"
- `gh api repos/eatsome-webapp/soul-packages/contents/scripts/properties.sh --jq .name` returns `properties.sh`
- The remote branch is ahead of upstream by at least 1 commit
</acceptance_criteria>
</task>

<verification>
1. `gh repo view eatsome-webapp/soul-packages` succeeds — fork exists
2. `grep "com.soul.terminal" scripts/properties.sh` in the fork — prefix is correct
3. `gh workflow list --repo eatsome-webapp/soul-packages` shows "Bootstrap Build"
4. `gh secret list --repo eatsome-webapp/soul-packages` shows `SOUL_GPG_PRIVATE_KEY`
5. No remaining `com.termux` package name references in bootstrap package definitions (Java paths excluded)
</verification>

<must_haves>
- Fork repo eatsome-webapp/soul-packages exists and is accessible
- TERMUX_APP__PACKAGE_NAME is set to "com.soul.terminal" in scripts/properties.sh
- All derived paths resolve to /data/data/com.soul.terminal/files/usr
- GPG keypair exists — private key in GitHub Secrets, public key in termux-keyring package
- bootstrap-build.yml workflow exists with workflow_dispatch trigger
- Workflow builds aarch64-only via Docker cross-compilation
- Workflow publishes bootstrap zip to GitHub Releases with SHA-256 checksum
</must_haves>
