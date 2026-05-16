@echo off
cd /d "%~dp0"
set "PS51=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=%~dp0Win-Key-Remover-Debug.ps1"
if not exist "%SCRIPT%" (
    echo Win-Key-Remover-Debug.ps1 not found.
    pause
    exit /b 1
)
"%PS51%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -DownloadTest %*
echo Exit code: %ERRORLEVEL%
pause
