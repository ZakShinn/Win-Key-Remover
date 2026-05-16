# Minimal launcher for: irm .../Install.ps1 | iex
# No culture variables — only downloads Win-Key-Remover.ps1 and runs it in a new process.
$ErrorActionPreference = 'Stop'
$url = 'https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1'
$dest = Join-Path $env:TEMP 'Win-Key-Remover.ps1'
(New-Object System.Net.WebClient).DownloadFile($url, $dest)
$ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
if (-not (Test-Path -LiteralPath $ps51)) { $ps51 = 'powershell.exe' }
& $ps51 -NoProfile -ExecutionPolicy Bypass -File $dest -WkrSkipUpdate
exit $LASTEXITCODE
