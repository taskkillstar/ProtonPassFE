# PowerShell script to test applying patches locally on Windows
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$patchesDir = Join-Path $repoRoot "patches"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Proton Pass Custom Build: Applying Modifications (Win)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (Test-Path $patchesDir) {
    $patchFiles = Get-ChildItem -Path $patchesDir -Include "*.patch", "*.diff" -File | Sort-Object Name
    if ($patchFiles.Count -eq 0) {
        Write-Host "[INFO] No .patch or .diff files found in $patchesDir." -ForegroundColor Yellow
    } else {
        Write-Host "[INFO] Found $($patchFiles.Count) patch file(s):" -ForegroundColor Green
        foreach ($patch in $patchFiles) {
            Write-Host "--> Applying $($patch.Name)..." -ForegroundColor Cyan
            git apply --check "$($patch.FullName)" 2>$null
            if ($LASTEXITCODE -eq 0) {
                git apply "$($patch.FullName)"
                Write-Host "    ✓ Successfully applied $($patch.Name)" -ForegroundColor Green
            } else {
                Write-Host "    Attempting 3-way merge for $($patch.Name)..." -ForegroundColor Yellow
                git apply --3way "$($patch.FullName)"
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    ✓ Successfully applied with 3-way merge: $($patch.Name)" -ForegroundColor Green
                } else {
                    Write-Error "[ERROR] Failed to apply patch: $($patch.Name)"
                    exit 1
                }
            }
        }
    }
}

$customHook = Join-Path $scriptDir "custom-hooks.ps1"
if (Test-Path $customHook) {
    Write-Host "--> Running custom hook: $customHook" -ForegroundColor Cyan
    & $customHook
    Write-Host "    ✓ Custom hooks completed successfully" -ForegroundColor Green
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  All modifications applied successfully!                 " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
