@echo off
setlocal
cd /d "%~dp0.."
set "PATH=%PATH%;%ProgramFiles%\GitHub CLI"
echo.
echo === GitHub login (one-time) ===
echo Browser will open. Complete login, then run:
echo   tools\fork_maagf1_docs.ps1
echo.
gh auth login --hostname github.com --git-protocol https --web
if errorlevel 1 (
    echo Login failed or cancelled.
    pause
    exit /b 1
)
echo.
echo Login OK. Run: powershell -File tools\fork_maagf1_docs.ps1
pause
