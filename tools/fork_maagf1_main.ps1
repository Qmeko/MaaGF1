#Requires -Version 5.1
<#
.SYNOPSIS
    Fork MaaGF1/MaaGF1, clone to Desktop\MaaGF1, overlay JP assets, push to your fork.
.DESCRIPTION
    One-time migration from MaaGF1 local wrapper into a full upstream fork with Japanese overlay.
    Safe to re-run: skips clone if Desktop\MaaGF1 already exists as a git repo.
#>

$ErrorActionPreference = "Stop"

$DesktopRoot = [Environment]::GetFolderPath("Desktop")
$LegacyRoot  = Join-Path $DesktopRoot "MaaNX2"   # pre-migration local wrapper (removed after first run)
$ProjectRoot = Join-Path $DesktopRoot "MaaGF1"
$UpstreamRepo = "MaaGF1/MaaGF1"

function Test-GhLoggedIn {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & gh auth status 2>&1 | Out-Null
        return ($LASTEXITCODE -eq 0)
    }
    finally {
        $ErrorActionPreference = $prev
    }
}

function Invoke-GhCommand {
    param([Parameter(Mandatory)][string[]]$GhArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & gh @GhArgs
        if ($LASTEXITCODE -ne 0) {
            throw "gh failed (exit $LASTEXITCODE): gh $($GhArgs -join ' ')"
        }
    }
    finally {
        $ErrorActionPreference = $prev
    }
}

function Copy-TreeForce {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path $Source)) {
        Write-Warning "Skip missing: $Source"
        return
    }
    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }
    $parent = Split-Path $Destination -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Copy-Item -Path $Source -Destination $Destination -Recurse -Force
}

function Copy-FilesForce {
    param([string]$SourceDir, [string]$DestDir, [string]$Pattern = "*")
    if (-not (Test-Path $SourceDir)) { return }
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Copy-Item -Path (Join-Path $SourceDir $Pattern) -Destination $DestDir -Recurse -Force
}

function Add-GitignoreLines {
    param([string]$GitignorePath, [string[]]$Lines)
    $existing = @()
    if (Test-Path $GitignorePath) {
        $existing = Get-Content $GitignorePath -Encoding UTF8
    }
    $toAdd = $Lines | Where-Object { $existing -notcontains $_ }
    if ($toAdd.Count -gt 0) {
        if ($existing.Count -gt 0) {
            Add-Content -Path $GitignorePath -Value "" -Encoding UTF8
            Add-Content -Path $GitignorePath -Value "# MaaGF1 JP local runtime (do not commit)" -Encoding UTF8
        }
        Add-Content -Path $GitignorePath -Value ($toAdd -join "`n") -Encoding UTF8
    }
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found. Run: winget install GitHub.cli"
}

if (-not (Test-GhLoggedIn)) {
    Write-Host ""
    Write-Host "[!] GitHub not logged in (one-time setup)" -ForegroundColor Yellow
    Write-Host "    Run: tools\gh_login.bat" -ForegroundColor Cyan
    Write-Host "    Then run again: .\tools\fork_maagf1_main.ps1" -ForegroundColor Cyan
    exit 1
}

$user = Invoke-GhCommand @("api", "user", "--jq", ".login")
$ForkRepo = "${user}/MaaGF1"
Write-Host "==> GitHub user: $user" -ForegroundColor Cyan

$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& gh repo view $ForkRepo 2>&1 | Out-Null
$forkExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prev

if (-not $forkExists) {
    Write-Host "==> Forking $UpstreamRepo ..." -ForegroundColor Cyan
    Invoke-GhCommand @("repo", "fork", $UpstreamRepo, "--clone=false")
}
else {
    Write-Host "==> Fork already exists: $ForkRepo" -ForegroundColor Cyan
}

if (-not (Test-Path (Join-Path $ProjectRoot ".git"))) {
    if (Test-Path $ProjectRoot) {
        Write-Error "Path exists but is not a git repo: $ProjectRoot"
    }
    Write-Host "==> Clone fork to $ProjectRoot ..." -ForegroundColor Cyan
    git clone "https://github.com/$ForkRepo.git" $ProjectRoot
    Push-Location $ProjectRoot
    try {
        $remotes = @(git remote)
        if (-not ($remotes -contains "upstream")) {
            git remote add upstream "https://github.com/$UpstreamRepo.git"
        }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-Path $LegacyRoot)) {
    Write-Error "Legacy MaaGF1 folder not found: $LegacyRoot"
}

