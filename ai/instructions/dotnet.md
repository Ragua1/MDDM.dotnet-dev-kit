# .NET / C# instrukce

## Verze a funkce jazyka

- Preferuj **moderní C#** – využívej nové syntaktické funkce, které zvyšují čitelnost
- Respektuj **nullable reference types** – nepoužívej `!` operátor bez komentáře vysvětlujícího proč
- Preferuj **file-scoped namespaces** pro nové soubory

## Architektura a design

- Preferuj **dependency injection** přes konstruktor – vyhýbej se service locatoru
- Drž **business logiku mimo controllery** – controllery jsou thin a delegují na services/handlers
- Respektuj **existující architekturu** projektu – neměň vzory bez konzultace
- Preferuj **explicitní interfaces** pro závislosti, které chceš testovat

## Async/await

- Piš async kód **správně** – nepoužívej `.Result`, `.Wait()` nebo `.GetAwaiter().GetResult()` v async kontextu
- Vždy přidej `Async` suffix k async metodám
- Propaguj **CancellationToken** od volající vrstvy dolů – nepřidávej `CancellationToken.None` bez důvodu
- Dávej pozor na **deadlocky** – používej `ConfigureAwait(false)` v library kódu, ne v aplikačním kódu

## Logování

- Používej `ILogger<T>` injektovaný přes konstruktor
- Loguj na správné úrovni: `Debug` pro diagnostiku, `Information` pro klíčové události, `Warning` pro neočekávané stavy, `Error` pro chyby
- Nikdy neloguj **citlivá data** (hesla, tokeny, PII)
- Preferuj **structured logging** se pojmenovanými parametry: `_logger.LogInformation("Order {OrderId} processed", orderId)`

## Validace

- Validuj **na vstupu** – neočekávej, že data z vnějšku jsou platná
- Preferuj explicitní validaci před spoléháním na vyjimky pro kontrolní tok

## Testovatelnost

- Piš kód, který **lze testovat bez frameworku** – statické třídy a singleton antipatterns znesnadňují testování
- Vyhýbej se `DateTime.Now` – injektuj `TimeProvider` nebo `ISystemClock` pro testovatelnost
- Vyhýbej se přímému volání `File.ReadAllText` v business logice – zabal to za abstrakci
