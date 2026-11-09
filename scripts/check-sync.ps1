# PowerShell helper script to check upstream tags vs our releases
Write-Host "Fetching upstream tags..." -ForegroundColor Cyan
git fetch upstream --tags --quiet 2>$null

$tags = git tag --list --sort=-version:refname
$latestUpstreamTag = ($tags | Where-Object { $_ -match '^\d+\.\d+\.\d+$' } | Select-Object -First 1)

Write-Host "Latest upstream release tag: $latestUpstreamTag" -ForegroundColor Green

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Checking GitHub Releases in taskkillstar/ProtonPassFE..." -ForegroundColor Cyan
    gh release view "v$latestUpstreamTag" --repo taskkillstar/ProtonPassFE 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Status: [UP TO DATE] Release v$latestUpstreamTag already exists." -ForegroundColor Green
    } else {
        Write-Host "Status: [NEW RELEASE AVAILABLE] v$latestUpstreamTag is not released yet!" -ForegroundColor Yellow
    }
} else {
    Write-Host "Note: gh CLI not found, cannot query GitHub Releases." -ForegroundColor DarkGray
}
