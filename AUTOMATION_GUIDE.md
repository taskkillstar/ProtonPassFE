# ProtonPassFE: Automated Custom Build & Release Pipeline

This fork of [protonpass/android-pass](https://github.com/protonpass/android-pass) is configured to automatically:
1. **Detect Upstream Releases**: Regularly checks for new release tags published by Proton.
2. **Apply Your Custom Modifications**: Automatically applies any patches or scripts in `patches/` onto the upstream release.
3. **Build the Android APK**: Automatically builds the clean F-Droid production APK (`assembleFdroidProdRelease`) via GitHub Actions.
4. **Publish GitHub Releases**: Creates a new release under your repository (`vX.Y.Z`) with the compiled `.apk` attached.
5. **Notify You**: You receive an email via GitHub Releases / notifications, and optionally push notifications via Telegram, Discord, or Ntfy.

---

## Architecture Overview

```
Upstream (protonpass/android-pass)
          │
          │ [Git Tag Published: e.g. 1.41.5]
          ▼
GitHub Actions Cron Job / Manual Dispatch (weekly)
          │
          ├─► Compare upstream tag vs your GitHub Releases
          │   └─ Already released? ──► Stop (No duplicate builds)
          ▼
Checkout upstream tag (1.41.5)
          │
          ├─► Apply patches in patches/*.patch (via scripts/apply-modifications.sh)
          │   └─ Any conflict? ──► Fail early & alert you
          ▼
Build Android APK (assembleFdroidProdRelease)
          │   └─ Pure standalone APK (no Sentry, no Play Services requirement)
          ▼
Create GitHub Release (v1.41.5)
          │   ├─ Upload ProtonPass-1.41.5-custom.apk
          │   └─ Upload SHA256SUMS.txt
          ▼
Send Notifications
          ├─► GitHub Release watcher email
          ├─► Telegram (optional, if secrets configured)
          ├─► Discord (optional, if secret configured)
          └─► Ntfy push notification (optional, if secret configured)
```

---

## How to Add Your Custom Modifications

### Method 1: Using Patch Files (`patches/`)
1. Edit any code or resources in your local repository.
2. Create a patch file:
   ```bash
   git diff > patches/0001-my-modification.patch
   ```
3. Commit and push the patch file:
   ```bash
   git add patches/0001-my-modification.patch
   git commit -m "Add custom modification patch"
   git push origin main
   ```
4. All `.patch` and `.diff` files in `patches/` are automatically applied in alphabetical order on every release.

### Method 2: Programmatic Scripts (`scripts/custom-hooks.sh` or `.ps1`)
If your changes require dynamic modifications (e.g. search-and-replace, asset generation), create a script at:
- `scripts/custom-hooks.sh`

It will be executed automatically by `scripts/apply-modifications.sh`.

---

## How to Trigger a Build Manually

You don't have to wait for the weekly cron schedule. You can trigger a build at any time:

1. Open your repository on GitHub: [github.com/taskkillstar/ProtonPassFE](https://github.com/taskkillstar/ProtonPassFE)
2. Go to **Actions** tab.
3. Click on **Sync Upstream & Release Modified App** in the left sidebar.
4. Click **Run workflow**:
   - Leave `target_tag` empty to build the latest upstream release (e.g. `1.41.5`).
   - Or specify a specific tag (e.g. `1.41.5`).
   - Check `force_build` if you want to rebuild and overwrite an existing release with new patches.

Alternatively, using the GitHub CLI:
```bash
gh workflow run sync-and-release.yml --repo taskkillstar/ProtonPassFE -f force_build=true
```

---

## Checking Upstream Sync Locally

To check the current status of upstream tags vs your releases locally:

On Linux / macOS / Git Bash:
```bash
bash scripts/check-sync.sh
```

On Windows (PowerShell):
```powershell
.\scripts\check-sync.ps1
```

---

## Optional: Instant Notifications (Telegram, Discord, Ntfy)

If you'd like instant notifications directly on your phone or chat app when builds finish:

Go to **Settings** > **Secrets and variables** > **Actions** in your GitHub repository and add:

- **Telegram**:
  - `TELEGRAM_BOT_TOKEN`: Your Telegram Bot API token from `@BotFather`.
  - `TELEGRAM_CHAT_ID`: Your Telegram user or channel chat ID.
- **Discord**:
  - `DISCORD_WEBHOOK`: Your Discord channel webhook URL.
- **Ntfy (Free push notifications to Android/iOS)**:
  - `NTFY_TOPIC`: Your custom ntfy topic name (e.g. `taskkillstar-protonpass`).
