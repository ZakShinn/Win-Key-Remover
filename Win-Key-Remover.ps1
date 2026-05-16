#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Remove Windows/Office keys via slmgr.vbs and ospp.vbs (Microsoft tools).
.PARAMETER Lang
  vi | en. If omitted, you are prompted at startup.
.EXAMPLE
  .\Win-Key-Remover.ps1
.EXAMPLE
  .\Win-Key-Remover.ps1 -Lang en
.NOTES
  Run: .\Win-Key-Remover.ps1  or  .\Win-Key-Remover.ps1 -Lang en
  irm | iex: opens a child powershell.exe -File (Admin required).
  Recommended: Windows PowerShell 5.1 (powershell.exe), Administrator.
#>

$ErrorActionPreference = 'Stop'

$script:WkrRawUrl = 'https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1'

# Legacy names from older builds (param + ValidateSet) break irm | iex if touched in this session
foreach ($legacyScope in @('Global', 'Script', 'Local')) {
    foreach ($legacyName in @('WkrUiLanguage', 'Lang')) {
        Remove-Variable -Name $legacyName -Scope $legacyScope -ErrorAction SilentlyContinue
    }
}

# irm | iex: run FIRST — before any other script logic or culture variables
if (-not $PSScriptRoot) {
    $dest = Join-Path $env:TEMP 'Win-Key-Remover.ps1'
    try {
        (New-Object System.Net.WebClient).DownloadFile($script:WkrRawUrl, $dest)
    }
    catch {
        Write-Host "Download failed / Loi tai file: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    $ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if (-not (Test-Path -LiteralPath $ps51)) { $ps51 = 'powershell.exe' }
    & $ps51 -NoProfile -ExecutionPolicy Bypass -File $dest -WkrSkipUpdate
    exit $LASTEXITCODE
}

$RemoteScriptUrl = $script:WkrRawUrl

function Get-WkrWindowsPowerShellExe {
    $ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path -LiteralPath $ps51) { return $ps51 }
    return 'powershell.exe'
}

function Test-WkrIsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-WkrWebDownload {
    param(
        [Parameter(Mandatory)]
        [string]$Uri,
        [Parameter(Mandatory)]
        [string]$Destination
    )
    $dir = Split-Path -Parent $Destination
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Invoke-WebRequest -Uri $Uri -OutFile $Destination -UseBasicParsing
        return
    }
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $Destination -UseBasicParsing
    }
    catch {
        (New-Object System.Net.WebClient).DownloadFile($Uri, $Destination)
    }
}

function Start-WkrInWindowsPowerShell {
    param(
        [string]$ScriptPath,
        [string]$LangArg,
        [switch]$SkipRemoteUpdate
    )
    $psExe = Get-WkrWindowsPowerShellExe
    $psArgs = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $ScriptPath
    )
    if ($LangArg) {
        $psArgs += '-Lang'
        $psArgs += $LangArg
    }
    if ($SkipRemoteUpdate) {
        $psArgs += '-WkrSkipUpdate'
    }
    & $psExe @psArgs
    exit $LASTEXITCODE
}

function Test-WkrCliSwitchPresent {
    param([Parameter(Mandatory)][string]$Name)
    foreach ($a in $args) {
        if ([string]$a -eq $Name) { return $true }
    }
    return $false
}

function Get-WkrCliLanguageFromArgs {
    for ($i = 0; $i -lt $args.Count; $i++) {
        $token = [string]$args[$i]
        if ($token -in @('-Lang', '/Lang') -and ($i + 1) -lt $args.Count) {
            return [string]$args[$i + 1]
        }
    }
    return $null
}

function Test-WkrShouldSkipRemoteUpdatePrompt {
    if (Test-WkrCliSwitchPresent -Name '-WkrSkipUpdate') { return $true }
    if ($env:WKR_SKIP_REMOTE_UPDATE -eq '1') { return $true }

    $path = $PSCommandPath
    if (-not $path) { $path = $MyInvocation.PSCommandPath }
    if (-not $path) { return $false }

    $fileName = [System.IO.Path]::GetFileName($path)
    if ($fileName -notmatch '^Win-Key-Remover(-downloaded)?\.ps1$') { return $false }

    $dir = [System.IO.Path]::GetDirectoryName($path)
    $tempRoot = [System.IO.Path]::GetTempPath().TrimEnd('\', '/')
    if ($dir.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }
    return $false
}

function Test-WkrScriptSyntax {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try {
        $parseErr = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$parseErr)
        return (-not $parseErr -or $parseErr.Count -eq 0)
    }
    catch {
        return $false
    }
}

