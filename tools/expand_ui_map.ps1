#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$mapPath = Join-Path $PSScriptRoot "cn_ui_to_jp.json"
$extractPath = Join-Path $PSScriptRoot "cn_ui_strings_extracted.txt"
$fallbackPath = Join-Path $PSScriptRoot "cn_fallback_literals.json"

$map = @{}
(Get-Content $mapPath -Raw -Encoding UTF8 | ConvertFrom-Json).PSObject.Properties | ForEach-Object {
    $map[$_.Name] = $_.Value
}
$fallback = @{}
(Get-Content $fallbackPath -Raw -Encoding UTF8 | ConvertFrom-Json).PSObject.Properties | ForEach-Object {
    $fallback[$_.Name] = $_.Value
}

function Rough-Translate([string]$Text) {
    if ($map.ContainsKey($Text)) { return $map[$Text] }
    if ($Text -notmatch '[\u4e00-\u9fff]') { return $null }
    if ($Text -match '^\$_') { return $null }
    if ($Text -match '^https?://') { return $null }
    $r = $Text
    foreach ($key in ($fallback.Keys | Sort-Object { $_.Length } -Descending)) {
        $r = $r.Replace($key, $fallback[$key])
    }
    if ($r -match '[\u4e00-\u9fff]' -and $r -eq $Text) { return $null }
    return $r
}

$added = 0
foreach ($line in (Get-Content $extractPath -Encoding UTF8)) {
    $s = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($s)) { continue }
    if ($map.ContainsKey($s)) { continue }
    $jp = Rough-Translate $s
    if ($jp) {
        $map[$s] = $jp
        $added++
    }
}
$ordered = [ordered]@{}
foreach ($k in ($map.Keys | Sort-Object)) { $ordered[$k] = $map[$k] }
($ordered | ConvertTo-Json -Depth 3) | Set-Content $mapPath -Encoding UTF8
Write-Host "Added $added entries. Total: $($map.Count)"
