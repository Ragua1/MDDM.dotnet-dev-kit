<#
.SYNOPSIS
    Aplikuje šablony z MDDM.dotnet-dev-kit do cílového projektu.

.DESCRIPTION
    Načte manifest.yaml, projde soubory pro zvolený profil a v závislosti
    na režimu buď vypíše, co by se změnilo (Check), nebo soubory zkopíruje (Apply).

    Skript NIKDY nepřepíše existující soubor. Pokud soubor v projektu existuje,
    vypíše SKIP. Pokud neexistuje, vypíše CREATE (Check) nebo soubor vytvoří (Apply).

.PARAMETER ProjectPath
    Absolutní nebo relativní cesta k cílovému projektu.

.PARAMETER Profile
    Název profilu z manifest.yaml. Výchozí hodnota je 'dotnet-basic'.

.PARAMETER Mode
    'Check' – pouze vypíše, co by se změnilo (nic nemodifikuje).
    'Apply' – vytvoří chybějící adresáře a zkopíruje soubory.

.EXAMPLE
    .\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Mode Check
    .\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Mode Apply
    .\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Profile dotnet-basic -Mode Apply
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [Parameter(Mandatory = $false)]
    [string]$Profile = 'dotnet-basic',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Check', 'Apply')]
    [string]$Mode = 'Check'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Pomocná funkce pro parsování jednoduchého YAML ---
# Tato implementace podporuje pouze formát používaný v manifest.yaml tohoto projektu.
# Pro komplexnější YAML použij modul powershell-yaml (Install-Module powershell-yaml).
function Read-ManifestYaml {
    param([string]$Path)

    $content = Get-Content -Path $Path -Raw
    $lines   = $content -split "`n"

    $profiles   = @{}
    $currentProfile = $null
    $inFiles    = $false
    $currentSource = $null

    foreach ($rawLine in $lines) {
        $line = $rawLine.TrimEnd()

        # Profil – "  dotnet-basic:"
        if ($line -match '^\s{2}(\S+):$') {
            $currentProfile = $Matches[1]
            $profiles[$currentProfile] = @{
                description  = ''
                templateBase = ''
                files        = [System.Collections.Generic.List[hashtable]]::new()
            }
            $inFiles = $false
            continue
        }

        if ($null -eq $currentProfile) { continue }

        # description
        if ($line -match '^\s{4}description:\s+"?([^"]+)"?$') {
            $profiles[$currentProfile].description = $Matches[1].Trim('"')
            continue
        }

        # templateBase
        if ($line -match '^\s{4}templateBase:\s+"?([^"]+)"?$') {
            $profiles[$currentProfile].templateBase = $Matches[1].Trim('"')
            continue
        }

        # Sekce files:
        if ($line -match '^\s{4}files:') {
            $inFiles = $true
            continue
        }

        if (-not $inFiles) { continue }

        # - source: "..."
        if ($line -match '^\s{6}-\s+source:\s+"?([^"]+)"?$') {
            $currentSource = $Matches[1].Trim('"')
            continue
        }

        # target: "..."
        if ($line -match '^\s{8}target:\s+"?([^"]+)"?$' -and $null -ne $currentSource) {
            $profiles[$currentProfile].files.Add(@{
                source = $currentSource
                target = $Matches[1].Trim('"')
            })
            $currentSource = $null
            continue
        }
    }

    return $profiles
}

# --- Rozlišení cest ---
$scriptRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot      = Split-Path -Parent $scriptRoot
$manifestPath  = Join-Path $repoRoot 'manifest.yaml'
$ProjectPath   = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue)?.Path
if (-not $ProjectPath) {
    Write-Error "Cílová cesta '$ProjectPath' neexistuje."
    exit 1
}

# --- Načtení manifestu ---
if (-not (Test-Path $manifestPath)) {
    Write-Error "manifest.yaml nebyl nalezen na cestě: $manifestPath"
    exit 1
}

Write-Host ""
Write-Host "=== project-apply.ps1 ===" -ForegroundColor Cyan
Write-Host "Profil   : $Profile"
Write-Host "Projekt  : $ProjectPath"
Write-Host "Režim    : $Mode"
Write-Host ""

$manifest = Read-ManifestYaml -Path $manifestPath

if (-not $manifest.ContainsKey($Profile)) {
    Write-Error "Profil '$Profile' nebyl nalezen v manifest.yaml. Dostupné profily: $($manifest.Keys -join ', ')"
    exit 1
}

$profileData = $manifest[$Profile]
$templateBase = Join-Path $repoRoot $profileData.templateBase

if (-not (Test-Path $templateBase)) {
    Write-Error "Složka šablon '$templateBase' neexistuje."
    exit 1
}

# --- Zpracování souborů ---
$created = 0
$skipped = 0

foreach ($file in $profileData.files) {
    $sourcePath = Join-Path $templateBase $file.source
    $targetPath = Join-Path $ProjectPath  $file.target

    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Zdrojový soubor nenalezen, přeskakuji: $sourcePath"
        continue
    }

    if (Test-Path $targetPath) {
        Write-Host "  SKIP   $($file.target)" -ForegroundColor DarkGray
        $skipped++
    } else {
        Write-Host "  CREATE $($file.target)" -ForegroundColor Yellow
        $created++

        if ($Mode -eq 'Apply') {
            $targetDir = Split-Path -Parent $targetPath
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            Copy-Item -Path $sourcePath -Destination $targetPath
        }
    }
}

# --- Souhrn ---
Write-Host ""
if ($Mode -eq 'Check') {
    Write-Host "Check dokončen. K vytvoření: $created soubor(ů), přeskočeno: $skipped soubor(ů)." -ForegroundColor Cyan
    Write-Host "Spusť se -Mode Apply pro aplikaci změn."
} else {
    Write-Host "Apply dokončen. Vytvořeno: $created soubor(ů), přeskočeno: $skipped soubor(ů)." -ForegroundColor Green
}
Write-Host ""
