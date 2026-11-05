# Windows_10

Minimalny, czysty projekt startowy Windows 10 — **bez plików systemu Windows**.

To repozytorium zawiera instrukcje legalnego pobrania Windows 10 od Microsoft, weryfikacji obrazu ISO oraz dwa bezpieczne skrypty PowerShell do diagnostyki. **Nie zawiera Windows 10, jego kodu źródłowego, obrazów ISO ani kluczy licencyjnych.**

## Pierwsze kroki

1. Przeczytaj [instrukcję czystej instalacji](docs/INSTALACJA.md).
2. Pobierz oficjalny obraz lub narzędzie Media Creation Tool ze strony Microsoft: https://www.microsoft.com/pl-pl/software-download/windows10
3. Jeśli pobrano ISO, sprawdź sumę SHA-256:
   ```powershell
   .\scripts\Test-Windows10Media.ps1 -IsoPath 'C:\Users\TwojaNazwa\Downloads\Win10.iso'
   ```
   Jeśli znasz oficjalną sumę SHA-256 odpowiadającą dokładnie Twojemu obrazowi ISO, użyj również `-ExpectedSha256`.
4. Na komputerze z Windows uruchom bezpieczną diagnostykę (tylko odczyt):
   ```powershell
   .\scripts\Get-Windows10Status.ps1
   ```

## Zawartość

- `docs/INSTALACJA.md` — czysta instalacja Windows 10 i uwagi o licencjach.
- `scripts/Test-Windows10Media.ps1` — oblicza SHA-256 ISO i opcjonalnie porównuje z oczekiwaną wartością.
- `scripts/Get-Windows10Status.ps1` — wyświetla informacje o systemie Windows; niczego nie modyfikuje.
- `.gitignore` — zapobiega przypadkowemu dodaniu obrazów systemowych i tajnych plików.

## Bezpieczeństwo i wsparcie

Standardowe wydania Windows 10 osiągnęły koniec wsparcia **14 października 2025 r.** Sprawdź program ESU lub wybierz wspierany system operacyjny, zwłaszcza do pracy w sieci.

To jest własny projekt pomocniczy, **nieoficjalny projekt Microsoft**.
