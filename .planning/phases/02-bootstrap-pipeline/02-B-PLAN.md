---
phase: 2
plan: "02-B"
name: "Build Bootstrap & Apt Repository"
wave: 2
depends_on: ["02-A"]
requirements_addressed: [BOOT-02, BOOT-04]
files_modified:
  - "(soul-packages repo) apt repository assets on GitHub Releases"
  - "(soul-packages repo) .github/workflows/bootstrap-build.yml (if adjustments needed)"
autonomous: true
---

# Plan 02-B: Build Bootstrap & Apt Repository

<objective>
Trigger the bootstrap-build workflow created in Plan 02-A to produce the actual bootstrap-aarch64.zip with all packages compiled for the com.soul.terminal prefix. Verify the build succeeds, the bootstrap zip is published to GitHub Releases, and set up the apt repository structure so that `pkg install` can fetch packages. This plan produces the artifacts that Plan 02-C will integrate into the soul-terminal app.
</objective>

<task id="02-B-01" title="Trigger bootstrap build workflow and monitor">
<read_first>
- soul-packages/.github/workflows/bootstrap-build.yml (verify workflow is committed and correct)
</read_first>
<action>
Trigger the bootstrap build workflow with a version tag:

```bash
gh workflow run bootstrap-build.yml \
  --repo eatsome-webapp/soul-packages \
  -f version_tag="2026.03.19-r1+soul-terminal"
```

Monitor the workflow run:
```bash
gh run list --repo eatsome-webapp/soul-packages --workflow bootstrap-build.yml --limit 1
gh run watch --repo eatsome-webapp/soul-packages $(gh run list --repo eatsome-webapp/soul-packages --workflow bootstrap-build.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

Expected outcome: workflow completes successfully, GitHub Release `bootstrap-2026.03.19-r1+soul-terminal` is created with `bootstrap-aarch64.zip` asset.

If the workflow fails:
1. Check logs: `gh run view --repo eatsome-webapp/soul-packages --log`
2. Common failures:
   - Docker image pull timeout: re-run the workflow
   - Package build error: check which package failed, fix in fork, push, re-trigger
   - `generate-bootstraps.sh` fails: switch to manual zip assembly (update workflow)
3. Fix the issue, commit to soul-packages, and re-trigger
</action>
<acceptance_criteria>
- `gh run list --repo eatsome-webapp/soul-packages --workflow bootstrap-build.yml --limit 1 --json conclusion --jq '.[0].conclusion'` returns `"success"`
- `gh release view bootstrap-2026.03.19-r1+soul-terminal --repo eatsome-webapp/soul-packages --json assets --jq '.assets[].name'` includes `bootstrap-aarch64.zip`
</acceptance_criteria>
</task>

<task id="02-B-02" title="Verify bootstrap zip contents">
<read_first>
- soul-packages/.github/workflows/bootstrap-build.yml (to find the release tag)
</read_first>
<action>
Download the built bootstrap zip and inspect its contents:

```bash
gh release download bootstrap-2026.03.19-r1+soul-terminal \
  --repo eatsome-webapp/soul-packages \
  --pattern "bootstrap-aarch64.zip" \
  --dir /tmp/bootstrap-verify/

