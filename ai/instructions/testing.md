# Instrukce pro testování

## Filozofie testování

- Navrhuj testy podle **hodnoty** – testuj věci, které se mohou rozbít a jejichž rozbití by vadilo
- Nepiš testy jen pro **coverage čísla** – 100% coverage se špatnými testy je horší než 60% s dobrými
- Rozlišuj **unit testy** (rychlé, izolované, bez I/O) a **integrační testy** (reálné závislosti, pomalejší)

## Struktura testů

- Preferuj **Arrange / Act / Assert** strukturu – jasně odděluje přípravu, akci a ověření
- Jeden test = **jeden scénář** – nespojuj více různých Assert scénářů do jednoho testu
- Pojmenuj testy popisně: `MethodName_Scenario_ExpectedResult`
  - Příklad: `CreateOrder_WhenProductOutOfStock_ThrowsInvalidOperationException`

## Nástroje a knihovny

- Používej **FluentAssertions**, pokud je v projektu – čitelnější výstup při selhání
- Pro mocky preferuj **NSubstitute** nebo **Moq** dle projektového standardu
- Pro integrační testy preferuj **reálné dependency** nebo **Testcontainers**, pokud projekt podporuje Docker
- Vyhýbej se mockování toho, co vlastníš jen okrajově (např. mock `DbContext` místo reálné DB)

## Co testovat

- **Business logiku** – validace, výpočty, stavy, transformace dat
- **Edge cases** – null hodnoty, prázdné kolekce, hraniční hodnoty
- **Chybové stavy** – výjimky, neplatné vstupy, nedostupné závislosti

## Co netestovat (nebo testovat opatrně)

- Trivální gettery/settery bez logiky
- Framework kód (ASP.NET routing, EF Core mapping) – tento kód má vlastní testy
- Privátní metody přímo – testuj je přes veřejné API

## Integrační testy

- Preferuj **WebApplicationFactory** pro testování ASP.NET Core aplikací end-to-end
- Používej **reálnou testovací databázi** nebo Testcontainers pro DB testy – in-memory provider skryje SQL problémy
- Izoluj testy od sebe – každý test si vytvoří svůj stav a uklidí po sobě
