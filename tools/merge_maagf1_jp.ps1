#Requires -Version 5.1
<#
.SYNOPSIS
    Merge MaaGF1 v2 CN resource package into MaaGF1 Japanese assets (Phase B).
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AssetsDir   = Join-Path $ProjectRoot "assets"
$InstallDir  = Join-Path $ProjectRoot "install"
$CnResource  = Join-Path $InstallDir "resource"
$JpResource  = Join-Path $AssetsDir "resource_jp"
$OcrMapPath  = Join-Path $PSScriptRoot "ocr_cn_to_jp.json"
$TaskNameMapPath = Join-Path $PSScriptRoot "cn_task_name_map.json"
$DocSnippetMapPath = Join-Path $PSScriptRoot "cn_doc_snippet_map.json"
$LangBasePath = Join-Path $PSScriptRoot "jp_lang_base.json"
$JpTasksSeedPath = Join-Path $PSScriptRoot "jp_tasks_seed.json"
$MergeConfigPath = Join-Path $PSScriptRoot "jp_merge_config.json"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Read-JsonFile([string]$Path) {
    return (Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Get-OcrMap {
    $map = @{}
    (Read-JsonFile $OcrMapPath).PSObject.Properties | ForEach-Object {
        $map[$_.Name] = $_.Value
    }
    return $map
}

function Apply-OcrMapToJsonFile([string]$Path, [hashtable]$Map) {
    $raw = Get-Content $Path -Raw -Encoding UTF8
    $changed = $raw
    foreach ($key in ($Map.Keys | Sort-Object { $_.Length } -Descending)) {
        $quotedKey = '"' + $key + '"'
        $quotedVal = '"' + $Map[$key] + '"'
        $changed = $changed.Replace($quotedKey, $quotedVal)
        $changed = $changed.Replace($key, $Map[$key])
    }
    if ($changed -ne $raw) {
        Set-Content -Path $Path -Value $changed -Encoding UTF8 -NoNewline
    }
}

function Translate-TaskName([string]$Name) {
    if ([string]::IsNullOrEmpty($Name)) { return $Name }
    $cfg = Read-JsonFile $TaskNameMapPath
    $n = $Name
    foreach ($pair in $cfg.prefix) {
        $n = $n -replace $pair[0], $pair[1]
    }
    foreach ($pair in $cfg.literal) {
        $n = $n.Replace($pair[0], $pair[1])
    }
    return $n
}

function Translate-DocSnippet([string]$Doc) {
    if ([string]::IsNullOrEmpty($Doc)) { return $Doc }
    $cfg = Read-JsonFile $DocSnippetMapPath
    $d = $Doc
    foreach ($pair in $cfg.literal) {
        $d = $d.Replace($pair[0], $pair[1])
    }
    return $d
}

$ProtectedRelative = @(
    "pipeline\tasks\dormitory_like.json",
    "pipeline\tasks\smoke_test.json",
    "pipeline\tasks\exp_134_entry.json",
    "pipeline\tasks\exp_134_deploy.json",
    "pipeline\tasks\exp_134_battle.json",
    "pipeline\tasks\exp_134_squad.json",
    "pipeline\tasks\exp_134_reset.json",
    "pipeline\public\return_main.json",
    "pipeline\public\navigation.json",
    "pipeline\public\stage_clear.json"
)

Write-Host "========================================" -ForegroundColor Green
Write-Host " MaaGF1 Phase B: CN package -> JP merge" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

if (-not (Test-Path $CnResource)) {
    Write-Error "CN resource not found: $CnResource"
}

Write-Step "Backup protected JP pipeline files"
$BackupDir = Join-Path $env:TEMP "MaaGF1-jp-protected-$(Get-Date -Format 'yyyyMMddHHmmss')"
Ensure-Directory $BackupDir
foreach ($rel in $ProtectedRelative) {
    $src = Join-Path $JpResource $rel
    if (Test-Path $src) {
        $dst = Join-Path $BackupDir $rel
        Ensure-Directory (Split-Path $dst -Parent)
        Copy-Item $src $dst -Force
    }
}

Write-Step "Copy CN pipeline + image -> assets/resource_jp"
$cnPipeline = Join-Path $CnResource "pipeline"
$cnImage    = Join-Path $CnResource "image"
if (Test-Path $cnPipeline) {
    Copy-Item -Path (Join-Path $cnPipeline "*") -Destination (Join-Path $JpResource "pipeline") -Recurse -Force
}
if (Test-Path $cnImage) {
    Ensure-Directory (Join-Path $JpResource "image")
    Copy-Item -Path (Join-Path $cnImage "*") -Destination (Join-Path $JpResource "image") -Recurse -Force
}

Write-Step "Restore protected JP pipeline files"
foreach ($rel in $ProtectedRelative) {
    $bak = Join-Path $BackupDir $rel
    if (Test-Path $bak) {
        $dst = Join-Path $JpResource $rel
        Ensure-Directory (Split-Path $dst -Parent)
        Copy-Item $bak $dst -Force
        Write-Host "  kept: $rel" -ForegroundColor DarkGray
    }
}

Write-Step "Apply OCR CN->JP map to pipeline JSON"
$ocrMap = Get-OcrMap
$pipelineRoot = Join-Path $JpResource "pipeline"
Get-ChildItem $pipelineRoot -Recurse -Filter "*.json" | ForEach-Object {
    $rel = $_.FullName.Substring($pipelineRoot.Length + 1)
    $skip = $false
    foreach ($p in $ProtectedRelative) {
        $prot = $p -replace '^pipeline\\', ''
        if ($rel -eq $prot) { $skip = $true; break }
    }
    if (-not $skip) {
        Apply-OcrMapToJsonFile $_.FullName $ocrMap
    }
}
Write-Host "  pipeline JSON files processed" -ForegroundColor Green

Write-Step "Build merged interface.json"
$cnInterfacePath = Join-Path $InstallDir "interface.json"
if (-not (Test-Path $cnInterfacePath)) {
    Write-Error "install/interface.json not found"
}
$cn = Read-JsonFile $cnInterfacePath
$jpTasksSeed = Read-JsonFile $JpTasksSeedPath
$MergeConfig = Read-JsonFile $MergeConfigPath
$SkipCnEntries = @($MergeConfig.skip_cn_entries)
$windowRegex = $MergeConfig.window_regex

$mergedTasks = [System.Collections.Generic.List[object]]::new()
foreach ($t in $jpTasksSeed) { [void]$mergedTasks.Add($t) }

foreach ($t in $cn.task) {
    $entry = $t.entry
    if ($SkipCnEntries -contains $entry) { continue }
    $clone = [ordered]@{}
    foreach ($prop in $t.PSObject.Properties) {
        $val = $prop.Value
        if ($prop.Name -eq "name" -and $val -is [string]) {
            $val = Translate-TaskName $val
        }
        if ($prop.Name -eq "doc" -and $val -is [string]) {
            $val = Translate-DocSnippet $val
        }
        $clone[$prop.Name] = $val
    }
    [void]$mergedTasks.Add([pscustomobject]$clone)
}

$jpInterface = [ordered]@{
    '$schema' = 'http://json-schema.org/draft-07/schema#'
    interface_version = 2
    name = 'MaaGfl1'
    title = '$_MaaGfl1_Title'
    description = '$_MaaGfl1_Description'
    license = '$_License_URL'
    version = if ($cn.version) { $cn.version } else { 'v2.0.1' }
    url = 'https://github.com/MaaGF1/MaaGF1'
    mirrorchyan_rid = $null
    mirrorchyan_multiplatform = $false
    controller = @(
        @{
            name = 'Win32_Background'
            label = '$_Controller_Background'
            type = 'Win32'
            win32 = @{
                class_regex = '.*'
                window_regex = $windowRegex
                screencap = 16
                mouse = 32
                keyboard = 2
            }
        },
        @{
            name = 'Win32_Foreground'
            label = '$_Controller_Foreground'
            type = 'Win32'
            win32 = @{
                class_regex = '.*'
                window_regex = $windowRegex
                screencap = 16
                mouse = 1
                keyboard = 2
            }
        }
    )
    resource = @(
        @{
            name = 'Resource_JP'
            label = '$_Resource_JP'
            path = @('{PROJECT_DIR}/resource_jp/')
        }
    )
    languages = @{
        'ja-JP' = 'lang/ja-JP.json'
    }
    task = $mergedTasks.ToArray()
}

$optionHash = @{}
if ($cn.option) {
    $cn.option.PSObject.Properties | ForEach-Object { $optionHash[$_.Name] = $_.Value }
}
$assetsIfacePath = Join-Path $AssetsDir "interface.json"
if (Test-Path $assetsIfacePath) {
    $assetsIface = Read-JsonFile $assetsIfacePath
    if ($assetsIface.option -and $assetsIface.option.'134_loops') {
        $optionHash['134_loops'] = $assetsIface.option.'134_loops'
    }
}
if ($optionHash.Count -gt 0) {
    $jpInterface['option'] = $optionHash
}

$ifaceOut = Join-Path $AssetsDir "interface.json"
($jpInterface | ConvertTo-Json -Depth 100) | Set-Content $ifaceOut -Encoding UTF8
Write-Host "  tasks: $($mergedTasks.Count)" -ForegroundColor Green

Write-Step "Expand lang/ja-JP.json"
$langPath = Join-Path $AssetsDir "lang\ja-JP.json"
$lang = @{}
(Read-JsonFile $LangBasePath).PSObject.Properties | ForEach-Object {
    $lang[$_.Name] = $_.Value
}

foreach ($t in $cn.task) {
    if ($t.label -match '^\$_') {
        $key = $t.label.TrimStart('$')
        if (-not $lang.ContainsKey($key)) {
            $srcName = if ($t.name) { $t.name } else { $key }
            $lang[$key] = Translate-TaskName $srcName
        }
    }
}

$orderedLang = [ordered]@{}
foreach ($k in ($lang.Keys | Sort-Object)) {
    $orderedLang[$k] = $lang[$k]
}
($orderedLang | ConvertTo-Json -Depth 5) | Set-Content $langPath -Encoding UTF8

Write-Step "Copy mfa_layout.json if present"
$cnLayout = Join-Path $CnResource "mfa_layout.json"
if (Test-Path $cnLayout) {
    Copy-Item $cnLayout (Join-Path $JpResource "mfa_layout.json") -Force
}

Write-Step "Done. Run: .\tools\sync_assets.ps1"
Write-Host "Then run: .\tools\apply_jp_config.ps1" -ForegroundColor Yellow
Write-Host "Note: CN template images copied - JP client may need coord-picker retake." -ForegroundColor Yellow
