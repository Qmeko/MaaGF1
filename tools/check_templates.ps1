#Requires -Version 5.1
<#
.SYNOPSIS
    MaaGF1: Maa pipeline template check. gfl-assistant refs use sibling NewMaaGfl1.
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GflRoot = Join-Path (Split-Path $ProjectRoot -Parent) "NewMaaGfl1\gfl-assistant"

function Get-TemplatePathsFromJson([string]$JsonPath) {
    if (-not (Test-Path $JsonPath)) { return @() }
    $raw = Get-Content $JsonPath -Raw -Encoding UTF8
    $matches = [regex]::Matches($raw, '"template"\s*:\s*(?:"([^"]+)"|\[([^\]]+)\])')
    $result = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($m in $matches) {
        if ($m.Groups[1].Success -and $m.Groups[1].Value) {
            [void]$result.Add($m.Groups[1].Value)
        }
        if ($m.Groups[2].Success) {
            foreach ($inner in [regex]::Matches($m.Groups[2].Value, '"([^"]+)"')) {
                [void]$result.Add($inner.Groups[1].Value)
            }
        }
    }
    return $result
}

function Get-TemplatePathsFromText([string]$Text) {
    $result = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($m in [regex]::Matches($Text, 'templates/[A-Za-z0-9_./-]+\.png')) {
        [void]$result.Add($m.Value)
    }
    return $result
}

$required = [System.Collections.Generic.HashSet[string]]::new()

$pipelineDir = Join-Path $ProjectRoot "assets\resource_jp\pipeline"
if (Test-Path $pipelineDir) {
    Get-ChildItem $pipelineDir -Recurse -Filter "*.json" | ForEach-Object {
        foreach ($t in (Get-TemplatePathsFromJson $_.FullName)) {
            [void]$required.Add("assets/resource_jp/image/$t")
        }
    }
}

$gflAssets = Join-Path $GflRoot "Assets"
if (Test-Path $gflAssets) {
    Get-ChildItem $gflAssets -Recurse -Include "*.json" | ForEach-Object {
        foreach ($t in (Get-TemplatePathsFromText (Get-Content $_.FullName -Raw -Encoding UTF8))) {
            [void]$required.Add("gfl-assistant/Assets/$t")
        }
    }
}

$gflSrc = Join-Path $GflRoot "GflAssistant"
if (Test-Path $gflSrc) {
    Get-ChildItem $gflSrc -Recurse -Include "*.cs" | ForEach-Object {
        foreach ($t in (Get-TemplatePathsFromText (Get-Content $_.FullName -Raw -Encoding UTF8))) {
            [void]$required.Add("gfl-assistant/Assets/$t")
        }
    }
}

$maaDorm = @(
    "assets/resource_jp/image/dormitory/Gvisit.png",
    "assets/resource_jp/image/dormitory/dianzan.png",
    "assets/resource_jp/image/dormitory/Gbattery1.png",
    "assets/resource_jp/image/dormitory/battery.png",
    "assets/resource_jp/image/dormitory/next.png",
    "assets/resource_jp/image/dormitory/Gback1.png",
    "assets/resource_jp/image/dormitory/Gback2.png",
    "assets/resource_jp/image/dormitory/message.png",
    "assets/resource_jp/image/dormitory/Gheart.png"
)
foreach ($p in $maaDorm) { [void]$required.Add($p) }

$missing = @()
$found = @()
foreach ($rel in ($required | Sort-Object)) {
    if ($rel.StartsWith("gfl-assistant/", [StringComparison]::Ordinal)) {
        $full = Join-Path $GflRoot ($rel.Substring("gfl-assistant/".Length) -replace '/', '\')
    } else {
        $full = Join-Path $ProjectRoot ($rel -replace '/', '\')
    }
    if (Test-Path $full) { $found += $rel } else { $missing += $rel }
}

Write-Host ""
Write-Host "=== MaaGF1 Template Check ===" -ForegroundColor Cyan
Write-Host "Found:   $($found.Count)" -ForegroundColor Green
Write-Host "Missing: $($missing.Count)" -ForegroundColor $(if ($missing.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($missing.Count -gt 0) {
    Write-Host "--- Missing ---" -ForegroundColor Yellow
    foreach ($m in $missing) {
        Write-Host "  [ ] $m"
    }
    Write-Host ""
    Write-Host "Guide: ..\NewMaaGfl1\gfl-assistant\docs\MaaGfl1_TEMPLATE_CAPTURE.ja.md"
    Write-Host "Tool:  ..\NewMaaGfl1\gfl-assistant\scripts\coord-picker.bat"
    exit 1
}

Write-Host "All required templates are present." -ForegroundColor Green
exit 0
