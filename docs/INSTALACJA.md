# Czysta instalacja Windows 10

> Uwaga: Czysta instalacja może usunąć wszystkie dane z wybranego dysku/partycji. Przed rozpoczęciem wykonaj kopię zapasową i sprawdź, czy posiadasz ważną licencję Windows.

## 1. Pobierz instalator ze źródła Microsoft

- Windows 10: https://www.microsoft.com/pl-pl/software-download/windows10
- Windows 10 ISO: https://www.microsoft.com/pl-pl/software-download/windows10ISO
- Instrukcje Microsoft dotyczące nośnika instalacyjnego: https://support.microsoft.com/windows/deployment/install-upgrade/create-installation-media-for-windows

Pobieraj tylko oficjalne, niezmodyfikowane obrazy. Obraz ISO i licencja pozostają poza repozytorium GitHub.

## 2. Zweryfikuj obraz ISO (opcjonalnie)

W PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 -Path 'C:\ścieżka\Win10.iso'
```

Sumę porównuj **tylko** z wiarygodnym oficjalnym hashem dla dokładnie tej wersji i języka ISO.

Możesz też uruchomić `scripts/Test-Windows10Media.ps1`.

## 3. Utwórz nośnik instalacyjny

Użyj oficjalnego narzędzia Microsoft Media Creation Tool i pustego pendrive'a o pojemności co najmniej 8 GB (jego zawartość może zostać usunięta). Przygotowanie nośnika wykonuj na własnym komputerze.

## 4. Zainstaluj Windows

1. Zapisz kopię danych i zanotuj ustawienia urządzenia.
2. Uruchom komputer z pendrive'a przez menu rozruchowe producenta.
3. Wybierz język, edycję i typ instalacji.
4. Jeśli rzeczywiście chcesz instalacji od zera, wybierz instalację niestandardową i **uważnie** wskaż właściwy dysk. Usuwanie partycji jest nieodwracalne.
5. Po instalacji skonfiguruj konto, aktualizacje, sterowniki i aktywację zgodnie z warunkami Microsoft.

## 5. Potwierdź stan systemu

Po instalacji:

```powershell
.\scripts\Get-Windows10Status.ps1
```

## Ważne w 2026 r.

Zwykły Windows 10 Home/Pro zakończył bezpłatne wsparcie 14 października 2025 r. W zależności od edycji i urządzenia dostępne mogą być dodatkowe programy ESU. Nie zakładaj, że świeża instalacja Windows 10 będzie otrzymywać aktualizacje bezpieczeństwa bez ESU.

Oficjalne informacje: https://learn.microsoft.com/windows/release-health/release-information
