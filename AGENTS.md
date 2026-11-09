# AGENTS.md

Instructions for agents operating in `ProtonPassFE`.

## Mission

Maintain an automated fork of [protonpass/android-pass](https://github.com/protonpass/android-pass) that tracks upstream release tags, applies custom modifications via patches/hooks, compiles the standalone F-Droid APK, and publishes GitHub releases under `taskkillstar/ProtonPassFE`.

## Context Pointers

- **Pipeline & Secrets Architecture**: [`AUTOMATION_GUIDE.md`](AUTOMATION_GUIDE.md) — triggers, cron, release artifacts, notification hooks.
- **Patch Conventions**: [`patches/README.md`](patches/README.md) — patch sequencing, naming, and git diff boundaries.
- **CI Workflow**: [`.github/workflows/sync-and-release.yml`](.github/workflows/sync-and-release.yml) — runner swap allocation, daemon flags, artifact signing.

---

## Modifying the App

All modifications must survive upstream tag rebases. Treat `main` as the source of truth for automation, patch files, and scripts; never commit ad-hoc source modifications directly into `main` without an accompanying patch file.

### Step 1: Develop and Verify Changes
1. Apply changes directly in the local worktree against the target version code.
2. Verify local compilation or dry-run formatting.

### Step 2: Extract Atomic Patch
1. Isolate the diff to modified files only.
2. Save into `patches/` following numeric ordering:
   ```bash
   git diff -- <paths> > patches/000X-<description>.patch
   ```
   *Completion criterion*: `git status` shows clean tracked files with only the new `.patch` file untracked.

### Step 3: Dry-Run Application
1. Revert worktree edits to base state: `git checkout -- .`
2. Test patch application:
   - Windows: `.\scripts\apply-modifications.ps1`
   - Linux/macOS: `bash scripts/apply-modifications.sh`
   *Completion criterion*: Script outputs `All modifications applied successfully!` with exit code 0.

### Step 4: Commit and Push
1. Commit the patch file to `main`:
   ```bash
   git add patches/000X-<description>.patch
   git commit -m "feat(patch): add <description>"
   git push origin main
   ```

---

## Sync & Release Operations

### Inspect Upstream Status
Check if upstream published a tag not yet released on `taskkillstar/ProtonPassFE`:
- Windows: `.\scripts\check-sync.ps1`
- Linux/macOS: `bash scripts/check-sync.sh`

### Trigger Build Pipeline
Trigger GitHub Actions to checkout upstream, apply patches, compile, and release:
```bash
gh workflow run sync-and-release.yml --repo taskkillstar/ProtonPassFE -f force_build=true
```
Track run progress:
```bash
gh run list --repo taskkillstar/ProtonPassFE --limit 3
gh run watch <run-id> --repo taskkillstar/ProtonPassFE
```
*Completion criterion*: Release exists on `taskkillstar/ProtonPassFE` with attached `ProtonPass-<tag>-custom.apk` and matching `SHA256SUMS.txt`.

---

## Invariant Rules & Environment Gotchas

1. **Flavor Target**: Build variant is exclusively `:app:assembleFdroidProdRelease`. It excludes proprietary Google Play billing and Sentry crash telemetry.
2. **Flags**: Always build with `-PdisableSentryUpload=true -PapkBuild=true --no-daemon --no-configuration-cache`.
3. **R8 Memory Bound**: R8 fullMode triggers OOM on GitHub standard runners. Keep `android.enableR8.fullMode=false` and assign `>=6GB` heap with G1GC (`-Xms1g -Xmx6g -XX:+UseG1GC -XX:MaxMetaspaceSize=1g`).
4. **Target Remote**: GitHub CLI actions must explicitly specify `--repo taskkillstar/ProtonPassFE` to prevent defaulting to upstream `protonpass/android-pass`.