if (-not (Test-WkrIsAdministrator)) {
    Write-Host 'Run PowerShell as Administrator / Can chay PowerShell (Admin).' -ForegroundColor Red
    exit 1
}

if ($PSScriptRoot) {
    Set-Location -LiteralPath $PSScriptRoot
}

function Get-Strings {
    param([string]$Culture)
    if ($Culture -eq 'en') {
        return @{
            DisclaimerTitle = '========== WARNING / DISCLAIMER =========='
            DisclaimerLines = @(
                'You accept all risks when running this script.'
                '- Windows or Office may become NOT ACTIVATED.'
                '- Not every Windows edition has a trial after the key is removed.'
                '- Office trial only applies if you originally installed a valid trial build.'
                '- This script does not remove cracks via patched files, hosts, or fake services.'
                '- Administrator rights are required.'
            )
            DisclaimerEnd   = '=========================================='
            ChooseLang      = 'Choose language / Chon ngon ngu: 1 = Vietnamese (tieng Viet)  2 = English'
            InvalidLang     = 'Invalid choice.'
            ChooseMode      = 'Choose an option:'
            Mode1           = '  1 - Windows only (slmgr /upk, /cpky, /ckms)'
            Mode2           = '  2 - Office only (ospp.vbs /unpkey from /dstatus)'
            Mode3           = '  3 - Both Windows and Office'
            EnterMode       = 'Enter 1, 2, or 3'
            InvalidMode     = 'Invalid choice.'
            WinProgress     = '[Windows] Uninstalling product key and clearing the registry copy...'
            WinNotFound     = 'slmgr.vbs not found at {0}'
            WinDone         = '[Windows] Done (check Activation in Settings).'
            OfficeNoOspp    = '[Office] ospp.vbs not found (Office may be missing or in an unusual path).'
            OfficeUsing     = '[Office] Using: {0}'
            OfficeBadOut    = '[Office] Could not read /dstatus output.'
            OfficeNoKeys    = "[Office] No keys found in /dstatus. Output:`n{0}"
            OfficeRemove    = '[Office] Removing key (last 5): {0}'
            OfficeDone      = '[Office] Done. Verify with: cscript //Nologo "{0}" /dstatus'
            RemoteNotCfg    = 'Remote URL is still a placeholder. Edit $RemoteScriptUrl in this script, or press Enter to run local copy.'
            PromptUpdate    = 'Download latest script from GitHub before continuing? [y/N]'
            Downloading     = 'Downloading: {0}'
            DownloadFail    = 'Download failed: {0}'
            DownloadNoFile  = 'Download did not produce a file.'
            SavedRun        = 'Saved: {0} - continuing with downloaded copy...'
            UpdateBadSyntax = 'Downloaded script has syntax errors (GitHub may be outdated). Continuing with THIS copy.'
            UpdateUseLocal  = 'Using local script: {0}'
            UpdateSkipped   = 'Skipping update prompt (already running a copy just downloaded from GitHub).'
            PsHostNote      = '[Info] Using: {0} (PS {1})'
        }
    }
    return @{
        DisclaimerTitle = '========== CANH BAO / LUU Y =========='
        DisclaimerLines = @(
            'Ban tu chiu trach nhiem moi rui ro khi chay script nay.'
            '- Co the lam Windows hoac Office chuyen sang trang thai CHUA KICH HOAT.'
            '- Khong phai moi phien ban Windows deu co trial sau khi go key.'
            '- Office trial chi hop ly neu ban dang dung goi cai dat trial hop le.'
            '- Script khong go bo crack bang file patch, hosts, hay dich vu la.'
            '- Can chay PowerShell voi quyen Administrator.'
        )
        DisclaimerEnd   = '========================================'
        ChooseLang      = 'Chon ngon ngu / Choose language: 1 = Tieng Viet  2 = English'
        InvalidLang     = 'Lua chon khong hop le.'
        ChooseMode      = 'Chon che do:'
        Mode1           = '  1 - Chi Windows (slmgr /upk, /cpky, /ckms)'
        Mode2           = '  2 - Chi Office (ospp.vbs /unpkey theo /dstatus)'
        Mode3           = '  3 - Ca Windows va Office'
        EnterMode       = 'Nhap 1, 2 hoac 3'
        InvalidMode     = 'Lua chon khong hop le.'
        WinProgress     = '[Windows] Dang go product key va xoa ban sao trong registry...'
        WinNotFound     = 'Khong tim thay slmgr.vbs tai {0}'
        WinDone         = '[Windows] Hoan tat (kiem tra Activation trong Settings).'
        OfficeNoOspp    = '[Office] Khong tim thay ospp.vbs (co the chua cai Office hoac duong dan khac).'
        OfficeUsing     = '[Office] Su dung: {0}'
        OfficeBadOut    = '[Office] Khong doc duoc ket qua /dstatus.'
        OfficeNoKeys    = "[Office] Khong tim thay key trong /dstatus. Noi dung:`n{0}"
        OfficeRemove    = '[Office] Go key (5 ky tu cuoi): {0}'
        OfficeDone      = '[Office] Hoan tat. Kiem tra: cscript //Nologo "{0}" /dstatus'
        RemoteNotCfg    = 'URL remote van la placeholder. Sua $RemoteScriptUrl trong script, hoac nhan Enter de chay ban cuc bo.'
        PromptUpdate    = 'Tai phien ban moi tu GitHub truoc khi tiep tuc? [y/N]'
        Downloading     = 'Dang tai: {0}'
        DownloadFail    = 'Loi tai file: {0}'
        DownloadNoFile  = 'Tai file that bai.'
        SavedRun        = 'Da luu: {0} - tiep tuc voi ban da tai...'
        UpdateBadSyntax = 'Ban tai ve loi cu phap (GitHub co the chua cap nhat). Tiep tuc voi ban DANG CHAY.'
        UpdateUseLocal  = 'Dung ban cuc bo: {0}'
        UpdateSkipped   = 'Bo qua hoi tai ban moi (dang chay ban vua tai tu GitHub).'
        PsHostNote      = '[Info] Dang dung: {0} (PS {1})'
    }
}

