#Requires -Version 5.1
<#
.SYNOPSIS
    Phase C: Full Japanese UI for interface.json + lang/ja-JP.json
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AssetsDir = Join-Path $ProjectRoot "assets"
$IfacePath = Join-Path $AssetsDir "interface.json"
$LangBasePath = Join-Path $PSScriptRoot "jp_lang_base.json"
$UiMapPath = Join-Path $PSScriptRoot "cn_ui_to_jp.json"
$LangOutPath = Join-Path $AssetsDir "lang\ja-JP.json"

function Read-JsonFile([string]$Path) {
    return (Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Get-UiMap {
    $map = @{}
    (Read-JsonFile $UiMapPath).PSObject.Properties | ForEach-Object {
        $map[$_.Name] = $_.Value
    }
    return $map
}

function To-LangKey([string]$Source) {
    $safe = $Source -replace '[^\w]', '_'
    $safe = $safe -replace '_+', '_'
    $safe = $safe.Trim('_')
    if ($safe.Length -gt 48) { $safe = $safe.Substring(0, 48) }
    if ([string]::IsNullOrWhiteSpace($safe)) {
        $hash = [System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($Source)
            )
        ).Replace("-", "").Substring(0, 10)
        return "_Opt_$hash"
    }
    return "_Opt_$safe"
}

function Translate-Ui([string]$Text, [hashtable]$Map) {
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    if ($Text -match '^\$_') { return $Text }
    if ($Map.ContainsKey($Text)) { return $Map[$Text] }
    return $Text
}

function Has-Cjk([string]$Text) {
    return ($Text -match '[\u4e00-\u9fff\u3400-\u4dbf]')
}

Write-Host "========================================" -ForegroundColor Green
Write-Host " MaaGF1 Phase C: Full JP UI translate" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

if (-not (Test-Path $IfacePath)) {
    Write-Error "interface.json not found: $IfacePath"
}

$uiMap = Get-UiMap
$iface = Read-JsonFile $IfacePath
$lang = @{}
(Read-JsonFile $LangBasePath).PSObject.Properties | ForEach-Object {
    $lang[$_.Name] = $_.Value
}

$taskCount = 0
foreach ($t in $iface.task) {
    if ($t.name) {
        $jp = Translate-Ui $t.name $uiMap
        if ($jp -ne $t.name) { $t.name = $jp }
    }
    if ($t.doc) {
        $jp = Translate-Ui $t.doc $uiMap
        if ($jp -ne $t.doc) { $t.doc = $jp }
    }
    if ($t.label -match '^\$_') {
        $key = $t.label.TrimStart('$')
        if (-not $lang.ContainsKey($key) -and $t.name) {
            $lang[$key] = $t.name
        }
    }
    $taskCount++
}

$optCount = 0
$caseCount = 0
if ($iface.option) {
    foreach ($prop in $iface.option.PSObject.Properties) {
        $optKey = [string]$prop.Name
        $optVal = $prop.Value
        $jpOpt = Translate-Ui $optKey $uiMap
        $hasLabel = $false
        if ($optVal.PSObject.Properties.Match('^label$').Count -gt 0) {
            $hasLabel = -not [string]::IsNullOrWhiteSpace([string]$optVal.label)
        }
        $langKey = To-LangKey $optKey
        if (-not $lang.ContainsKey($langKey) -or (Has-Cjk $lang[$langKey])) {
            $lang[$langKey] = $jpOpt
        }
        if (-not $hasLabel -or (Has-Cjk ([string]$optVal.label))) {
            if ($optVal -is [pscustomobject]) {
                $optVal | Add-Member -NotePropertyName 'label' -NotePropertyValue "`$$langKey" -Force
            }
            $optCount++
        }
        if ($optVal.cases) {
            foreach ($case in $optVal.cases) {
                if (-not $case.name) { continue }
                $jpCase = Translate-Ui ([string]$case.name) $uiMap
                $hasCaseLabel = ($case.PSObject.Properties.Match('^label$').Count -gt 0)
                $needLabel = (-not $hasCaseLabel) -or (Has-Cjk ([string]$case.label))
                if ($needLabel -and $jpCase -ne [string]$case.name) {
                    $case | Add-Member -NotePropertyName 'label' -NotePropertyValue $jpCase -Force
                    $caseCount++
                }
            }
        }
        if ($optVal.inputs) {
            foreach ($inp in $optVal.inputs) {
                if ($inp.label) {
                    $jpInp = Translate-Ui ([string]$inp.label) $uiMap
                    if ($jpInp -ne $inp.label) { $inp.label = $jpInp }
                }
            }
        }
    }
}

($iface | ConvertTo-Json -Depth 100) | Set-Content $IfacePath -Encoding UTF8

$orderedLang = [ordered]@{}
foreach ($k in ($lang.Keys | Sort-Object)) {
    $orderedLang[$k] = $lang[$k]
}
($orderedLang | ConvertTo-Json -Depth 5) | Set-Content $LangOutPath -Encoding UTF8

Write-Host "Tasks processed: $taskCount" -ForegroundColor Green
Write-Host "Option labels added: $optCount" -ForegroundColor Green
Write-Host "Case labels added: $caseCount" -ForegroundColor Green
Write-Host "Lang entries: $($lang.Count)" -ForegroundColor Green
Write-Host "Done. Run: .\tools\sync_assets.ps1 && .\tools\apply_jp_config.ps1" -ForegroundColor Yellow
