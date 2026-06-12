#Requires -Version 5.1
$ifacePath = Join-Path (Split-Path -Parent $PSScriptRoot) "assets\interface.json"
if (-not (Test-Path $ifacePath)) {
    $ifacePath = Join-Path (Split-Path -Parent $PSScriptRoot) "install\interface.json"
}
$iface = Get-Content $ifacePath -Raw -Encoding UTF8 | ConvertFrom-Json
$names = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($t in $iface.task) {
    if ($t.name) { [void]$names.Add([string]$t.name) }
    if ($t.doc) { [void]$names.Add([string]$t.doc) }
}
if ($iface.option) {
    foreach ($prop in $iface.option.PSObject.Properties) {
        [void]$names.Add([string]$prop.Name)
        if ($prop.Value.cases) {
            foreach ($case in $prop.Value.cases) {
                if ($case.name) { [void]$names.Add([string]$case.name) }
                if ($case.label -and $case.label -notmatch '^\$_') { [void]$names.Add([string]$case.label) }
            }
        }
        if ($prop.Value.inputs) {
            foreach ($inp in $prop.Value.inputs) {
                if ($inp.label) { [void]$names.Add([string]$inp.label) }
            }
        }
    }
}
$out = Join-Path $PSScriptRoot "cn_ui_strings_extracted.txt"
$names | Sort-Object | Set-Content $out -Encoding UTF8
Write-Host "Extracted $($names.Count) strings -> $out"
