# Windows 10 — instalacja na nowej maszynie wirtualnej

**Cel:** uruchomić oficjalny instalator Windows 10 z obrazu ISO na nowym wirtualnym dysku. Nie dotykać systemu i danych hosta. Repozytorium nie zawiera ISO ani licencji Microsoft.

## Wymagania

- Komputer lub serwer z Windows Pro/Enterprise/Education i działającym Hyper-V; **nie Windows Home**.
- Funkcje wirtualizacji CPU i SLAT oraz dostateczna ilość pamięci RAM i miejsca na dysku (wirtualny dysk 64 GB).
- Legalnie pozyskany obraz ISO Windows 10, np. z <https://www.microsoft.com/pl-pl/software-download/windows10>.
- Uprawnienia administratora Hyper-V; fizyczny ekran hosta lub dostęp zdalny do okna maszyny.

## 1. Plan i weryfikacja

W PowerShell otwartym w katalogu repozytorium:

```powershell
.\scripts\Test-WindowsVM.ps1
.\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso"
```

Tryb bez `-Create` **nie zmienia niczego**. Wypisuje sprzęt, identyfikator ISO (SHA-256) i plan stworzenia VM. Użycie ISO o prawidłowej sumie kontrolnej względem pliku nie dowodzi jego autentyczności — porównuj z wiarygodnym wzorcem Microsoft, jeśli jest dostępny.

## 2. Uruchomienie instalatora (z potwierdzeniem)

```powershell
.\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso" -Create -Boot -WhatIf
.\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso" -Create -Boot
```

Tworzy **nową** maszynę `Windows10Clean` (Gen2, RAM 4 GB, 2 vCPU, dysk VHDX 64 GB), podłącza ISO i uruchamia ją z nośnika. Nie nadpisuje istniejących VM. **Nie oznacza to jeszcze ukończonej instalacji Windows.**

## 3. Instalacja w maszynie

1. Otwórz **Hyper-V Manager**.
2. Wybierz nową maszynę **Windows10Clean** i kliknij **Connect / Połącz**.
3. W kreatorze Windows wybierz język, edycję i **Install now**.
4. Wybierz **Custom: Install Windows only** i wskaż wyłącznie **nowy, pusty wirtualny dysk 64 GB** tej VM — nie modyfikuj fizycznych dysków.
5. Zaczekaj na restart, dokończ konfigurację użytkownika i aktywację zgodnie z licencją.
6. Jeśli VM ponownie bootuje do instalatora, odłącz ISO w ustawieniach napędu DVD VM lub ustaw wirtualny dysk jako pierwszy w firmware.

## 4. Zakończenie i weryfikacja

W zainstalowanym Windows możesz uruchomić `scripts/Get-Windows10Status.ps1` (diagnostyka odczytu). System uznajemy za zainstalowany dopiero, gdy kreator ukończy działanie i Windows pokaże pulpit.

### Ograniczenia

- W samym ChatGPT nie ma trwałej maszyny Windows ani obrazu instalacyjnego.
- GitHub Codespaces nie jest hostem z systemem Windows i nie gwarantuje obsługi KVM.
- Bez hosta z Hyper-V i ISO możemy przygotować tylko pliki, nie przeprowadzić pełnej instalacji.
- Standardowe wsparcie Windows 10 zakończyło się **14 października 2025 r.**; należy zweryfikować dostępność ESU.
