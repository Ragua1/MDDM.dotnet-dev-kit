<#
.SYNOPSIS
    Generuje AI instrukce a GitHub Copilot instrukce do cílového projektu.

.DESCRIPTION
    Vezme zdrojové instrukce z ai/instructions/ a vygeneruje soubory
    AGENTS.md a .github/copilot-instructions.md + instrukce pro Copilot.

    Obsah mimo bloky <!-- BEGIN GENERATED --> / <!-- END GENERATED -->
    není přepsán – ruční sekce jsou zachovány.

.PARAMETER ProjectPath
    Absolutní nebo relativní cesta k cílovému projektu.

.EXAMPLE
    .\generate-ai-instructions.ps1 -ProjectPath "C:\Projects\MyApp"
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Cesty ---
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot   = Split-Path -Parent $scriptRoot

$ProjectPath = (Resolve-Path $ProjectPath -ErrorAction SilentlyContinue)?.Path
if (-not $ProjectPath) {
    Write-Error "Cílová cesta '$ProjectPath' neexistuje."
    exit 1
}

$instructionsRoot = Join-Path $repoRoot 'ai\instructions'

Write-Host ""
Write-Host "=== generate-ai-instructions.ps1 ===" -ForegroundColor Cyan
Write-Host "Projekt  : $ProjectPath"
Write-Host ""

# --- Pomocná funkce: načti instrukce ---
function Get-InstructionContent {
    param([string]$FilePath)
    if (Test-Path $FilePath) {
        return (Get-Content -Path $FilePath -Raw).Trim()
    }
    Write-Warning "Soubor s instrukcemi nenalezen: $FilePath"
    return ''
}

# --- Pomocná funkce: zapsat soubor s generated blokem ---
# Pokud soubor existuje, nahradí pouze obsah mezi generated značkami.
# Pokud soubor neexistuje, vytvoří ho celý.
function Write-GeneratedFile {
    param(
        [string]$TargetPath,
        [string]$GeneratedContent,
        [string]$DefaultHeader = ''
    )

    $beginTag = '<!-- BEGIN GENERATED -->'
    $endTag   = '<!-- END GENERATED -->'

    $newBlock = "$beginTag`n$GeneratedContent`n$endTag"

    if (Test-Path $TargetPath) {
        $existing = Get-Content -Path $TargetPath -Raw

        if ($existing -match [regex]::Escape($beginTag)) {
            # Nahraď pouze generated blok
            $pattern     = [regex]::Escape($beginTag) + '[\s\S]*?' + [regex]::Escape($endTag)
            $updated     = [regex]::Replace($existing, $pattern, $newBlock)
            Set-Content -Path $TargetPath -Value $updated -NoNewline
            Write-Host "  UPDATE $TargetPath" -ForegroundColor Yellow
        } else {
            # Soubor existuje, ale nemá generated blok – přidej blok na konec
            $updated = $existing.TrimEnd() + "`n`n$newBlock`n"
            Set-Content -Path $TargetPath -Value $updated -NoNewline
            Write-Host "  APPEND $TargetPath" -ForegroundColor Yellow
        }
    } else {
        # Soubor neexistuje – vytvoř ho
        $targetDir = Split-Path -Parent $TargetPath
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        $fullContent = if ($DefaultHeader) {
            "$DefaultHeader`n`n$newBlock`n"
        } else {
            "$newBlock`n"
        }

        Set-Content -Path $TargetPath -Value $fullContent -NoNewline
        Write-Host "  CREATE $TargetPath" -ForegroundColor Green
    }
}

# --- Načtení zdrojových instrukcí ---
$baseContent    = Get-InstructionContent (Join-Path $instructionsRoot 'base.md')
$dotnetContent  = Get-InstructionContent (Join-Path $instructionsRoot 'dotnet.md')
$testingContent = Get-InstructionContent (Join-Path $instructionsRoot 'testing.md')
$efcoreContent  = Get-InstructionContent (Join-Path $instructionsRoot 'efcore.md')

# --- AGENTS.md ---
$agentsContent = @"
## AI instrukce – základ

$baseContent

## .NET / C# instrukce

$dotnetContent

## Testování

$testingContent

## EF Core

$efcoreContent
"@

$agentsHeader = @"
# AGENTS.md

Instrukce pro AI agenty (GitHub Copilot, ChatGPT, Cursor, atd.) pracující v tomto repozitáři.

> Obsah sekce Generated je generován skriptem generate-ai-instructions.ps1.
> Ruční sekce mimo Generated blok nejsou přepsány.
"@

Write-GeneratedFile `
    -TargetPath      (Join-Path $ProjectPath 'AGENTS.md') `
    -GeneratedContent $agentsContent `
    -DefaultHeader   $agentsHeader

# --- .github/copilot-instructions.md ---
$copilotContent = @"
## Obecné instrukce

$baseContent

## .NET / C# instrukce

$dotnetContent
"@

$copilotHeader = @"
# GitHub Copilot instrukce

Instrukce pro GitHub Copilot v tomto projektu.

> Obsah sekce Generated je generován skriptem generate-ai-instructions.ps1.
"@

Write-GeneratedFile `
    -TargetPath      (Join-Path $ProjectPath '.github\copilot-instructions.md') `
    -GeneratedContent $copilotContent `
    -DefaultHeader   $copilotHeader

# --- .github/instructions/dotnet.instructions.md ---
$dotnetInstrHeader = @"
---
applyTo: "**/*.cs"
---

# .NET / C# instrukce

> Generováno ze zdrojové instrukce ai/instructions/dotnet.md
"@

Write-GeneratedFile `
    -TargetPath      (Join-Path $ProjectPath '.github\instructions\dotnet.instructions.md') `
    -GeneratedContent $dotnetContent `
    -DefaultHeader   $dotnetInstrHeader

# --- .github/instructions/tests.instructions.md ---
$testsInstrHeader = @"
---
applyTo: "**/*Tests.cs, tests/**/*.cs"
---

# Instrukce pro testování

> Generováno ze zdrojové instrukce ai/instructions/testing.md
"@

Write-GeneratedFile `
    -TargetPath      (Join-Path $ProjectPath '.github\instructions\tests.instructions.md') `
    -GeneratedContent $testingContent `
    -DefaultHeader   $testsInstrHeader

# --- .github/instructions/efcore.instructions.md ---
$efcoreInstrHeader = @"
---
applyTo: "**/*DbContext.cs, **/Migrations/**/*.cs, **/*Repository.cs"
---

# EF Core instrukce

> Generováno ze zdrojové instrukce ai/instructions/efcore.md
"@

Write-GeneratedFile `
    -TargetPath      (Join-Path $ProjectPath '.github\instructions\efcore.instructions.md') `
    -GeneratedContent $efcoreContent `
    -DefaultHeader   $efcoreInstrHeader

Write-Host ""
Write-Host "Hotovo! AI instrukce byly vygenerovány." -ForegroundColor Green
Write-Host ""
