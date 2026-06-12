#Requires -Version 5.1
<#
.SYNOPSIS
    Fork MaaGF1/docs to your GitHub account and push Japanese bilingual changes.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DocsRoot = Join-Path $ProjectRoot "maagf1-docs"

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

if (-not (Test-Path $DocsRoot)) {
    Write-Error "maagf1-docs not found: $DocsRoot"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found. Run: winget install GitHub.cli"
}

Push-Location $DocsRoot
try {
    if (-not (Test-GhLoggedIn)) {
        Write-Host ""
        Write-Host "[!] GitHub not logged in (one-time setup)" -ForegroundColor Yellow
        Write-Host "    Run either:" -ForegroundColor Yellow
        Write-Host "      tools\gh_login.bat" -ForegroundColor Cyan
        Write-Host "    or:" -ForegroundColor Yellow
        Write-Host "      gh auth login --hostname github.com --git-protocol https --web" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    Then run again:" -ForegroundColor Yellow
        Write-Host "      .\tools\fork_maagf1_docs.ps1" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }

    $user = Invoke-GhCommand @("api", "user", "--jq", ".login")
    Write-Host "==> GitHub user: $user" -ForegroundColor Cyan

    $status = git status --porcelain
    if ($status) {
        git add -A
        git commit -m "Add Japanese bilingual translations (MaaGF1 fork)"
    }

    $remotes = @(git remote)
    if ($remotes -contains "upstream") {
        Write-Host "upstream remote already configured." -ForegroundColor DarkGray
    }
    elseif ($remotes -contains "origin") {
        $originUrl = git remote get-url origin
        if ($originUrl -match "MaaGF1/docs") {
            git remote rename origin upstream
            Write-Host "Renamed origin -> upstream" -ForegroundColor DarkGray
        }
    }

    $remotes = @(git remote)
    if (-not ($remotes -contains "origin")) {
        $forkRepo = "${user}/docs"
        $forkExists = $false
        $prev = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & gh repo view $forkRepo 2>&1 | Out-Null
        $forkExists = ($LASTEXITCODE -eq 0)
        $ErrorActionPreference = $prev

        if ($forkExists) {
            Write-Host "==> Fork already exists: $forkRepo" -ForegroundColor Cyan
            git remote add origin "https://github.com/$forkRepo.git"
        }
        else {
            Write-Host "==> Forking current repo (upstream) ..." -ForegroundColor Cyan
            # gh v2.94: --remote cannot be used with explicit repo argument.
            # Run inside cloned repo without argument; uses upstream remote.
            Invoke-GhCommand @("repo", "fork", "--remote=true", "--remote-name=origin")
        }
    }

    $branch = git rev-parse --abbrev-ref HEAD
    $forkRepo = "${user}/docs"
    Write-Host "==> Push to fork $forkRepo branch $branch ..." -ForegroundColor Cyan
    git push -u origin $branch

    $forkUrl = "https://github.com/$forkRepo"
    Write-Host ""
    Write-Host "Done. Your fork: $forkUrl" -ForegroundColor Green
}
finally {
    Pop-Location
}
