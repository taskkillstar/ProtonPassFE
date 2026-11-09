# Custom Patches for Proton Pass

This directory holds patches that are automatically applied to the Proton Pass Android app when building custom releases.

## How it works

1. The automated GitHub Actions workflow checks for new upstream tags from `https://github.com/protonpass/android-pass.git`.
2. When a new tag is detected, it checks out that upstream release tag cleanly.
3. The workflow executes `scripts/apply-modifications.sh`, which finds all `.patch` and `.diff` files in this directory and applies them in alphabetical order.
4. The modified code is built into an APK, released on GitHub Releases, and you receive a notification with the download link.

## How to create a patch

1. Make your changes in this repository (e.g. edit source files, layout XML, drawables, gradle configs).
2. Generate a patch file:
   ```bash
   git diff > patches/0001-my-custom-feature.patch
   ```
3. Commit and push the `.patch` file to `main`:
   ```bash
   git add patches/0001-my-custom-feature.patch
   git commit -m "Add custom feature patch"
   git push origin main
   ```

## Naming convention

Prefix your patch files with numbers to guarantee their application order:
- `0001-brand-or-theme-changes.patch`
- `0002-feature-tweaks.patch`
- `0003-remove-trackers.patch`

## Testing locally

On Linux / macOS / Git Bash:
```bash
bash scripts/apply-modifications.sh
```

On Windows (PowerShell):
```powershell
.\scripts\apply-modifications.ps1
```
