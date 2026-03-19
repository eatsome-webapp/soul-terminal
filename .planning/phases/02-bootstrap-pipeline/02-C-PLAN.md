---
phase: 2
plan: "02-C"
name: "Integrate Bootstrap into soul-terminal App"
wave: 3
depends_on: ["02-B"]
requirements_addressed: [BOOT-03, BOOT-05]
files_modified:
  - app/build.gradle
autonomous: true
---

# Plan 02-C: Integrate Bootstrap into soul-terminal App

<objective>
Update the soul-terminal app's build.gradle to download the custom bootstrap zip from the soul-packages GitHub Release instead of upstream Termux, with correct SHA-256 checksums. Then build a debug APK, install it on the device, and verify that bootstrap extraction works and `pkg install` fetches packages from the own apt repository.
</objective>

<task id="02-C-01" title="Update download URL in app/build.gradle">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/app/build.gradle (lines 154-219 — the downloadBootstrap function and downloadBootstraps task)
- /data/data/com.termux/files/home/soul-terminal/.planning/phases/02-bootstrap-pipeline/bootstrap-checksums.txt (version and checksum from Plan 02-B)
</read_first>
<action>
In `app/build.gradle`, modify the `downloadBootstrap` function (line 177) to change the download URL from upstream Termux to soul-packages:

Change line 177 from:
```groovy
def remoteUrl = "https://github.com/termux/termux-packages/releases/download/bootstrap-" + version + "/bootstrap-" + arch + ".zip"
```

To:
```groovy
def remoteUrl = "https://github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-" + version + "/bootstrap-" + arch + ".zip"
```

This changes the GitHub org/repo from `termux/termux-packages` to `eatsome-webapp/soul-packages`.
</action>
<acceptance_criteria>
- `grep "eatsome-webapp/soul-packages" app/build.gradle` returns at least 1 match
- `grep "termux/termux-packages" app/build.gradle` returns 0 matches (no remaining upstream references in download URL)
- The URL pattern is `https://github.com/eatsome-webapp/soul-packages/releases/download/bootstrap-{version}/bootstrap-{arch}.zip`
</acceptance_criteria>
</task>

<task id="02-C-02" title="Update version and checksums in downloadBootstraps task">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/app/build.gradle (lines 205-213 — downloadBootstraps task)
- /data/data/com.termux/files/home/soul-terminal/.planning/phases/02-bootstrap-pipeline/bootstrap-checksums.txt
</read_first>
<action>
In `app/build.gradle`, modify the `downloadBootstraps()` task (lines 205-213).

Replace the entire task body:

Old:
```groovy
task downloadBootstraps() {
    doLast {
        def version = "2024.06.17-r1+apt-android-7"
        downloadBootstrap("aarch64", "91a90661597fe14bb3c3563f5f65b243c0baaec42f2bc3d2243ff459e3942fb6", version)
        downloadBootstrap("arm",     "d54b5eb2a305d72f267f9704deaca721b2bebbd3d4cca134aec31da719707997", version)
        downloadBootstrap("i686",    "06a51ac1c679d68d52045509f1a705622c8f41748ef753660e31e3b6a846eba2", version)
        downloadBootstrap("x86_64",  "4c8e43474c8d9543e01d4cbf3c4d7f59bbe4d696c38f6dece2b6ab3ba8881f2e", version)
    }
}
```

New (use the actual checksum from bootstrap-checksums.txt — placeholder shown):
```groovy
task downloadBootstraps() {
    doLast {
        def version = "2026.03.19-r1+soul-terminal"
        downloadBootstrap("aarch64", "<ACTUAL_SHA256_FROM_CHECKSUMS_TXT>", version)
    }
}
```

Key changes:
1. Version string updated to match the soul-packages release tag
2. Only aarch64 architecture (arm, i686, x86_64 lines removed)
3. Checksum updated to match the actual built bootstrap zip

IMPORTANT: The checksum MUST be the exact 64-character hex string from bootstrap-checksums.txt. Do not use a placeholder — read the file and use the real value.
</action>
<acceptance_criteria>
- `grep "2026.03.19-r1+soul-terminal" app/build.gradle` returns a match
- `grep -c "downloadBootstrap(" app/build.gradle` returns exactly `1` (only aarch64, not arm/i686/x86_64)
- The checksum string in build.gradle is exactly 64 hex characters
- `grep "arm" app/build.gradle` does NOT match in the downloadBootstraps task (arm/i686/x86_64 removed)
</acceptance_criteria>
</task>

<task id="02-C-03" title="Build debug APK and verify bootstrap download">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/app/build.gradle (verify all changes are saved)
- /data/data/com.termux/files/home/soul-terminal/.github/workflows/debug_build.yml (CI build workflow)
</read_first>
<action>
Commit the build.gradle changes and push to trigger a CI build:

```bash
cd /data/data/com.termux/files/home/soul-terminal
git add app/build.gradle
git commit -m "feat(bootstrap): switch to soul-packages bootstrap with com.soul.terminal prefix"
git push origin main
```

Then trigger and monitor the debug build:
```bash
gh workflow run debug_build.yml
gh run watch $(gh run list --workflow debug_build.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

The critical validation is that the `downloadBootstraps` Gradle task succeeds — this proves:
1. The bootstrap zip is downloadable from the soul-packages release
2. The SHA-256 checksum matches

If the build fails at `downloadBootstraps`:
- Check if the release URL is correct (try `curl -sI` the URL)
- Check if the checksum matches
- Fix and re-push
</action>
<acceptance_criteria>
- `gh run list --workflow debug_build.yml --limit 1 --json conclusion --jq '.[0].conclusion'` returns `"success"`
- The APK artifact is downloadable: `gh run download` succeeds
</acceptance_criteria>
</task>

<task id="02-C-04" title="Install APK and test bootstrap extraction">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/.github/workflows/debug_build.yml (artifact naming pattern)
</read_first>
<action>
Download the built APK and install via ADB:

```bash
gh run download $(gh run list --workflow debug_build.yml --limit 1 --json databaseId --jq '.[0].databaseId') \
  --pattern "*universal*" --dir /tmp/apk-test/

adb install /tmp/apk-test/*/soul-terminal_*.apk
```

After installation, open the app. The bootstrap extraction runs on first launch. Monitor via logcat:

```bash
adb logcat -s TermuxInstaller:* System.out:* | head -100
```

Expected log output:
- "Installing bootstrap packages" or similar
- No "wrong checksum" or "extraction failed" errors
- Bootstrap completes and shell prompt appears

Once the shell is available, verify:
```bash
# In the SOUL Terminal app:
echo $PREFIX
# Expected: /data/data/com.soul.terminal/files/usr

which bash
# Expected: /data/data/com.soul.terminal/files/usr/bin/bash

cat /data/data/com.soul.terminal/files/usr/etc/apt/sources.list
# Expected: URL pointing to eatsome-webapp/soul-packages
```
</action>
<acceptance_criteria>
- `adb shell pm list packages | grep com.soul.terminal` shows the app is installed
- `adb logcat` shows no bootstrap extraction errors
- Terminal shell prompt appears after first launch
- `$PREFIX` resolves to `/data/data/com.soul.terminal/files/usr` inside the terminal
</acceptance_criteria>
</task>

<task id="02-C-05" title="Test pkg install from own repository">
<read_first>
- /data/data/com.termux/files/home/soul-terminal/.planning/phases/02-bootstrap-pipeline/02-RESEARCH.md (BOOT-05 test procedure)
</read_first>
<action>
In the running SOUL Terminal app, test package installation:

```bash
# Update package lists
pkg update

# Install a test package
pkg install -y python

# Verify installation
python3 --version
which python3
# Expected: /data/data/com.soul.terminal/files/usr/bin/python3

# Verify apt sees the correct repository
apt policy
# Should show the soul-packages repository URL

# Check no com.termux paths remain
apt list --installed 2>/dev/null | head -20
```

If `pkg update` fails with GPG errors:
- The termux-keyring package doesn't have the correct signing key
- Fix in soul-packages fork, rebuild bootstrap, update checksums

If `pkg update` fails with "Failed to fetch":
- The apt repository URL in sources.list is wrong or the repo isn't accessible
- Check the URL structure matches what apt expects from GitHub Releases
</action>
<acceptance_criteria>
- `pkg update` completes without errors (exit code 0)
- `pkg install python` succeeds (or any other package from the repository)
- `which python3` returns `/data/data/com.soul.terminal/files/usr/bin/python3`
- No "com.termux" paths appear in installed package paths
</acceptance_criteria>
</task>

<verification>
1. app/build.gradle points to eatsome-webapp/soul-packages for bootstrap download
2. Only aarch64 bootstrap is configured (arm/i686/x86_64 removed)
3. Debug APK builds successfully in GitHub Actions (downloadBootstraps task passes)
4. APK installs and bootstrap extracts without errors on first launch
5. Shell prompt appears with correct $PREFIX (/data/data/com.soul.terminal/files/usr)
6. `pkg install python` works — fetches from own apt repository
</verification>

<must_haves>
- app/build.gradle downloads bootstrap from eatsome-webapp/soul-packages (not termux/termux-packages)
- SHA-256 checksum in build.gradle matches the actual bootstrap-aarch64.zip
- Only aarch64 architecture configured (single downloadBootstrap call)
- Debug APK builds successfully with the new bootstrap
- Bootstrap extracts correctly on first app launch
- pkg install works against the own apt repository
</must_haves>
