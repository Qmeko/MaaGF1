#Requires -Version 5.1
<#
.SYNOPSIS
    One-shot: expand map, translate UI, sync install, set ja-JP.
#>
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$ProjectRoot = Split-Path -Parent $here

& (Join-Path $here "restore_official_mfa.ps1")
& (Join-Path $here "extract_cn_ui_strings.ps1")
& (Join-Path $here "expand_ui_map.ps1")
& (Join-Path $here "translate_phase_c.ps1")
& (Join-Path $here "sync_assets.ps1")
& (Join-Path $here "apply_jp_config.ps1")

$langJa = Join-Path $ProjectRoot "assets\lang\ja-JP.json"
$langZh = Join-Path $ProjectRoot "assets\lang\zh-cn.json"
Copy-Item $langJa $langZh -Force
Copy-Item $langJa (Join-Path $ProjectRoot "install\lang\zh-cn.json") -Force

$tasks = Get-Content (Join-Path $here "jp_instance_tasks.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$instPath = Join-Path $ProjectRoot "install\config\instances\default.json"
$inst = Get-Content $instPath -Raw -Encoding UTF8 | ConvertFrom-Json
$inst.Resource = "Resource_JP"
$inst.CurrentControllerName = "Win32_Background"
$inst.CurrentController = 0
$inst.DesktopWindowClassName = "UnityWndClass"
$inst.DesktopWindowName = $tasks.desktop_window_name
$inst | ConvertTo-Json -Depth 50 | Set-Content $instPath -Encoding UTF8

Write-Host ""
Write-Host "JP UI build complete. Restart MFAAvalonia (ja-JP)." -ForegroundColor Green
