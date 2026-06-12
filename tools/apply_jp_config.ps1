#Requires -Version 5.1
<#
.SYNOPSIS
    Force MFAAvalonia install/config.json to ja-JP after resource merge.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $ProjectRoot "install\config\config.json"

if (-not (Test-Path $configPath)) {
    Write-Error "config.json not found: $configPath"
}

$cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$cfg.CurrentLanguage = "ja-JP"
$cfg.EnableCheckVersion = $false
$cfg | ConvertTo-Json -Depth 30 | Set-Content $configPath -Encoding UTF8
Write-Host "CurrentLanguage -> ja-JP ($configPath)" -ForegroundColor Green