Write-Host "==> Overlay JP assets from MaaGF1 ..." -ForegroundColor Cyan

$overlayItems = @(
    @{ Src = Join-Path $LegacyRoot "assets\resource_jp"; Dst = Join-Path $ProjectRoot "assets\resource_jp" },
    @{ Src = Join-Path $LegacyRoot "assets\interface.json"; Dst = Join-Path $ProjectRoot "assets\interface.json" },
    @{ Src = Join-Path $LegacyRoot "assets\lang"; Dst = Join-Path $ProjectRoot "assets\lang" }
)
foreach ($item in $overlayItems) {
    if ((Get-Item $item.Src -ErrorAction SilentlyContinue).PSIsContainer) {
        Copy-TreeForce $item.Src $item.Dst
    }
    else {
        $parent = Split-Path $item.Dst -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Copy-Item $item.Src $item.Dst -Force
    }
}

Copy-FilesForce (Join-Path $LegacyRoot "tools") (Join-Path $ProjectRoot "tools")
Copy-FilesForce (Join-Path $LegacyRoot "scripts") (Join-Path $ProjectRoot "scripts")

$localDocs = Join-Path $LegacyRoot "docs"
if (Test-Path $localDocs) {
    $jpDocs = @("USAGE.ja.md", "STRUCTURE.ja.md", "TEMPLATE_CHECKLIST.ja.md")
    $destDocs = Join-Path $ProjectRoot "docs"
    if (-not (Test-Path $destDocs)) { New-Item -ItemType Directory -Path $destDocs -Force | Out-Null }
    foreach ($name in $jpDocs) {
        $src = Join-Path $localDocs $name
        if (Test-Path $src) {
            Copy-Item $src (Join-Path $destDocs $name) -Force
        }
    }
}

$readmeJa = Join-Path $LegacyRoot "README.ja.md"
if (Test-Path $readmeJa) {
    Copy-Item $readmeJa (Join-Path $ProjectRoot "README.ja.md") -Force
}

$docsSub = Join-Path $LegacyRoot "maagf1-docs"
$docsDst = Join-Path $ProjectRoot "maagf1-docs"
if (Test-Path $docsSub) {
    if (-not (Test-Path $docsDst)) {
        Copy-TreeForce $docsSub $docsDst
    }
    else {
        Write-Host "maagf1-docs already at destination; keeping existing." -ForegroundColor DarkGray
    }
}

$installSrc = Join-Path $LegacyRoot "install"
$installDst = Join-Path $ProjectRoot "install"
if (Test-Path $installSrc) {
    Write-Host "==> Copy local install/ (gitignored) ..." -ForegroundColor Cyan
    Copy-TreeForce $installSrc $installDst
}

$gitignorePath = Join-Path $ProjectRoot ".gitignore"
Add-GitignoreLines $gitignorePath @(
    "install/",
    "logs/",
    "*.log",
    "maagf1-docs/site/"
)

Push-Location $ProjectRoot
try {
    $status = git status --porcelain
    if ($status) {
        git add -A
        git reset HEAD install/ 2>$null
        git status --porcelain install/ 2>$null | ForEach-Object {
            if ($_ -match "^[AM]") { git reset HEAD -- "install/" 2>$null }
        }
        git commit -m @"
Add Japanese Steam overlay (resource_jp, ja-JP UI tools)

Fork of MaaGF1/MaaGF1 with JP assets, build scripts, and local usage docs.
MFAAvalonia display name remains MaaGfl1.
"@
    }
    else {
        Write-Host "No changes to commit." -ForegroundColor DarkGray
    }

    $branch = git rev-parse --abbrev-ref HEAD
    Write-Host "==> Push to $ForkRepo ($branch) ..." -ForegroundColor Cyan
    git push -u origin $branch

    Write-Host ""
    Write-Host "Done. Fork: https://github.com/$ForkRepo" -ForegroundColor Green
    Write-Host "Local:  $ProjectRoot" -ForegroundColor Green
}
finally {
    Pop-Location
}
