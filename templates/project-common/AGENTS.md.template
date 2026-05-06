# AGENTS.md

Tento soubor obsahuje instrukce pro AI agenty (GitHub Copilot, ChatGPT, Cursor a další)
pracující v tomto repozitáři.

> Obsah sekce **Generated** je generován skriptem `generate-ai-instructions.ps1`.  
> Ruční sekce mimo Generated blok nejsou přepsány.

---

## Jak buildit projekt

```bash
# Obnovení NuGet balíčků
dotnet restore

# Build
dotnet build

# Build v release konfiguraci
dotnet build --configuration Release
```

## Jak spustit testy

```bash
# Spustit všechny testy
dotnet test

# Spustit testy s výstupem
dotnet test --logger "console;verbosity=normal"

# Spustit konkrétní projekt
dotnet test tests/MyProject.Tests
```

## Základní .NET coding conventions

- Používej C# `latestMajor` (viz `Directory.Build.props`)
- Nullable reference types jsou zapnuty – respektuj je
- Preferuj `async/await` pro I/O operace
- Vždy předávej `CancellationToken` kde to dává smysl
- Drž business logiku mimo controllery / handlery
- Preferuj dependency injection přes konstruktor
- Piš čitelný kód – optimalizuj pro čtenáře, ne pro překladač

## Co kontrolovat před commitem

- [ ] `dotnet build` projde bez chyb
- [ ] `dotnet test` projde
- [ ] Žádná nová varování, která nebyla tam dříve
- [ ] Nové třídy/metody mají smysluplné názvy
- [ ] Nullable warningy jsou adresovány

---

<!-- BEGIN GENERATED -->
<!-- END GENERATED -->
