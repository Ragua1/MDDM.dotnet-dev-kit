# Dokumentace – MDDM.dotnet-dev-kit

Podrobná dokumentace k použití repozitáře.  
Stručný přehled je v [README.md](../README.md).

---

## Obsah

- [Přehled struktury](#přehled-struktury)
- [Skripty](#skripty)
  - [bootstrap.ps1](#bootstrapps1)
  - [project-apply.ps1](#project-applyps1)
  - [project-new.ps1](#project-newps1)
  - [generate-ai-instructions.ps1](#generate-ai-instructionsps1)
- [Šablony](#šablony)
- [AI instrukce](#ai-instrukce)
- [AI skilly](#ai-skilly)
- [Manifest.yaml](#manifestyaml)
- [Rozšiřování repozitáře](#rozšiřování-repozitáře)

---

## Přehled struktury

```
MDDM.dotnet-dev-kit/
├─ manifest.yaml              # Konfigurace profilů
├─ scripts/                   # PowerShell skripty
├─ templates/project-common/  # Sdílené projektové šablony
├─ ai/instructions/           # Zdrojové AI instrukce
├─ ai/skills/                 # AI skill definice
└─ docs/                      # Tato dokumentace
```

---

## Skripty

### bootstrap.ps1

**Účel:** Ověření prostředí před prvním použitím.

```powershell
.\scripts\bootstrap.ps1
```

Zkontroluje:
- Verzi PowerShellu (doporučeno 5.1+)
- Dostupnost `git`
- Dostupnost `dotnet` a verzi SDK

Zatím **neinstaluje** žádný software – pouze informuje.

---

### project-apply.ps1

**Účel:** Aplikace šablon z tohoto repa do cílového projektu.

```powershell
# Parametry
.\scripts\project-apply.ps1 `
    -ProjectPath "C:\Projects\MyApp" `
    -Profile     "dotnet-basic" `      # volitelné, výchozí: dotnet-basic
    -Mode        "Check"               # Check nebo Apply
```

**Režim Check** (doporučeno spustit jako první):
- Projde všechny soubory profilu
- Vypíše `CREATE` (soubor neexistuje) nebo `SKIP` (soubor existuje)
- **Nic nemodifikuje**

**Režim Apply**:
- Vytvoří chybějící adresáře
- Zkopíruje soubory označené `CREATE`
- Soubory označené `SKIP` **nikdy nepřepíše**

**Přidání nového souboru do profilu:**
1. Přidej šablonu do `templates/project-common/`
2. Přidej záznam do `manifest.yaml`

---

### project-new.ps1

**Účel:** Vytvoření nového .NET projektu se standardním nastavením.

```powershell
.\scripts\project-new.ps1 `
    -Name       "MyApp" `
    -OutputPath "C:\Projects"
```

Provede tyto kroky:
1. Ověří, že výstupní cesta existuje
2. Vytvoří složku `<OutputPath>\<Name>`
3. Spustí `dotnet new sln --name <Name>`
4. Zavolá `project-apply.ps1 -Mode Apply`

**Po vytvoření:**
- Uprav `global.json` – nastav verzi SDK
- Přidej projekty: `dotnet new webapi --name MyApp.Api`
- Přidej je do solution: `dotnet sln add`

---

### generate-ai-instructions.ps1

**Účel:** Generování AI/Copilot instrukcí z centrálních zdrojů.

```powershell
.\scripts\generate-ai-instructions.ps1 -ProjectPath "C:\Projects\MyApp"
```

**Co generuje:**

| Cílový soubor | Zdrojová instrukce |
|---------------|-------------------|
| `AGENTS.md` | `ai/instructions/base.md` + všechny ostatní |
| `.github/copilot-instructions.md` | `base.md` + `dotnet.md` |
| `.github/instructions/dotnet.instructions.md` | `dotnet.md` |
| `.github/instructions/tests.instructions.md` | `testing.md` |
| `.github/instructions/efcore.instructions.md` | `efcore.md` |

**Bezpečné zachování ručního obsahu:**

Generovaný obsah je ohraničen bloky:
```
<!-- BEGIN GENERATED -->
...vygenerovaný obsah...
<!-- END GENERATED -->
```

Obsah **mimo tyto bloky není přepsán**. Můžeš přidat vlastní sekce nad nebo pod Generated blok.

---

## Šablony

Složka `templates/project-common/` obsahuje sdílené šablony.

### .editorconfig
- Kódování UTF-8, CRLF pro Windows
- Indent 4 mezery pro C#, 2 mezery pro XML/JSON/YAML
- Nastavení pro `var` vs. explicitní typy
- Expression-bodied members jen tam, kde zvyšují čitelnost
- **TODO:** uprav preferovaný styl dle potřeb projektu

### Directory.Build.props
- Nullable enable, ImplicitUsings enable
- LangVersion: latestMajor
- TreatWarningsAsErrors: **false** (bezpečný MVP default)
- Deterministický build
- **TODO:** zvažte zapnutí `TreatWarningsAsErrors` pro produkční projekty

### Directory.Packages.props
- Central Package Management zapnut
- Obsahuje základní balíčky jako příklady s aktuálními verzemi
- **TODO:** aktualizuj verze a doplň balíčky specifické pro projekt

### global.json
- Verze SDK: **TODO: nastav na verzi instalovanou na zařízení**
- rollForward: `latestMinor`

---

## AI instrukce

Zdrojové instrukce v `ai/instructions/` jsou psány v Markdownu.
Jsou navrženy tak, aby fungovaly jak při generování do projektů (viz `generate-ai-instructions.ps1`),
tak při přímém použití jako kontext v ChatGPT, Claude nebo jiném AI nástrojí.

| Soubor | Obsah |
|--------|-------|
| `base.md` | Jazyk, styl komunikace, bezpečnost |
| `dotnet.md` | C# konvence, async, DI, logging |
| `testing.md` | Filozofie testů, xunit, FluentAssertions |
| `efcore.md` | N+1, tracking, migrace, indexy |

---

## AI skilly

Složka `ai/skills/` obsahuje definice skillů pro AI asistenty.

Každý skill má `SKILL.md` se strukturou:
- **Účel** – co skill dělá
- **Vstupy** – co skill potřebuje
- **Postup** – jak postupovat
- **Výstup** – formát odpovědi

### Dostupné skilly

| Skill | Popis |
|-------|-------|
| `dotnet-project-initializer` | Inicializace nového nebo existujícího .NET projektu |
| `dotnet-code-review` | Strukturované code review C# kódu |
| `test-strategy-generator` | Navrhování testovací strategie |

---

## Manifest.yaml

Soubor `manifest.yaml` definuje **profily** pro `project-apply.ps1`.

Aktuální profily:

| Profil | Popis |
|--------|-------|
| `dotnet-basic` | Základní .NET projekt (editor, build props, AI instrukce) |

### Přidání nového profilu

```yaml
profiles:
  moje-profil:
    description: "Popis profilu"
    templateBase: "templates/project-common"
    files:
      - source: ".editorconfig"
        target: ".editorconfig"
```

---

## Rozšiřování repozitáře

### Nový profil v manifestu

Přidej sekci do `manifest.yaml` a vytvoř odpovídající šablony.

### Nová AI instrukce

1. Přidej `.md` soubor do `ai/instructions/`
2. Aktualizuj `generate-ai-instructions.ps1` – přidej načtení a použití instrukce

### Nový AI skill

1. Vytvoř složku `ai/skills/<nazev-skillu>/`
2. Přidej `SKILL.md` podle vzoru existujících skillů

### Nový PowerShell skript

1. Přidej do `scripts/`
2. Začni s `#Requires -Version 5.1` a `Set-StrictMode -Version Latest`
3. Dokumentuj parametry pomocí comment-based help (`<# .SYNOPSIS ... #>`)
4. Zapiš do README.md a do tohoto souboru

---

*Dokumentace je záměrně stručná. Přidávej sekce podle potřeby projektu.*
