# Skill: dotnet-project-initializer

## Účel

Pomáhá připravit **nový nebo existující .NET projekt** aplikací standardních šablon,
konfigurací a AI instrukcí z MDDM.dotnet-dev-kit.

---

## Vstupy

- Cesta k projektu nebo název nového projektu
- Typ projektu (Web API, Console, Class Library, Worker, atd.)
- Zda projekt existuje nebo ho teprve vytváříme

---

## Postup

### 1. Zjistit stav projektu

- Je to nový nebo existující projekt?
- Jakou verzi .NET používá?
- Existuje už `Directory.Build.props`, `.editorconfig`, `global.json`?
- Existuje `.github/copilot-instructions.md` nebo `AGENTS.md`?

### 2. Doporučit soubory k doplnění

Na základě zjištěného stavu doporuč, které soubory chybí:

| Soubor | Existuje? | Akce |
|--------|-----------|------|
| `.editorconfig` | ? | CREATE / SKIP |
| `Directory.Build.props` | ? | CREATE / SKIP |
| `Directory.Packages.props` | ? | CREATE / SKIP |
| `global.json` | ? | CREATE / SKIP |
| `AGENTS.md` | ? | CREATE / SKIP |
| `.github/copilot-instructions.md` | ? | CREATE / SKIP |

### 3. Aplikovat šablony

```powershell
# Zkontroluj nejdříve
.\scripts\project-apply.ps1 -ProjectPath <cesta> -Mode Check

# Pak teprve aplikuj
.\scripts\project-apply.ps1 -ProjectPath <cesta> -Mode Apply
```

### 4. Generovat AI instrukce

```powershell
.\scripts\generate-ai-instructions.ps1 -ProjectPath <cesta>
```

### 5. Ověřit výsledek

- Zkontroluj, zda build projde: `dotnet build`
- Zkontroluj verzi .NET v `global.json`
- Uprav `Directory.Packages.props` – odkomentuj potřebné balíčky

---

## Bezpečnostní pravidla

- **Nikdy nepřepiš existující soubor bez upozornění**
- Vždy nejdřív spusť `Mode Check` a ukáž uživateli plánované změny
- Pokud soubor existuje, navrhni diff místo přepsání
- Preferuj malé kroky – jeden soubor najednou, ne celé repo

---

## Výstup

Po dokončení vypíš:
- Co bylo vytvořeno
- Co bylo přeskočeno (existovalo)
- Doporučené manuální kroky (verze SDK, balíčky, atd.)
