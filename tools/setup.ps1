#Requires -Version 5.1
<#
.SYNOPSIS
    MaaGfl1 setup for Japanese Steam client (Dolls' Frontline)
#>

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AssetsDir   = Join-Path $ProjectRoot "assets"
$OutputDir   = Join-Path $ProjectRoot "install"
$TempDir     = Join-Path $env:TEMP "MaaGfl1-setup"
$MfaVersion  = "v2.12.1"
$MfaZip      = "MFAAvalonia-$MfaVersion-win-x64.zip"
$MfaUrl      = "https://github.com/MaaXYZ/MFAAvalonia/releases/download/$MfaVersion/$MfaZip"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Write-Host "========================================" -ForegroundColor Green
Write-Host " MaaGfl1 Setup (JP Steam Client)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Step "Prepare directories"
Ensure-Directory $TempDir
Ensure-Directory $OutputDir

$ZipPath = Join-Path $TempDir $MfaZip
$ExtractDir = Join-Path $TempDir "mfa"

Write-Step "Download MFAAvalonia $MfaVersion"
Write-Host "  $MfaUrl"
Invoke-WebRequest -Uri $MfaUrl -OutFile $ZipPath -UseBasicParsing

Write-Step "Extract GUI"
if (Test-Path $ExtractDir) { Remove-Item -Recurse -Force $ExtractDir }
Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force

Write-Step "Install to install/"
Get-ChildItem $OutputDir -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $ExtractDir "*") -Destination $OutputDir -Recurse -Force

Write-Step "Deploy MaaGfl1 resources"
Copy-Item (Join-Path $AssetsDir "interface.json") (Join-Path $OutputDir "interface.json") -Force

$langSrc = Join-Path $AssetsDir "lang"
$langDst = Join-Path $OutputDir "lang"
Ensure-Directory $langDst
Copy-Item (Join-Path $langSrc "*.json") $langDst -Force

$resJpSrc = Join-Path $AssetsDir "resource_jp"
$resJpDst = Join-Path $OutputDir "resource_jp"
if (Test-Path $resJpDst) { Remove-Item -Recurse -Force $resJpDst }
Copy-Item $resJpSrc $resJpDst -Recurse -Force

$configDir = Join-Path $OutputDir "config"
Ensure-Directory $configDir
$configPath = Join-Path $configDir "config.json"
if (-not (Test-Path $configPath)) {
    @{
        CurrentLanguage = "ja-JP"
        ColorTheme      = "Blue"
        BaseTheme       = "Light"
    } | ConvertTo-Json | Set-Content $configPath -Encoding UTF8
} else {
    $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $cfg.CurrentLanguage = "ja-JP"
    $cfg | ConvertTo-Json -Depth 20 | Set-Content $configPath -Encoding UTF8
}

Write-Step "Fetch OCR models"
$ocrScript = Join-Path $PSScriptRoot "fetch_ocr_model.ps1"
if (Test-Path $ocrScript) {
    & $ocrScript
}

Write-Step "Done"
Write-Host ""
Write-Host "Install dir: $OutputDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Run DependencySetup if present, or install .NET 10 + VC++ 14.4"
Write-Host "  2. Game: 1280x720 windowed, Steam JP (Dolls Frontline)"
Write-Host "  3. Start install\MFAAvalonia.exe"
Write-Host "  4. Resource: Japanese (Steam)"
Write-Host "  5. Controller: Background (high performance)"
Write-Host "  6. Language: ja-JP"
Write-Host "  7. Run task: 0.Smoke test"
Write-Host ""
Write-Host "Guide: docs\USAGE.ja.md"
Write-Host ""