cd /tmp/bootstrap-verify/
unzip -l bootstrap-aarch64.zip | head -50
```

Verify:
1. `SYMLINKS.txt` exists in the zip root
2. `bin/bash` exists in the zip
3. `bin/apt` or `bin/apt-get` exists
4. `etc/apt/sources.list` exists (or `etc/apt/sources.list.d/`)
5. File count is reasonable (>500 files expected for a full bootstrap)

Check that paths do NOT contain `com.termux` (they should be relative paths, not absolute):
```bash
unzip -p bootstrap-aarch64.zip SYMLINKS.txt | grep -c "com\.termux"
```
This should return 0.

Verify SHA-256 matches the release description:
```bash
sha256sum bootstrap-aarch64.zip
```
</action>
<acceptance_criteria>
- `unzip -l bootstrap-aarch64.zip` lists `SYMLINKS.txt` in the archive
- `unzip -l bootstrap-aarch64.zip` lists `bin/bash` in the archive
- `unzip -p bootstrap-aarch64.zip SYMLINKS.txt | grep -c "com\.termux"` returns `0`
- `sha256sum bootstrap-aarch64.zip` output matches the checksum in the GitHub Release body
</acceptance_criteria>
</task>

<task id="02-B-03" title="Set up apt repository on GitHub Releases">
<read_first>
- soul-packages/scripts/generate-bootstraps.sh (understand how apt repo metadata is generated)
- soul-packages/packages/termux-tools/ (find sources.list template)
</read_first>
<action>
Create the apt repository structure for hosting packages via GitHub Releases. This enables `pkg install <package>` to work after bootstrap.

Option A (if generate-bootstraps.sh already created apt repo metadata):
The workflow may have generated `Packages`, `Packages.gz`, `Release`, and `InRelease` files. Upload these as a separate GitHub Release tagged `apt-repo`:

```bash
gh release create apt-repo \
  --repo eatsome-webapp/soul-packages \
  --title "APT Repository" \
  --notes "SOUL Terminal apt repository metadata and packages" \
  dists/stable/main/binary-aarch64/Packages \
  dists/stable/main/binary-aarch64/Packages.gz \
  dists/stable/Release \
  dists/stable/InRelease \
  debs/*.deb
```

Option B (manual apt repo generation):
If the workflow only produced .deb files, generate the repo metadata manually:

```bash
mkdir -p apt-repo/dists/stable/main/binary-aarch64
mkdir -p apt-repo/pool/main

# Copy debs
cp debs/*_aarch64.deb debs/*_all.deb apt-repo/pool/main/

# Generate Packages index
cd apt-repo
dpkg-scanpackages pool/main /dev/null > dists/stable/main/binary-aarch64/Packages
gzip -k dists/stable/main/binary-aarch64/Packages

# Generate Release
apt-ftparchive release dists/stable/ > dists/stable/Release

# Sign
gpg --batch --yes --clearsign -o dists/stable/InRelease dists/stable/Release
gpg --batch --yes --detach-sign --armor -o dists/stable/Release.gpg dists/stable/Release
```

Update the `sources.list` in `termux-tools` package to point to the correct URL:
```
deb https://github.com/eatsome-webapp/soul-packages/releases/download/apt-repo/ stable main
```

Note: If GitHub Releases URL structure doesn't match apt expectations, consider using GitHub Pages or a simple static file host instead. The key requirement is that `apt` can fetch `Packages.gz` from the configured URL.
</action>
<acceptance_criteria>
- A GitHub Release tagged `apt-repo` exists in eatsome-webapp/soul-packages (or equivalent hosting)
- `curl -sL "https://github.com/eatsome-webapp/soul-packages/releases/download/apt-repo/Packages" | head -5` returns valid Packages index content (starts with `Package:`)
- At least the bootstrap .deb packages are available as release assets
- `grep "soul-packages" packages/termux-tools/` shows the sources.list URL points to the own repo
</acceptance_criteria>
</task>

<task id="02-B-04" title="Record SHA-256 checksum for soul-terminal integration">
<read_first>
- GitHub Release body for bootstrap-2026.03.19-r1+soul-terminal (contains checksum)
</read_first>
<action>
Extract the SHA-256 checksum from the bootstrap build output and record it for Plan 02-C:

```bash
CHECKSUM=$(gh release view bootstrap-2026.03.19-r1+soul-terminal \
  --repo eatsome-webapp/soul-packages \
  --json body --jq '.body' | grep -oP 'SHA-256: \K[a-f0-9]{64}')
echo "Version: 2026.03.19-r1+soul-terminal"
echo "Checksum: $CHECKSUM"
```

Write these values to a file for reference by the next plan:

```bash
cat > /data/data/com.termux/files/home/soul-terminal/.planning/phases/02-bootstrap-pipeline/bootstrap-checksums.txt <<EOF
# Bootstrap checksums for soul-terminal integration
# Generated by Plan 02-B, task 02-B-04
VERSION=2026.03.19-r1+soul-terminal
CHECKSUM_AARCH64=<the actual 64-char hex checksum>
DOWNLOAD_URL=https://github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-2026.03.19-r1+soul-terminal/bootstrap-aarch64.zip
EOF
```
</action>
<acceptance_criteria>
- File `.planning/phases/02-bootstrap-pipeline/bootstrap-checksums.txt` exists
- File contains `VERSION=` line with valid version string
- File contains `CHECKSUM_AARCH64=` line with exactly 64 hex characters
- File contains `DOWNLOAD_URL=` line pointing to eatsome-webapp/soul-packages GitHub Release
</acceptance_criteria>
</task>

<verification>
1. Bootstrap build workflow completed successfully in GitHub Actions
2. GitHub Release `bootstrap-2026.03.19-r1+soul-terminal` exists with `bootstrap-aarch64.zip`
3. Bootstrap zip contains `SYMLINKS.txt`, `bin/bash`, and no `com.termux` references
4. Apt repository is accessible via URL (Packages index downloadable)
5. Checksum is recorded for soul-terminal app integration
</verification>

<must_haves>
- bootstrap-aarch64.zip is built with com.soul.terminal prefix and published to GitHub Releases
- SHA-256 checksum is known and recorded
- Apt repository metadata (Packages, Packages.gz, InRelease) is hosted and accessible
- sources.list in bootstrap points to own apt repository URL
- All .deb packages in the bootstrap set are available for download
</must_haves>
