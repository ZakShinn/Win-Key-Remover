#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Remove Windows/Office keys via slmgr.vbs and ospp.vbs (Microsoft tools).
.DESCRIPTION
  Language: Vietnamese or English. Menu: Windows only, Office only, or both.
  Optional: download latest copy from a GitHub RAW URL you set, then continue.
.PARAMETER Lang
  vi | en. If omitted, you are prompted at startup.
.EXAMPLE
  .\Win-Key-Remover.ps1
.EXAMPLE
  .\Win-Key-Remover.ps1 -Lang en
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('vi', 'en')]
    [string]$Lang
)

$ErrorActionPreference = 'Stop'

# === Optional: set to your GitHub RAW URL for this same script; leave placeholder to skip download prompt ===
$RemoteScriptUrl = 'https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/Win-Key-Remover.ps1'

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
            SavedRun        = 'Saved: {0} — continuing with downloaded copy...'
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
        SavedRun        = 'Da luu: {0} — tiep tuc voi ban da tai...'
    }
}

function Invoke-OptionalRemoteUpdate {
    param([hashtable]$S)

    if ($RemoteScriptUrl -match 'YOUR_USER|YOUR_REPO') {
        Write-Host $S.RemoteNotCfg -ForegroundColor DarkYellow
        return
    }

    Write-Host $S.PromptUpdate -ForegroundColor White
    $yn = Read-Host
    if ($yn -notmatch '^(y|yes)$') { return }

    $out = Join-Path $env:TEMP 'Win-Key-Remover-downloaded.ps1'
    Write-Host ($S.Downloading -f $RemoteScriptUrl) -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $RemoteScriptUrl -OutFile $out -UseBasicParsing
    }
    catch {
        Write-Host ($S.DownloadFail -f $_.Exception.Message) -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path -LiteralPath $out)) {
        Write-Host $S.DownloadNoFile -ForegroundColor Red
        exit 1
    }

    Write-Host ($S.SavedRun -f $out) -ForegroundColor Green
    if ($Lang) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $out -Lang $Lang
    }
    else {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $out
    }
    exit $LASTEXITCODE
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

    cscript //Nologo $slmgr /upk  | Out-Host
    cscript //Nologo $slmgr /cpky | Out-Host
    cscript //Nologo $slmgr /ckms | Out-Host

    Write-Host $S.WinDone -ForegroundColor Green
}

function Find-OsppPath {
    $roots = @(
        "${env:ProgramFiles}\Microsoft Office\Office16",
        "${env:ProgramFiles(x86)}\Microsoft Office\Office16",
        "${env:ProgramFiles}\Microsoft Office\Office15",
        "${env:ProgramFiles(x86)}\Microsoft Office\Office15"
    )
    foreach ($r in $roots) {
        $p = Join-Path $r 'ospp.vbs'
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $found = Get-ChildItem -Path "${env:ProgramFiles}", "${env:ProgramFiles(x86)}" -Filter 'ospp.vbs' -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    return $found
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
        cscript //Nologo $ospp /dstatus > $tmp 2>&1
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
        $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($m in $patternMatches) {
            $last5 = $m.Groups[1].Value
            if ($seen.Add($last5)) {
                Write-Host ($S.OfficeRemove -f $last5) -ForegroundColor Cyan
                cscript //Nologo $ospp /unpkey:$last5 | Out-Host
            }
        }
        Write-Host ($S.OfficeDone -f $ospp) -ForegroundColor Green
    }
    finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

# --- Resolve language ---
if (-not $Lang) {
    Write-Host (Get-Strings -Culture 'vi').ChooseLang -ForegroundColor White
    $lc = Read-Host '1 / 2'
    switch ($lc) {
        '1' { $Lang = 'vi' }
        '2' { $Lang = 'en' }
        default {
            Write-Host 'Invalid choice / Lua chon khong hop le.' -ForegroundColor Red
            exit 1
        }
    }
}

$S = Get-Strings -Culture $Lang

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
