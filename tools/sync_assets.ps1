#Requires -Version 5.1
<#
.SYNOPSIS
    Sync assets/ changes to install/ (restart MFAAvalonia after)
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AssetsDir   = Join-Path $ProjectRoot "assets"
$OutputDir   = Join-Path $ProjectRoot "install"

if (-not (Test-Path $OutputDir)) {
    Write-Error "install/ not found. Run .\tools\setup.ps1 first."
}

Write-Host "MaaGfl1: syncing assets -> install ..." -ForegroundColor Cyan

Copy-Item (Join-Path $AssetsDir "interface.json") (Join-Path $OutputDir "interface.json") -Force

$langSrc = Join-Path $AssetsDir "lang"
$langDst = Join-Path $OutputDir "lang"
if (-not (Test-Path $langDst)) { New-Item -ItemType Directory -Path $langDst -Force | Out-Null }
Copy-Item (Join-Path $langSrc "*.json") $langDst -Force

$resJpSrc = Join-Path $AssetsDir "resource_jp"
$resJpDst = Join-Path $OutputDir "resource_jp"
if (Test-Path $resJpDst) { Remove-Item -Recurse -Force $resJpDst }
Copy-Item $resJpSrc $resJpDst -Recurse -Force

Write-Host "Done. Restart MFAAvalonia." -ForegroundColor Green