function Invoke-WkrCscript {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )
    $cscript = Join-Path $env:SystemRoot 'System32\cscript.exe'
    if (-not (Test-Path -LiteralPath $cscript)) {
        throw "cscript.exe not found at $cscript"
    }
    $allArgs = @('//Nologo', $ScriptPath) + $Arguments
    & $cscript @allArgs 2>&1 | Out-Host
}

function Invoke-OptionalRemoteUpdate {
    param([hashtable]$S)

    if ($RemoteScriptUrl -match 'YOUR_USER|YOUR_REPO') {
        Write-Host $S.RemoteNotCfg -ForegroundColor DarkYellow
        return
    }

    if (Test-WkrShouldSkipRemoteUpdatePrompt) {
        Write-Host $S.UpdateSkipped -ForegroundColor DarkGray
        return
    }

    Write-Host $S.PromptUpdate -ForegroundColor White
    $yn = Read-Host
    if ($yn -notmatch '^(y|yes)$') { return }

    $out = Join-Path $env:TEMP 'Win-Key-Remover-downloaded.ps1'
    Write-Host ($S.Downloading -f $RemoteScriptUrl) -ForegroundColor Cyan
    try {
        Invoke-WkrWebDownload -Uri $RemoteScriptUrl -Destination $out
    }
    catch {
        Write-Host ($S.DownloadFail -f $_.Exception.Message) -ForegroundColor Red
        return
    }

    if (-not (Test-Path -LiteralPath $out)) {
        Write-Host $S.DownloadNoFile -ForegroundColor Red
        return
    }

    if (-not (Test-WkrScriptSyntax -Path $out)) {
        Write-Host $S.UpdateBadSyntax -ForegroundColor Red
        Remove-Item -LiteralPath $out -Force -ErrorAction SilentlyContinue
        $localMain = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'Win-Key-Remover.ps1' } else { $MyInvocation.MyCommand.Path }
        if ($localMain -and (Test-Path -LiteralPath $localMain)) {
            Write-Host ($S.UpdateUseLocal -f $localMain) -ForegroundColor Yellow
        }
        return
    }

    Write-Host ($S.SavedRun -f $out) -ForegroundColor Green
    Start-WkrInWindowsPowerShell -ScriptPath $out -LangArg $script:WkrCulture -SkipRemoteUpdate
}

function Show-Disclaimer {
    param([hashtable]$S)
    Write-Host ''
    Write-Host $S.DisclaimerTitle -ForegroundColor Yellow
    foreach ($line in $S.DisclaimerLines) { Write-Host $line }
    Write-Host $S.DisclaimerEnd -ForegroundColor Yellow
    Write-Host ''
}

function Clear-WindowsKey {
    param([hashtable]$S)

    Write-Host $S.WinProgress -ForegroundColor Cyan
    $slmgr = Join-Path $env:SystemRoot 'System32\slmgr.vbs'
    if (-not (Test-Path -LiteralPath $slmgr)) {
        throw ($S.WinNotFound -f $slmgr)
    }

    Invoke-WkrCscript -ScriptPath $slmgr -Arguments @('/upk')
    Invoke-WkrCscript -ScriptPath $slmgr -Arguments @('/cpky')
    Invoke-WkrCscript -ScriptPath $slmgr -Arguments @('/ckms')

    Write-Host $S.WinDone -ForegroundColor Green
}

