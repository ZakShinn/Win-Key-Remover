# Win-Key-Remover-Debug.ps1  - diagnostic only (does not remove keys)
<#
.SYNOPSIS
  Environment check for Win-Key-Remover (no key removal).
.PARAMETER Lang
  vi | en  - report language.
.PARAMETER DownloadTest
  Try downloading the script from GitHub raw URL.
.EXAMPLE
  .\Win-Key-Remover-Debug.ps1
.EXAMPLE
  .\Win-Key-Remover-Debug.ps1 -Lang en -DownloadTest
#>

[CmdletBinding()]
param(
    [ValidateSet('vi', 'en')]
    [Alias('Lang')]
    [string]$WkrUiLanguage = 'vi',
    [switch]$DownloadTest
)

$ErrorActionPreference = 'Continue'
$script:WkrRawUrl = 'https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1'
$script:WkrMainScriptName = 'Win-Key-Remover.ps1'
$script:LogPath = Join-Path $env:TEMP ("Win-Key-Remover-debug-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$script:Results = [System.Collections.Generic.List[object]]::new()
$script:FailCount = 0
$script:WarnCount = 0

function Get-DebugStrings {
    if ($WkrUiLanguage -eq 'en') {
        return @{
            Title       = '========== Win-Key-Remover DEBUG =========='
            SubTitle    = 'Diagnostic only  - keys are NOT removed.'
            LogFile     = 'Log file: {0}'
            Summary     = 'Summary: {0} OK | {1} WARN | {2} FAIL'
            Done        = 'See READY block below when there are no FAIL items.'
            AdminWarn   = 'Not elevated - required only for Win-Key-Remover.ps1 (right-click PowerShell -> Run as administrator)'
            ReadyTitle  = 'READY: Machine passed debug. Run the MAIN script next.'
            ReadyCmd    = '  Run-Win-Key-Remover.cmd   OR   cd to script folder then:  .\Win-Key-Remover.ps1'
            ReadyNoOffice = 'Office not found (WARN is OK). In the menu choose 1 = Windows only. Do NOT choose 2 or 3.'
            ReadyCd     = 'Current folder is not the script folder. Before .\Win-Key-Remover.ps1 run:  cd "{0}"'
            SectionEnv  = '--- Environment ---'
            SectionPaths = '--- Paths & tools ---'
            SectionScript = '--- Script & launch ---'
            SectionOffice = '--- Office (ospp.vbs) ---'
            SectionNet  = '--- Network (optional) ---'
            StatusOk    = 'OK'
            StatusWarn  = 'WARN'
            StatusFail  = 'FAIL'
        }
    }
    return @{
        Title       = '========== Win-Key-Remover DEBUG =========='
        SubTitle    = 'Chi chan doan  - KHONG go key.'
        LogFile     = 'File log: {0}'
        Summary     = 'Tong ket: {0} OK | {1} WARN | {2} FAIL'
            Done        = 'Xem khoi READY ben duoi neu khong co muc FAIL.'
            AdminWarn   = 'Chua chay quyen Admin - chi can khi chay Win-Key-Remover.ps1 (chuot phai PowerShell -> Run as administrator)'
            ReadyTitle  = 'SAN SANG: May da qua debug. Hay chay SCRIPT CHINH.'
            ReadyCmd    = '  Run-Win-Key-Remover.cmd   HOAC   cd thu muc script roi:  .\Win-Key-Remover.ps1'
            ReadyNoOffice = 'Khong co Office (WARN la binh thuong). Trong menu chon 1 = chi Windows. KHONG chon 2 hoac 3.'
            ReadyCd     = 'Thu muc hien tai khac thu muc script. Truoc khi go .\Win-Key-Remover.ps1 hay chay:  cd "{0}"'
        SectionEnv  = '--- Moi truong ---'
        SectionPaths = '--- Duong dan & cong cu ---'
        SectionScript = '--- Script & khoi chay ---'
        SectionOffice = '--- Office (ospp.vbs) ---'
        SectionNet  = '--- Mang (tuy chon) ---'
        StatusOk    = 'OK'
        StatusWarn  = 'WARN'
        StatusFail  = 'FAIL'
    }
}

function Write-DebugLog {
    param([string]$Line)
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $script:LogPath -Value "[$ts] $Line" -Encoding UTF8
}

function Add-DebugResult {
    param(
        [string]$Category,
        [string]$Name,
        [ValidateSet('OK', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Detail
    )
    $o = [PSCustomObject]@{
        Category = $Category
        Name     = $Name
        Status   = $Status
        Detail   = $Detail
    }
    $script:Results.Add($o)
    if ($Status -eq 'FAIL') { $script:FailCount++ }
    elseif ($Status -eq 'WARN') { $script:WarnCount++ }
    $line = "[$Status] $Category | $Name | $Detail"
    Write-DebugLog $line
}

function Write-DebugSection {
    param([string]$Title)
    Write-Host ''
    Write-Host $Title -ForegroundColor Cyan
    Write-DebugLog $Title
}

function Show-DebugResults {
    param([string]$CategoryFilter)
    $rows = $script:Results | Where-Object { $_.Category -eq $CategoryFilter }
    foreach ($r in $rows) {
        $color = switch ($r.Status) {
            'OK'   { 'Green' }
            'WARN' { 'Yellow' }
            'FAIL' { 'Red' }
        }
        Write-Host ("  [{0}] {1}" -f $r.Status, $r.Name) -ForegroundColor $color
        if ($r.Detail) { Write-Host "       $($r.Detail)" -ForegroundColor DarkGray }
    }
}

function Test-WkrIsAdministrator {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch { return $false }
}

function Get-WkrWindowsPowerShellExe {
    $ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path -LiteralPath $ps51) { return $ps51 }
    return $null
}

function Find-OsppPathDebug {
    $roots = @(
        "${env:ProgramFiles}\Microsoft Office\Office16",
        "${env:ProgramFiles}\Microsoft Office\Office15"
    )
    if (${env:ProgramFiles(x86)}) {
        $roots += @(
            "${env:ProgramFiles(x86)}\Microsoft Office\Office16",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office15"
        )
    }
    foreach ($r in $roots) {
        if (-not $r) { continue }
        $p = Join-Path $r 'ospp.vbs'
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

# --- Start ---
$T = Get-DebugStrings
"" | Out-File -LiteralPath $script:LogPath -Encoding UTF8
Write-DebugLog $T.Title
Write-Host $T.Title -ForegroundColor Cyan
Write-Host $T.SubTitle -ForegroundColor Yellow
Write-Host ($T.LogFile -f $script:LogPath) -ForegroundColor DarkGray

# Environment
Write-DebugSection $T.SectionEnv

$isAdmin = Test-WkrIsAdministrator
Add-DebugResult -Category 'Env' -Name 'Administrator (for main script)' -Status $(if ($isAdmin) { 'OK' } else { 'WARN' }) -Detail $(if ($isAdmin) { 'Running elevated' } else { $T.AdminWarn })

$os = [Environment]::OSVersion.VersionString
Add-DebugResult -Category 'Env' -Name 'OS' -Status 'OK' -Detail $os

$psVer = "$($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"
$psStatus = if ($PSVersionTable.PSEdition -eq 'Core') { 'WARN' } else { 'OK' }
Add-DebugResult -Category 'Env' -Name 'PowerShell version' -Status $psStatus -Detail $(if ($psStatus -eq 'WARN') { "$psVer  - script will re-launch Windows PowerShell 5.1" } else { $psVer })

try {
    $pol = Get-ExecutionPolicy -List | ForEach-Object { "$($_.Scope)=$($_.ExecutionPolicy)" }
    Add-DebugResult -Category 'Env' -Name 'ExecutionPolicy' -Status 'OK' -Detail ($pol -join '; ')
}
catch {
    Add-DebugResult -Category 'Env' -Name 'ExecutionPolicy' -Status 'WARN' -Detail $_.Exception.Message
}

$langVar = Get-Variable -Name Lang -Scope Global -ErrorAction SilentlyContinue
if ($langVar) {
    Add-DebugResult -Category 'Env' -Name 'Session $Lang variable' -Status 'WARN' -Detail "Value='$($langVar.Value)'  - old irm|iex builds failed here; current script uses WkrUiLanguage"
}
else {
    Add-DebugResult -Category 'Env' -Name 'Session $Lang variable' -Status 'OK' -Detail 'Not set (good)'
}

Show-DebugResults -CategoryFilter 'Env'

# Paths & tools
Write-DebugSection $T.SectionPaths

$ps51 = Get-WkrWindowsPowerShellExe
Add-DebugResult -Category 'Paths' -Name 'Windows PowerShell 5.1' -Status $(if ($ps51) { 'OK' } else { 'FAIL' }) -Detail $(if ($ps51) { $ps51 } else { 'Not found under System32' })

$cscript = Join-Path $env:SystemRoot 'System32\cscript.exe'
Add-DebugResult -Category 'Paths' -Name 'cscript.exe' -Status $(if (Test-Path -LiteralPath $cscript) { 'OK' } else { 'FAIL' }) -Detail $cscript

$slmgr = Join-Path $env:SystemRoot 'System32\slmgr.vbs'
Add-DebugResult -Category 'Paths' -Name 'slmgr.vbs' -Status $(if (Test-Path -LiteralPath $slmgr) { 'OK' } else { 'FAIL' }) -Detail $slmgr

if ($isAdmin -and (Test-Path -LiteralPath $slmgr) -and (Test-Path -LiteralPath $cscript)) {
    try {
        $out = & $cscript //Nologo $slmgr /dli 2>&1 | Out-String
        $preview = ($out.Trim() -split "`n" | Select-Object -First 3) -join ' | '
        Add-DebugResult -Category 'Paths' -Name 'slmgr /dli (preview)' -Status 'OK' -Detail $preview
    }
    catch {
        Add-DebugResult -Category 'Paths' -Name 'slmgr /dli (preview)' -Status 'WARN' -Detail $_.Exception.Message
    }
}
elseif (-not $isAdmin) {
    Add-DebugResult -Category 'Paths' -Name 'slmgr /dli (preview)' -Status 'WARN' -Detail 'Skipped  - need Administrator'
}

Show-DebugResults -CategoryFilter 'Paths'

# Script & launch
Write-DebugSection $T.SectionScript

$invPath = $MyInvocation.MyCommand.Path
Add-DebugResult -Category 'Script' -Name 'PSScriptRoot' -Status $(if ($PSScriptRoot) { 'OK' } else { 'WARN' }) -Detail $(if ($PSScriptRoot) { $PSScriptRoot } else { 'Empty  - normal for irm|iex; main script re-downloads to TEMP' })

$mainLocal = if ($PSScriptRoot) { Join-Path $PSScriptRoot $script:WkrMainScriptName } else { $null }
if ($mainLocal -and (Test-Path -LiteralPath $mainLocal)) {
    Add-DebugResult -Category 'Script' -Name 'Win-Key-Remover.ps1 (local)' -Status 'OK' -Detail $mainLocal
    try {
        $parseErr = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($mainLocal, [ref]$null, [ref]$parseErr)
        if ($parseErr) {
            $parseDetail = ($parseErr | ForEach-Object { $_.ToString() }) -join ' | '
            Add-DebugResult -Category 'Script' -Name 'Parse Win-Key-Remover.ps1' -Status 'FAIL' -Detail $parseDetail
        }
        else {
            Add-DebugResult -Category 'Script' -Name 'Parse Win-Key-Remover.ps1' -Status 'OK' -Detail 'No syntax errors'
        }
    }
    catch {
        Add-DebugResult -Category 'Script' -Name 'Parse Win-Key-Remover.ps1' -Status 'WARN' -Detail $_.Exception.Message
    }
}
else {
    Add-DebugResult -Category 'Script' -Name 'Win-Key-Remover.ps1 (local)' -Status 'WARN' -Detail 'Not beside debug script  - use git clone or download'
}

Add-DebugResult -Category 'Script' -Name 'Debug script path' -Status 'OK' -Detail $invPath
$cwd = (Get-Location).Path
$locStatus = if ($PSScriptRoot -and $cwd -ne $PSScriptRoot) { 'WARN' } else { 'OK' }
Add-DebugResult -Category 'Script' -Name 'Current location' -Status $locStatus -Detail $(if ($locStatus -eq 'WARN') { "$cwd (use Run-Win-Key-Remover.cmd or cd to script folder)" } else { $cwd })

Show-DebugResults -CategoryFilter 'Script'

# Office
Write-DebugSection $T.SectionOffice

$ospp = Find-OsppPathDebug
if ($ospp) {
    Add-DebugResult -Category 'Office' -Name 'ospp.vbs' -Status 'OK' -Detail $ospp
    if ($isAdmin -and (Test-Path -LiteralPath $cscript)) {
        try {
            $tmp = [System.IO.Path]::GetTempFileName()
            & $cscript //Nologo $ospp /dstatus 2>&1 | Out-File -LiteralPath $tmp -Encoding UTF8
            $text = Get-Content -LiteralPath $tmp -Raw -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
            $keys = [regex]::Matches($text, '(?i)Last 5 characters of installed product key:\s*([A-Z0-9]{5})')
            Add-DebugResult -Category 'Office' -Name 'ospp /dstatus keys found' -Status 'OK' -Detail "Count=$($keys.Count)"
        }
        catch {
            Add-DebugResult -Category 'Office' -Name 'ospp /dstatus' -Status 'WARN' -Detail $_.Exception.Message
        }
    }
}
else {
    Add-DebugResult -Category 'Office' -Name 'ospp.vbs' -Status 'WARN' -Detail 'Not found - OK if you only remove Windows key (menu option 1)'
}

Show-DebugResults -CategoryFilter 'Office'

# Network
if ($DownloadTest) {
    Write-DebugSection $T.SectionNet
    $dest = Join-Path $env:TEMP 'Win-Key-Remover-debug-download.ps1'
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            Invoke-WebRequest -Uri $script:WkrRawUrl -OutFile $dest -UseBasicParsing
        }
        else {
            try {
                Invoke-WebRequest -Uri $script:WkrRawUrl -OutFile $dest -UseBasicParsing
            }
            catch {
                (New-Object System.Net.WebClient).DownloadFile($script:WkrRawUrl, $dest)
            }
        }
        if (Test-Path -LiteralPath $dest) {
            $len = (Get-Item -LiteralPath $dest).Length
            Add-DebugResult -Category 'Net' -Name 'Download raw GitHub' -Status 'OK' -Detail "$dest ($len bytes)"
        }
        else {
            Add-DebugResult -Category 'Net' -Name 'Download raw GitHub' -Status 'FAIL' -Detail 'File missing after download'
        }
    }
    catch {
        Add-DebugResult -Category 'Net' -Name 'Download raw GitHub' -Status 'FAIL' -Detail $_.Exception.Message
    }
    Show-DebugResults -CategoryFilter 'Net'
}

# Summary
$okCount = $script:Results.Count - $script:FailCount - $script:WarnCount
Write-Host ''
Write-Host ($T.Summary -f $okCount, $script:WarnCount, $script:FailCount) -ForegroundColor $(if ($script:FailCount -gt 0) { 'Red' } elseif ($script:WarnCount -gt 0) { 'Yellow' } else { 'Green' })
Write-Host $T.Done -ForegroundColor DarkGray

if ($script:FailCount -eq 0) {
    Write-Host ''
    Write-Host '========================================' -ForegroundColor Green
    Write-Host $T.ReadyTitle -ForegroundColor Green
    Write-Host $T.ReadyCmd -ForegroundColor White
    if (-not $ospp) {
        Write-Host $T.ReadyNoOffice -ForegroundColor Yellow
    }
    if ($PSScriptRoot -and $cwd -ne $PSScriptRoot) {
        Write-Host ($T.ReadyCd -f $PSScriptRoot) -ForegroundColor Yellow
    }
    Write-Host '========================================' -ForegroundColor Green
    Write-DebugLog $T.ReadyTitle
}

Write-DebugLog ($T.Summary -f $okCount, $script:WarnCount, $script:FailCount)

exit $(if ($script:FailCount -gt 0) { 1 } else { 0 })
