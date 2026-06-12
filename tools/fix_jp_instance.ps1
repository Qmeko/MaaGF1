#Requires -Version 5.1
<#
.SYNOPSIS
    Fix MFAAvalonia config/instance for JP connection (Phase C).
#>

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $ProjectRoot "install\config\config.json"
$instancePath = Join-Path $ProjectRoot "install\config\instances\default.json"
$tasksPath = Join-Path $PSScriptRoot "jp_instance_tasks.json"

function Read-Json([string]$Path) {
    return Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Write-Json([string]$Path, $Obj) {
    $Obj | ConvertTo-Json -Depth 50 | Set-Content $Path -Encoding UTF8
}

$tasks = Read-Json $tasksPath

Write-Host "==> Fix config.json (ja-JP)" -ForegroundColor Cyan
$cfg = Read-Json $configPath
$cfg.CurrentLanguage = "ja-JP"
$cfg.EnableCheckVersion = $false
Write-Json $configPath $cfg

Write-Host "==> Fix default instance (Resource_JP + Win32_Background)" -ForegroundColor Cyan
$inst = Read-Json $instancePath
$inst.Resource = "Resource_JP"
$inst.CurrentControllerName = "Win32_Background"
$inst.CurrentController = 0
$inst.DesktopWindowClassName = "UnityWndClass"
$inst.DesktopWindowName = $tasks.desktop_window_name
$inst.Win32ControlMouseType = "SendMessageWithCursorPos"
$inst.Win32ControlScreenCapType = "PrintWindow"
$inst.CurrentTasks = @($tasks.jp_only) + @($tasks.cn_merged)

Write-Json $instancePath $inst
Write-Host "Config + instance fixed." -ForegroundColor Green
Write-Host "Restart MFAAvalonia and refresh device list (game must be running)." -ForegroundColor Yellow
