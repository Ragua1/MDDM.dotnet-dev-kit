# EF Core instrukce

## N+1 problém

- Vždy **upozorni na N+1** – je to nejčastější EF Core past
- Používej **`.Include()`** pro eager loading, ale pouze tehdy, když data opravdu potřebuješ
- Nekombinuj `.Include()` s filtrováním na klientu – může to vést k načtení celé tabulky

## Projection a materializace

- Preferuj **projection** přes `.Select(x => new ...)` před načtením celé entity
  - Načítáš jen data, která skutečně potřebuješ
  - Snižuje přenos dat a alokace paměti
- Neukrývej drahé dotazy za nenápadné property nebo metody – dej to jasně najevo v názvech nebo dokumentaci

## Tracking

- Pro **read-only dotazy** (zobrazení dat, reporty) vždy přidej `.AsNoTracking()`
- Tracking je potřeba pouze tehdy, když plánuješ entitu **modifikovat a uložit** ve stejném DbContext scope
- Dávej pozor na `AsNoTrackingWithIdentityResolution()` – potřebuješ ho, pokud dotaz vrací grafy entit se sdílenými referencemi

## Transakce a concurrency

- Pro operace měnící **více agregátů** zvažuj explicitní transakce
- Implementuj **optimistické zamykání** (`[Timestamp]` nebo `[ConcurrencyCheck]`) tam, kde více uživatelů může editovat stejná data
- Dávej pozor na **dlouhotrvající transakce** – drž je co nejkratší

## Indexy a výkon

- Přidej **databázové indexy** pro sloupce používané ve WHERE klauzulích nebo JOIN conditions
- EF Core automaticky indexuje foreign keys, ale ostatní indexy musíš přidat ručně v `OnModelCreating`
- Používej **.HasQueryFilter()** pro soft-delete nebo multitenancy – ale dokumentuj ho, protože ovlivňuje všechny dotazy na entitu

## Migrace

- Každá migrace má být **malá a reverzibilní** – vyhýbej se megamigracím
- Zkontroluj vygenerovaný SQL migrace před nasazením: `dotnet ef migrations script`
- Nikdy **neupravuj existující migraci**, která byla nasazena do produkce
- Přidej smysluplné jméno migrace: `dotnet ef migrations add AddOrderStatusIndex`
