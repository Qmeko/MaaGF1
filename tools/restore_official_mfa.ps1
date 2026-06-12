#Requires -Version 5.1
<#
.SYNOPSIS
    Restore official MFAAvalonia v2.12.1 binaries (keep JP resources/config).
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$InstallDir  = Join-Path $ProjectRoot "install"
$TempDir     = Join-Path $env:TEMP "MaaGF1-mfa-restore"
$MfaVersion  = "v2.12.1"
$MfaZip      = "MFAAvalonia-$MfaVersion-win-x64.zip"
$MfaUrl      = "https://github.com/MaaXYZ/MFAAvalonia/releases/download/$MfaVersion/$MfaZip"

$Preserve = @(
    "interface.json",
    "lang",
    "resource_jp",
    "config",
    "appsettings.json"
)

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

Write-Host "==> Restore official MFAAvalonia $MfaVersion" -ForegroundColor Cyan
Ensure-Directory $TempDir
$ZipPath = Join-Path $TempDir $MfaZip
$ExtractDir = Join-Path $TempDir "mfa"

if (-not (Test-Path $ZipPath)) {
    Write-Host "  Downloading..."
    Invoke-WebRequest -Uri $MfaUrl -OutFile $ZipPath -UseBasicParsing
}
if (Test-Path $ExtractDir) { Remove-Item -Recurse -Force $ExtractDir }
Expand-Archive -Path $ZipPath -DestinationPath $ExtractDir -Force

$BackupDir = Join-Path $TempDir "preserve-$(Get-Date -Format 'yyyyMMddHHmmss')"
Ensure-Directory $BackupDir
foreach ($name in $Preserve) {
    $src = Join-Path $InstallDir $name
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $BackupDir $name) -Recurse -Force
    }
}

Write-Host "  Replacing MFA binaries..."
Get-ChildItem $InstallDir -Force | ForEach-Object {
    if ($Preserve -contains $_.Name) { return }
    Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}
Copy-Item -Path (Join-Path $ExtractDir "*") -Destination $InstallDir -Recurse -Force

foreach ($name in $Preserve) {
    $bak = Join-Path $BackupDir $name
    if (Test-Path $bak) {
        $dst = Join-Path $InstallDir $name
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        Copy-Item $bak $dst -Recurse -Force
    }
}

Write-Host "Done. Run: .\tools\build_jp_ui.ps1" -ForegroundColor Green
