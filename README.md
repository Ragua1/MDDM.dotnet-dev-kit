# MDDM.dotnet-dev-kit

**Osobní sada šablon, skriptů a AI instrukcí pro .NET vývoj na Windows.**

Toto repo slouží k verzování a sdílení vývojového prostředí napříč zařízeními. Obsahuje projektové šablony, PowerShell skripty, GitHub Copilot instrukce a AI skilly pro .NET projekty.

> ⚠️ Toto je MVP – jednoduché, funkční, postupně rozšiřovatelné. Nesnaž se ho přehlcovat.

---

## Obsah repozitáře

```
MDDM.dotnet-dev-kit/
├─ README.md                          # Tento soubor
├─ manifest.yaml                      # Definice profilů pro project-apply.ps1
├─ scripts/                           # PowerShell skripty
│  ├─ bootstrap.ps1                   # Ověření prostředí
│  ├─ project-apply.ps1               # Aplikace šablon do existujícího projektu
│  ├─ project-new.ps1                 # Vytvoření nového projektu
│  └─ generate-ai-instructions.ps1   # Generování AI/Copilot instrukcí
├─ templates/
│  └─ project-common/                 # Sdílené šablony pro .NET projekty
│     ├─ .editorconfig
│     ├─ Directory.Build.props
│     ├─ Directory.Packages.props
│     ├─ global.json
│     ├─ AGENTS.md.template
│     ├─ copilot-instructions.md.template
│     └─ instructions/
│        ├─ dotnet.instructions.md.template
│        ├─ tests.instructions.md.template
│        └─ efcore.instructions.md.template
├─ ai/
│  ├─ instructions/                   # Zdrojové AI instrukce
│  │  ├─ base.md
│  │  ├─ dotnet.md
│  │  ├─ testing.md
│  │  └─ efcore.md
│  └─ skills/                         # ChatGPT / AI skilly
│     ├─ dotnet-project-initializer/
│     ├─ dotnet-code-review/
│     └─ test-strategy-generator/
└─ docs/
   └─ usage.md                        # Podrobná dokumentace
```

---

## Jak začít

### 1. Naklonování repozitáře

```powershell
git clone https://github.com/<tvuj-username>/MDDM.dotnet-dev-kit.git
cd MDDM.dotnet-dev-kit
```

### 2. Ověření prostředí

```powershell
.\scripts\bootstrap.ps1
```

Skript zkontroluje dostupnost `git` a `dotnet` a vypíše doporučené kroky.

---

## Použití projektového apply skriptu

Aplikuje šablony z tohoto repa do existujícího projektu.

```powershell
# Zkontroluj, co by se změnilo (nic nepřepíše)
.\scripts\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Mode Check

# Aplikuj šablony (přeskočí existující soubory)
.\scripts\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Mode Apply

# Použij jiný profil (výchozí je dotnet-basic)
.\scripts\project-apply.ps1 -ProjectPath "C:\Projects\MyApp" -Profile dotnet-basic -Mode Apply
```

Skript **nikdy nepřepíše existující soubor bez varování**. Pokud soubor existuje, vypíše `SKIP`.

---

## Generování GitHub Copilot instrukcí

Vygeneruje soubory pro GitHub Copilot a AI agenty z instrukcí v `ai/instructions/`.

```powershell
.\scripts\generate-ai-instructions.ps1 -ProjectPath "C:\Projects\MyApp"
```

Vygeneruje:
- `AGENTS.md` – instrukce pro AI agenty (Copilot, ChatGPT, Cursor, atd.)
- `.github/copilot-instructions.md` – instrukce pro GitHub Copilot
- `.github/instructions/dotnet.instructions.md`
- `.github/instructions/tests.instructions.md`
- `.github/instructions/efcore.instructions.md`

Obsah mimo bloky `<!-- BEGIN GENERATED -->` / `<!-- END GENERATED -->` **nebude přepsán**.

---

## Vytvoření nového projektu

```powershell
.\scripts\project-new.ps1 -Name "MyApp" -OutputPath "C:\Projects"
```

Skript vytvoří složku, inicializuje solution a zavolá `project-apply.ps1`.

---

## Přidávání nových šablon a instrukcí

### Nová šablona souboru

1. Přidej soubor do `templates/project-common/` (nebo nové podsložky)
2. Přidej záznam do `manifest.yaml` pod příslušný profil
3. Otestuj: `.\scripts\project-apply.ps1 -ProjectPath <cesta> -Mode Check`

### Nová AI instrukce

1. Přidej `.md` soubor do `ai/instructions/`
2. Odkazuj na něj v `scripts/generate-ai-instructions.ps1`
3. Znovu vygeneruj instrukce: `.\scripts\generate-ai-instructions.ps1 -ProjectPath <cesta>`

### Nový AI skill

1. Vytvoř složku `ai/skills/<nazev-skillu>/`
2. Přidej `SKILL.md` s popisem skriptu, vstupy a výstupy

---

## Poznámky

- Repo je **MVP** – bude postupně rozšiřováno podle potřeby
- Skripty jsou záměrně jednoduché a čitelné – preferuj pochopitelnost před elegancí
- Před každou větší změnou doporučuji commitovat aktuální stav
- Podrobnější dokumentace je v [`docs/usage.md`](docs/usage.md)
