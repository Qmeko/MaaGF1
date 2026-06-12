#Requires -Version 5.1
<#
.SYNOPSIS
    Download PP-OCRv5 models (det.onnx / rec.onnx) from MaaCommonAssets
#>

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OcrDir = Join-Path $ProjectRoot "assets\resource_jp\model\ocr"
$BaseUrl = "https://raw.githubusercontent.com/MaaXYZ/MaaCommonAssets/main/OCR/ppocr_v5/zh_cn"

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Ensure-Directory $OcrDir

$files = @("det.onnx", "rec.onnx")
foreach ($file in $files) {
    $dest = Join-Path $OcrDir $file
    if (Test-Path $dest) {
        Write-Host "Skip (exists): $file" -ForegroundColor DarkGray
        continue
    }
    $url = "$BaseUrl/$file"
    Write-Host "Download: $file ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    Write-Host "  Done: $dest" -ForegroundColor Green
}

$keysPath = Join-Path $OcrDir "keys.txt"
if (-not (Test-Path $keysPath)) {
    Write-Host "Download: keys.txt ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "$BaseUrl/keys.txt" -OutFile $keysPath -UseBasicParsing
}

Write-Host "OCR models ready: $OcrDir" -ForegroundColor Green
