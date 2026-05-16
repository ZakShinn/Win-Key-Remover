@echo off
cd /d "%~dp0"
set "PS51=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=%~dp0Win-Key-Remover.ps1"
if not exist "%SCRIPT%" (
    echo Win-Key-Remover.ps1 not found in: %~dp0
    pause
    exit /b 1
)
echo Starting Win-Key-Remover as Administrator...
echo Thu muc: %~dp0
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%PS51%' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File','%SCRIPT%' -WorkingDirectory '%~dp0' -Verb RunAs -Wait"
exit /b %ERRORLEVEL%