function Find-OsppPath {
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
    $searchRoots = @($env:ProgramFiles)
    if (${env:ProgramFiles(x86)}) { $searchRoots += ${env:ProgramFiles(x86)} }
    foreach ($root in $searchRoots) {
        if (-not $root -or -not (Test-Path -LiteralPath $root)) { continue }
        $found = Get-ChildItem -LiteralPath $root -Filter 'ospp.vbs' -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
        if ($found) { return $found }
    }
    return $null
}

function Clear-OfficeKeys {
    param([hashtable]$S)

    $ospp = Find-OsppPath
    if (-not $ospp) {
        Write-Host $S.OfficeNoOspp -ForegroundColor Red
        return
    }
    Write-Host ($S.OfficeUsing -f $ospp) -ForegroundColor Cyan

    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        $cscript = Join-Path $env:SystemRoot 'System32\cscript.exe'
        & $cscript //Nologo $ospp /dstatus 2>&1 | Out-File -LiteralPath $tmp -Encoding UTF8
        $text = Get-Content -LiteralPath $tmp -Raw -ErrorAction SilentlyContinue
        if (-not $text) {
            Write-Host $S.OfficeBadOut -ForegroundColor Red
            return
        }
        $patternMatches = [regex]::Matches($text, '(?i)Last 5 characters of installed product key:\s*([A-Z0-9]{5})')
        if ($patternMatches.Count -eq 0) {
            Write-Host ($S.OfficeNoKeys -f $text) -ForegroundColor Yellow
            return
        }
        $seen = @{}
        foreach ($m in $patternMatches) {
            $last5 = $m.Groups[1].Value
            if (-not $seen.ContainsKey($last5)) {
                $seen[$last5] = $true
                Write-Host ($S.OfficeRemove -f $last5) -ForegroundColor Cyan
                Invoke-WkrCscript -ScriptPath $ospp -Arguments @("/unpkey:$last5")
            }
        }
        Write-Host ($S.OfficeDone -f $ospp) -ForegroundColor Green
    }
    finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

# PowerShell 7+: re-launch in Windows PowerShell 5.1 (slmgr/ospp work best on 5.1)
if ($PSVersionTable.PSEdition -eq 'Core') {
    $self = $MyInvocation.MyCommand.Path
    if ($self -and (Test-Path -LiteralPath $self)) {
        Start-WkrInWindowsPowerShell -ScriptPath $self -LangArg (Get-WkrCliLanguageFromArgs)
    }
}

# --- Resolve language (no param block: safe for irm | iex) ---
$langFromCli = Get-WkrCliLanguageFromArgs
if ($langFromCli) {
    if ($langFromCli -notin @('vi', 'en')) {
        Write-Host "Invalid -Lang '$langFromCli'. Use vi or en. / -Lang khong hop le." -ForegroundColor Red
        exit 1
    }
    $script:WkrCulture = $langFromCli
}

if (-not $script:WkrCulture) {
    Write-Host (Get-Strings -Culture 'vi').ChooseLang -ForegroundColor White
    $lc = Read-Host '1 / 2'
    switch ($lc) {
        '1' { $script:WkrCulture = 'vi' }
        '2' { $script:WkrCulture = 'en' }
        default {
            Write-Host 'Invalid choice / Lua chon khong hop le.' -ForegroundColor Red
            exit 1
        }
    }
}

$S = Get-Strings -Culture $script:WkrCulture
$psExe = Get-WkrWindowsPowerShellExe
Write-Host ($S.PsHostNote -f $psExe, $PSVersionTable.PSVersion) -ForegroundColor DarkGray

Invoke-OptionalRemoteUpdate -S $S

Show-Disclaimer -S $S

Write-Host $S.ChooseMode -ForegroundColor White
Write-Host $S.Mode1
Write-Host $S.Mode2
Write-Host $S.Mode3
$choice = Read-Host $S.EnterMode

switch ($choice) {
    '1' { Clear-WindowsKey -S $S }
    '2' { Clear-OfficeKeys -S $S }
    '3' { Clear-WindowsKey -S $S; Clear-OfficeKeys -S $S }
    default {
        Write-Host $S.InvalidMode -ForegroundColor Red
        exit 1
    }
}

Write-Host ''
Write-Host 'Finished / Hoan tat. Check Activation in Settings / Kiem tra Kich hoat trong Cai dat.' -ForegroundColor Green
if ($Host.Name -eq 'ConsoleHost') {
    Read-Host 'Press Enter to close / Nhan Enter de dong'
}
