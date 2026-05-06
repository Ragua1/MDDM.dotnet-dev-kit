<#
.SYNOPSIS
    Vytvoří nový .NET projekt a aplikuje projektové šablony z MDDM.dotnet-dev-kit.

.DESCRIPTION
    Vytvoří složku projektu, inicializuje prázdnou .NET solution a zavolá
    project-apply.ps1 pro aplikaci standardních šablon.

.PARAMETER Name
    Název nového projektu (použije se jako název složky i solution).

.PARAMETER OutputPath
    Nadřazená složka, ve které bude projekt vytvořen.

.PARAMETER Profile
    Profil pro project-apply.ps1. Výchozí hodnota je 'dotnet-basic'.

.EXAMPLE
    .\project-new.ps1 -Name "MyApp" -OutputPath "C:\Projects"
    .\project-new.ps1 -Name "MyApp" -OutputPath "C:\Projects" -Profile dotnet-basic
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [string]$Profile = 'dotnet-basic'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== project-new.ps1 ===" -ForegroundColor Cyan
Write-Host "Název    : $Name"
Write-Host "Výstup   : $OutputPath"
Write-Host "Profil   : $Profile"
Write-Host ""

# --- Ověření výstupní cesty ---
if (-not (Test-Path $OutputPath)) {
    Write-Error "Výstupní cesta '$OutputPath' neexistuje. Vytvoř ji nejdříve ručně."
    exit 1
}

$projectPath = Join-Path $OutputPath $Name

if (Test-Path $projectPath) {
    Write-Error "Složka '$projectPath' již existuje. Zvol jiný název nebo cestu."
    exit 1
}

# --- Vytvoření složky ---
Write-Host "Vytvářím složku projektu: $projectPath"
New-Item -ItemType Directory -Path $projectPath | Out-Null

# --- Inicializace solution ---
Write-Host "Inicializuji .NET solution: $Name.sln"
Push-Location $projectPath
try {
    dotnet new sln --name $Name
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Příkaz 'dotnet new sln' selhal (exit code $LASTEXITCODE)."
        exit 1
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "Solution vytvořena." -ForegroundColor Green
Write-Host ""

# --- Aplikace šablon ---
$applyScript = Join-Path $PSScriptRoot 'project-apply.ps1'

if (-not (Test-Path $applyScript)) {
    Write-Warning "project-apply.ps1 nenalezen na cestě: $applyScript. Šablony nebyly aplikovány."
    exit 0
}

Write-Host "Aplikuji šablony (profil: $Profile)..." -ForegroundColor Cyan
& $applyScript -ProjectPath $projectPath -Profile $Profile -Mode Apply

Write-Host ""
Write-Host "Hotovo! Projekt '$Name' byl vytvořen v: $projectPath" -ForegroundColor Green
Write-Host ""
Write-Host "Další kroky:"
Write-Host "  1. Uprav global.json – zkontroluj verzi .NET SDK"
Write-Host "  2. Přidej projekty do solution: dotnet new <template> --name <name>"
Write-Host "  3. Vygeneruj AI instrukce: .\scripts\generate-ai-instructions.ps1 -ProjectPath '$projectPath'"
Write-Host ""
