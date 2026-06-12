#Requires -Version 5.1
<#
.SYNOPSIS
    Create image directory structure for MaaGfl1 templates.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

$dirs = @(
    "assets\resource_jp\image\dormitory",
    "assets\resource_jp\image\combat\levelUp\13-4",
    "assets\resource_jp\image\public",
    "gfl-assistant\Assets\templates\dormitory",
    "gfl-assistant\Assets\templates\nav",
    "gfl-assistant\Assets\templates\digits",
    "gfl-assistant\Assets\templates\picked",
    "screenshot"
)

foreach ($rel in $dirs) {
    $path = Join-Path $ProjectRoot $rel
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created: $rel" -ForegroundColor Green
    } else {
        Write-Host "Exists:  $rel" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "Next: .\tools\check_templates.ps1" -ForegroundColor Cyan
Write-Host "      gfl-assistant\scripts\coord-picker.bat" -ForegroundColor Cyan
