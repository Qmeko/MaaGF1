#Requires -Version 5.1
<#
.SYNOPSIS
    Preview MaaGF1 bilingual docs locally (mkdocs serve).
#>

$ErrorActionPreference = "Stop"
$DocsRoot = Join-Path (Split-Path -Parent $PSScriptRoot) "maagf1-docs"
if (-not (Test-Path $DocsRoot)) {
    Write-Error "maagf1-docs not found. Clone exists at MaaGF1\maagf1-docs"
}

Push-Location $DocsRoot
try {
    python -m pip install -q -r requirements.txt 2>$null
    if ($LASTEXITCODE -ne 0) {
        pip install -q -r requirements.txt
    }
    Write-Host "Open http://127.0.0.1:8000" -ForegroundColor Green
    mkdocs serve -a 127.0.0.1:8000
}
finally {
    Pop-Location
}
