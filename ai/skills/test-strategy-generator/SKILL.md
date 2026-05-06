# Skill: test-strategy-generator

## Účel

Navrhuje **testovací strategii** pro konkrétní změnu, třídu nebo feature.
Pomáhá rozhodnout, co testovat, jak a proč.

---

## Vstupy

- Popis změny nebo třída/metoda k otestování
- Typ komponenty (service, controller, repository, domain model, atd.)
- Stávající pokrytí testy (pokud je známo)
- Dostupné testovací nástroje (xunit, NSubstitute, Testcontainers, atd.)

---

## Typy testů

| Typ | Kdy použít | Rychlost |
|-----|-----------|---------|
| **Unit test** | Izolovaná logika bez závislostí na I/O | ⚡ Velmi rychlé |
| **Integration test** | Interakce mezi komponentami nebo s reálnou DB/API | 🐢 Pomalejší |
| **Contract test** | Ověření API kontraktu (request/response shape) | ⚡ Rychlé |
| **Database test** | EF Core dotazy, migrace, constraints | 🐢 Pomalejší |

---

## Postup

### 1. Analyzovat co se testuje

- Jaká je hlavní zodpovědnost třídy/metody?
- Jaké jsou vstupy a výstupy?
- Jaké jsou vedlejší efekty (DB, HTTP, události)?
- Jaké jsou edge cases (null, prázdné, hraniční hodnoty)?

### 2. Navrhnout strategii

Na základě analýzy rozhoduj:
- Jaký typ testu je vhodný
- Co mockovat a co použít reálné
- Jak izolovat test od externích závislostí

---

## Výstup

### 📋 What to test
Seznam věcí, které mají být pokryty testy.

### 🚫 What NOT to test
Věci, které jsou buď triviální, nebo jsou zodpovědností frameworku.

### ✅ Recommended test cases
Konkrétní pojmenované scénáře:
- `MethodName_Scenario_ExpectedResult`

### 🧪 Example test skeletons
Ukázkové kostry testů s Arrange/Act/Assert strukturou.

```csharp
[Fact]
public async Task MethodName_WhenScenario_ThenExpectedResult()
{
    // Arrange
    ...

    // Act
    var result = await sut.MethodAsync(...);

    // Assert
    result.Should().Be(...);
}
```

### ⚠️ Risks
- Části kódu, které jsou obtížně testovatelné a proč
- Potenciální falešné pozitivy/negativy
- Závislosti na externích systémech bez abstrakce

---

## Doporučení pro konkrétní případy

### Domain service / business logic
→ Unit testy, minimální závislosti, fokus na různé stavy vstupu

### Repository / EF Core
→ Integrační test s reálnou DB (SQLite in-memory nebo Testcontainers)
→ Testuj že SQL query vrací správná data, ne jen že se zavolala metoda

### ASP.NET Controller / Minimal API
→ `WebApplicationFactory` pro end-to-end HTTP test
→ Testuj status kódy, response shape, middleware efekty

### Background service / Worker
→ Unit test pro business logiku, integrační test pro celý pipeline
