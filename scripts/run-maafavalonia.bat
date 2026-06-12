@echo off
setlocal
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\tools\apply_jp_config.ps1" >nul 2>&1
set "EXE=%CD%\install\MFAAvalonia.exe"
if not exist "%EXE%" (
    echo [MaaGF1] MFAAvalonia.exe not found.
    echo Run: tools\setup.ps1
    pause
    exit /b 1
)
start "" "%EXE%"
exit /b 0
