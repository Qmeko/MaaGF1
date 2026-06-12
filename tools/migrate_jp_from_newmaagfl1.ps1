#Requires -Version 5.1
<#
.SYNOPSIS
    Sync Japanese assets/docs from sibling NewMaaGfl1 into MaaGF1 (one-way).
.DESCRIPTION
    Copies newer or missing files under assets/ from NewMaaGfl1.
    Does not overwrite MaaGF1 interface.json / ja-JP.json unless -ForceLang.
#>

param(
    [switch]$ForceLang,
    [switch]$IncludeDocs
)

$ErrorActionPreference = "Stop"
$Desktop = [Environment]::GetFolderPath("Desktop")
$SrcRoot = Join-Path $Desktop "NewMaaGfl1"
$DstRoot = Join-Path $Desktop "MaaGF1"

if (-not (Test-Path $SrcRoot)) {
    Write-Error "NewMaaGfl1 not found: $SrcRoot"
}
if (-not (Test-Path $DstRoot)) {
    Write-Error "MaaGF1 not found: $DstRoot"
}

function Copy-IfNewer([string]$RelativePath) {
    $src = Join-Path $SrcRoot $RelativePath
    $dst = Join-Path $DstRoot $RelativePath
    if (-not (Test-Path $src)) { return }
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    if (-not (Test-Path $dst)) {
        Copy-Item $src $dst -Force
        Write-Host "ADD  $RelativePath" -ForegroundColor Green
        return
    }
    if ((Get-Item $src).LastWriteTimeUtc -gt (Get-Item $dst).LastWriteTimeUtc) {
        Copy-Item $src $dst -Force
        Write-Host "NEW  $RelativePath" -ForegroundColor Cyan
    }
}

Write-Host "==> Sync assets from NewMaaGfl1 -> MaaGF1" -ForegroundColor Cyan

$assetsSrc = Join-Path $SrcRoot "assets"
if (Test-Path $assetsSrc) {
    Get-ChildItem $assetsSrc -Recurse -File | ForEach-Object {
        $rel = "assets\" + $_.FullName.Substring($assetsSrc.Length + 1)
        if ($rel -match '\\lang\\(ja-JP|zh-cn)\.json$' -and -not $ForceLang) {
            return
        }
        if ($rel -eq 'assets\interface.json' -and -not $ForceLang) {
            return
        }
        Copy-IfNewer $rel
    }
}

if ($IncludeDocs) {
    $docFiles = @(
        "docs\ARCHITECTURE.ja.md",
        "docs\ROADMAP.ja.md",
        "docs\FLOWCHART_SYSTEM.ja.md",
        "docs\README.ja.md"
    )
    foreach ($f in $docFiles) {
        $src = Join-Path $SrcRoot $f
        if (-not (Test-Path $src)) { continue }
        $raw = Get-Content $src -Raw -Encoding UTF8
        $raw = $raw.Replace('..\MaaGF1\', '.\')
        $raw = $raw.Replace('../MaaGF1/', './')
        $raw = $raw.Replace('`..\MaaGF1\', '`.\\')
        $raw = $raw.Replace('gfl-assistant/', '../NewMaaGfl1/gfl-assistant/')
        $raw = $raw.Replace('../gfl-assistant/', '../NewMaaGfl1/gfl-assistant/')
        $raw = $raw.Replace('`gfl-assistant/', '`../NewMaaGfl1/gfl-assistant/')
        $raw = $raw.Replace('agent/', '../NewMaaGfl1/agent/')
        $dst = Join-Path $DstRoot $f
        $dstDir = Split-Path $dst -Parent
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        Set-Content $dst $raw -Encoding UTF8 -NoNewline
        Write-Host "DOC  $f" -ForegroundColor Yellow
    }
}

Write-Host "Done." -ForegroundColor Green
