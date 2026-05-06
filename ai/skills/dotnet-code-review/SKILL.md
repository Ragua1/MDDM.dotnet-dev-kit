# Skill: dotnet-code-review

## Účel

Provede **strukturované code review** C#/.NET kódu s důrazem na correctness,
udržovatelnost, výkon a testovatelnost.

---

## Vstupy

- Kód ke kontrole (soubor, třída, metoda, PR diff)
- Kontext: typ projektu (API, Worker, Library, atd.)
- Specifické oblasti, na které se zaměřit (volitelné)

---

## Co kontrolovat

### Correctness
- Logické chyby a edge cases
- Off-by-one, null reference, nevyhozené výjimky
- Nesprávné zacházení s výsledky operací

### Async/Await
- Blocking calls (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()`)
- Missing `await` (fire-and-forget nechtěné)
- Nesprávné použití `async void`
- Chybějící `CancellationToken` propagace

### Nullability
- Ignorované nullable warningy (`!` operátor bez komentáře)
- Potenciální NullReferenceException
- Nekonzistentní nullable anotace

### DI lifetimes
- Captive dependency (singleton injektuje scoped závislost)
- Resolve ze scope mimo DI container

### EF Core pitfalls
- N+1 query
- Chybějící `.AsNoTracking()` u read-only dotazů
- Zbytečná materializace místo projection
- Dlouhotrvající transakce

### Logging
- Chybějící logování chybových stavů
- Logování citlivých dat
- Nevhodná log úroveň (Error vs Warning vs Information)
- Nestrukturované logování (string interpolace místo pojmenovaných parametrů)

### Validace
- Chybějící validace vstupů
- Validace jen na UI vrstvě bez validace na backend

### Testovatelnost
- Tight coupling (přímé new instance závislostí)
- Statické třídy znesnadňující testování
- Skrytá závislost na čase, random nebo filesystem

### Maintainability
- Porušení SRP (třída dělá příliš mnoho věcí)
- Příliš dlouhé metody
- Magic numbers bez pojmenovaných konstant
- Duplicitní kód

---

## Výstup

Odpověď strukturuj do těchto sekcí:

### 🚫 Blocking issues
Chyby, které musí být opraveny před mergem (correctness, bezpečnost, dependency lifetime).

### ⚠️ Important suggestions
Věci, které nejsou breaking, ale výrazně ovlivňují kvalitu.

### 💡 Minor improvements
Styl, čitelnost, drobné vylepšení.

### 🧪 Suggested tests
Konkrétní test scénáře, které by stálo za to přidat.

### 🔧 Suggested patch
Pokud dává smysl, přidej konkrétní diff nebo ukázkový kód pro opravu.

---

## Tón a styl

- Buď konkrétní – "řádek 42: ..." místo "někde v kódu..."
- Vysvětli **proč** je něco problém, nejen co
- Navrhuj opravy, nejenom upozorňuj
- Rozlišuj between "musíš opravit" a "zvažuj jestli"
