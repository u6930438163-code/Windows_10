# Integracja istniejących agentów AI z Windows_10

Cztery istniejące tożsamości: **Alex**, **Aria** (dawniej SI_1), **Astyria**, **Aurelius**. W tym projekcie nie narzucamy im ról, osobowości, instrukcji ani dostawców modeli. Nie tworzymy imitacji czterech niezależnych modeli.

## Lokalny kanał dwukierunkowy

Wymaga Python 3.11+. Bez dodatkowych zależności działa lokalna, trwała skrzynka SQLite.

```powershell
python agents/agentctl.py status
python agents/agentctl.py send --from user --to Alex --text "Przeanalizuj stan systemu"
python agents/agentctl.py send --from Aria --to Astyria --text "Prośba o współpracę"
python agents/agentctl.py send --from user --to all --text "Raport statusu"
python agents/agentctl.py inbox --agent user
python agents/agentctl.py inbox --agent Alex
python agents/agentctl.py conversation --agent Alex
python agents/agentctl.py conversation --agent all
```

Komunikaty są przechowywane lokalnie. **Bez działającego backendu AI będą miały stan `queued`**, czyli nie oznaczają, że model cokolwiek przeczytał lub odpowiedział. Komunikat z agenta do `user` trafia do lokalnej skrzynki `user`.

## Zewnętrzny backend Twoich agentów

Wcześniej używany backend Google AI Studio / Debian 13 nie ma tutaj potwierdzonego, uwierzytelnionego API wysyłania wiadomości. Nie wywołujemy przez pomyłkę `/api/agent-tasks/run` ani `/api/agents/inbox/send` — ich znaczenie było inne.

Po zweryfikowaniu endpointu ustaw środowisko PowerShell (nie zapisuj tokenu w repo):

```powershell
$env:AGENT_GATEWAY_URL="https://TWOJA-BRAMA.example"
$env:AGENT_GATEWAY_SEND_PATH="/twoj/potwierdzony/endpoint"
$env:AGENT_GATEWAY_TOKEN="TWOJ_TOKEN"
python agents/agentctl.py send --from user --to Alex --text "Test połączenia"
```

Protokół adaptera dla wysyłania: `POST` z JSON `{"message_id":1,"agent":"Alex","sender":"user","message":"..."}` i nagłówkiem `Authorization: Bearer ...`. Odpowiedź 2xx = **zaakceptowano żądanie przez bramę**, a nie ukończono pracę. Opcjonalne pole JSON `reply` zapisuje odpowiedź do skrzynki nadawcy. Przy błędzie wiadomość uzyskuje stan `failed` i można ponowić: `python agents/agentctl.py retry --id 1`. Zewnętrzny backend musi jawnie zaimplementować ten kontrakt (lub wymagać dopasowania adaptera).

## Lokalny HTTP API

```powershell
$env:WINDOWS10_LOCAL_TOKEN="WYGENERUJ-DLUGI-LOSOWY-TOKEN"
python agents/agentctl.py serve --port 8765
```

Serwer nasłuchuje **tylko na 127.0.0.1**, każde wywołanie wymaga `Authorization: Bearer TOKEN`. Endpointy:

- `GET /v1/agents` – znane tożsamości i konfiguracja bramy.
- `GET /v1/inbox?recipient=Alex&since=0` – skrzynka.
- `GET /v1/conversation?agent=Alex&limit=100` – historia rozmowy użytkownika z Alexem.
- `GET /v1/conversation?agent=all&limit=100` – kanał zbiorczy, także wymiana agent–agent.
- `POST /v1/messages` – JSON `{"sender":"user","recipient":"Aria","message":"Cześć"}`.

To **nie** jest publiczny serwer przeznaczony do wystawiania w Internecie. Token lokalny daje dostęp do wszystkich skrzynek — nie należy go udostępniać niezaufanym użytkownikom.

## MCP dla Codex

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install "mcp>=2,<3"
.\.venv\Scripts\python.exe -m mcp run agents/mcp_server.py --transport stdio
```

W aplikacji obsługującej MCP dodaj serwer stdio wskazujący interpreter Python i `agents/mcp_server.py`. Udostępnione narzędzia: `list_agents`, `send_agent_message`, `read_agent_inbox`. MCP daje dostęp do skrzynek — podłączaj tylko zaufanego klienta.

## Ważne ograniczenia

1. To jest prawdziwy kod transportu i kolejki, ale nie instaluje czterech modeli AI.
2. Wysyłka i faktyczne przetworzenie poleceń przez zewnętrznych agentów wymagają poprawnego URL, zgodnego endpointu i autoryzacji.
3. Bezpieczeństwo: nie dodajemy root/admin, autostartu ani wykonywania arbitralnego PowerShell przez agentów.
4. Zadania, historia, obsługa workerów, streaming i prawdziwa komunikacja 24/7 wymagają dodatkowych procesów oraz potwierdzonych usług.

## Panel dotykowy Windows

Uruchom `scripts/Launch-TouchWorkspace.ps1` (Windows PowerShell 5.1, WPF). Panel pozwala wybierać odbiorcę palcem i wysyłać wiadomości do lokalnej skrzynki. Instrukcja: [ui/README.md](../ui/README.md). Panel działa niezależnie od zewnętrznego backendu, ale **bez sprawnego API agentów nie generuje ich odpowiedzi**.

## Odświeżanie i responsywność dotykowego czatu

Panel wyświetla faktyczny zapis historii z SQLite i automatycznie odświeża go co 8 sekund. Dla lepszej responsywności HTTP przyjmuje wysyłane wiadomości do lokalnej kolejki i zwraca **202 Accepted**; zewnętrzny backend obsługiwany jest osobnym workerem. Stan `queued` nie oznacza, że agent rozpoczął pracę. Stan `accepted` potwierdza jedynie odbiór przez bramę; `failed` oznacza błąd transportu. Historia jest aktualizowana w kolejnym odświeżeniu. Gdy serwer jest zatrzymany, panel dotykowy dalej udostępnia funkcje Windows.
