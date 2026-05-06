<#
.SYNOPSIS
    Ověří, že prostředí je připraveno pro použití MDDM.dotnet-dev-kit.

.DESCRIPTION
    Zkontroluje dostupnost požadovaných nástrojů (git, dotnet) a vypíše
    doporučené další kroky. Zatím neinstaluje žádný software.

.EXAMPLE
    .\bootstrap.ps1
#>

#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "=== MDDM.dotnet-dev-kit – Bootstrap ===" -ForegroundColor Cyan
Write-Host ""

# --- Ověření PowerShell verze ---
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell verze: $($psVersion.ToString())" -ForegroundColor Gray

if ($psVersion.Major -lt 5) {
    Write-Warning "Doporučená verze je PowerShell 5.1 nebo novější. Aktuální verze může způsobit problémy."
} else {
    Write-Host "  [OK] PowerShell $($psVersion.Major).$($psVersion.Minor)" -ForegroundColor Green
}

# --- Ověření dostupnosti nástrojů ---
$tools = @(
    @{ Name = 'git';    Description = 'Git (verzovací systém)' },
    @{ Name = 'dotnet'; Description = '.NET SDK' }
)

$allOk = $true

foreach ($tool in $tools) {
    $cmd = Get-Command $tool.Name -ErrorAction SilentlyContinue
    if ($cmd) {
        $version = & $tool.Name --version 2>&1 | Select-Object -First 1
        Write-Host "  [OK] $($tool.Description): $version" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $($tool.Description) – příkaz '$($tool.Name)' nebyl nalezen." -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""

# --- Výsledek ---
if ($allOk) {
    Write-Host "Prostředí je připraveno." -ForegroundColor Green
} else {
    Write-Host "Některé nástroje chybí. Nainstaluj je a spusť bootstrap znovu." -ForegroundColor Yellow
}

# --- Doporučené další kroky ---
Write-Host ""
Write-Host "Doporučené další kroky:" -ForegroundColor Cyan
Write-Host "  1. Zkontroluj verzi .NET SDK v templates/project-common/global.json"
Write-Host "     a uprav ji na verzi instalovanou na tomto zařízení."
Write-Host ""
Write-Host "  2. Pro aplikaci šablon do existujícího projektu:"
Write-Host "     .\scripts\project-apply.ps1 -ProjectPath <cesta-k-projektu> -Mode Check"
Write-Host ""
Write-Host "  3. Pro vytvoření nového projektu:"
Write-Host "     .\scripts\project-new.ps1 -Name <nazev> -OutputPath <cesta>"
Write-Host ""
Write-Host "  4. Pro vygenerování AI/Copilot instrukcí:"
Write-Host "     .\scripts\generate-ai-instructions.ps1 -ProjectPath <cesta-k-projektu>"
Write-Host ""
