# Windows_10

Windows 10 — czysty projekt konfiguracyjny: instalacja systemu, **dotykowy pulpit Windows**, wirtualizacja, narzędzia OpenAI oraz lokalne kanały czterech istniejących agentów **Alex, Aria, Astyria, Aurelius**.

**To nie jest obraz ISO ani kopia systemu Windows.** Repozytorium zawiera skrypty i instrukcje. Uruchomienie funkcji wymaga urządzenia z Windows 10 i odpowiedniego sprzętu. Licencji, ISO oraz sekretów nie umieszczamy na GitHubie.

## Windows 10 z telefonu — pełny pulpit w przeglądarce

[Instrukcja instalacji pełnego Windows 10 na serwerze KVM z obsługą noVNC na Androidzie](docs/INSTALACJA-CHMURA-ANDROID.md).

Na telefonie nie potrzebujesz lokalnego Windows ani Hyper-V, ale potrzebujesz oddzielnego serwera KVM z konsolą HTML5, oficjalnego ISO i odpowiedniego prawa do używania/licencjonowania Windows 10 w chmurze. **Nie utworzono ani nie opłacono serwera.**

## Instalacja czystego Windows 10 (priorytet)

1. Pobierz oficjalny obraz ISO ze strony <https://www.microsoft.com/pl-pl/software-download/windows10>.
2. Na komputerze z włączonym Hyper-V, w PowerShell, wykonaj **plan bez zmian**:

```powershell
.\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso"
```

3. Aby utworzyć i uruchomić nową maszynę (po potwierdzeniu):

```powershell
.\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso" -Create -Boot
```

4. Połącz się z VM w Hyper-V Manager i dokończ instalator Microsoft.

Szczegóły: [Instalacja w Hyper-V](docs/WINDOWS-VM.md). Samo ChatGPT nie uruchamia pełnej maszyny Windows, a Codespaces nie udostępnia natywnego hosta Windows.

## Pulpit dotykowy — uruchom

Na komputerze Windows, w PowerShell:

```powershell
git clone https://github.com/u6930438163-code/Windows_10.git
cd Windows_10
.\scripts\Test-TouchScreen.ps1
.\scripts\Launch-TouchWorkspace.ps1
```

Aby utworzyć **skrót na pulpicie** (dopiero na wyraźne żądanie):

```powershell
.\scripts\Install-TouchShortcut.ps1 -Create
```

To uruchamia duży panel WPF z przyciskami obsługiwanymi palcem lub myszą. Daje szybki dostęp do: Eksploratora, Ustawień, trybu tabletu, dotyku, klawiatury ekranowej, skali wyświetlania, PowerShell, Menedżera zadań, ChatGPT, Codex i kanałów agentów.

**Pełny dotyk w Windows 10** zapewniają sterownik ekranu dotykowego i wbudowany tryb tabletu. Nasza nakładka nie zamienia monitora bez dotyku w panel dotykowy i nie zmienia wstecznie interfejsów obcych aplikacji. Instrukcja: [Panel i ustawienia dotyku](ui/README.md).

## Moduły

| Kategoria | Zawartość |
| --- | --- |
| Czysta instalacja Windows | [Instrukcja i pobieranie oryginalnego ISO](docs/INSTALACJA.md) |
| Wirtualizacja Hyper-V | [Diagnostyka i kontrolowane tworzenie VM](docs/WINDOWS-VM.md) |
| OpenAI | [ChatGPT, Codex, OpenAI SDK, MCP i bezpieczny instalator](docs/OPENAI-APPS.md) |
| Agenci AI | [Lokalny czat z historią, kolejką, SQLite, HTTP API, MCP](agents/README.md) |
| Pulpit dotykowy | [Uruchamianie panelu WPF i systemowych funkcji dotykowych](ui/README.md) |

## Lokalni agenci (bez udawania odpowiedzi AI)

```powershell
python agents/agentctl.py status
python agents/agentctl.py send --from user --to Alex --text "Status"
python agents/agentctl.py inbox --agent Alex
```

Tożsamości agentów są zachowane, a komunikacja między nimi może być kolejkowana lokalnie. **Faktyczne odpowiedzi i praca agentów wymagają podłączenia zgodnego, uwierzytelnionego backendu.** Bez niego nie są online, a polecenia pozostają w kolejce.

## Instalacja narzędzi OpenAI — tylko na żądanie

```powershell
.\scripts\Install-OpenAITools.ps1
.\scripts\Install-OpenAITools.ps1 -InstallChatGPT -WhatIf
```

Uruchomienie skryptu bez przełączników nic nie instaluje.

## Bezpieczeństwo i wsparcie

- Skrypty dotykowe nie zmieniają ani nie zastępują systemowej powłoki Windows.
- Żadnych zaszytych kluczy API ani automatycznej pełnej kontroli nad PowerShell przez AI.
- Standardowe wsparcie Windows 10 zakończyło się **14 października 2025 r.** Sprawdź ESU, jeśli planujesz korzystanie z Windows 10 w sieci.
- To **nieoficjalny projekt pomocniczy**, a nie produkt Microsoft ani OpenAI.

## Zmiany interfejsu dotykowego

Historia czatu jest pokazana ponad polem wysyłania, odświeża się co 8 sekund i jest rozdzielona na kanały czterech agentów oraz zbiorczy kanał `all`. Pod czatem dostępny jest pulpit narzędzi Windows. Zdalna integracja z modelami AI nie została jeszcze zweryfikowana i wymaga prawidłowego API oraz uwierzytelnienia.
