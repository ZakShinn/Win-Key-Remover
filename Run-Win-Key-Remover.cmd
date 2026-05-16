@echo off
:: Run Win-Key-Remover with Windows PowerShell 5.1 as Administrator
set "PS51=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SCRIPT=%~dp0Win-Key-Remover.ps1"
if not exist "%SCRIPT%" (
    echo Win-Key-Remover.ps1 not found next to this file.
    pause
    exit /b 1
)
powershell -Command "Start-Process -FilePath '%PS51%' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%SCRIPT%' -Verb RunAs"
exit /b 0
