# Windows_10 — pełnoekranowy pulpit dotykowy

To dodatkowy, odwracalny **panel startowy WPF** dla Windows 10. Obsługuje dotyk, rysik i mysz; korzysta z natywnych akcji Windows. Nie podmienia Eksploratora, nie zmienia rejestru i nie wyłącza zabezpieczeń.

## Uruchamianie

Na komputerze z Windows 10, z repozytorium:

```powershell
.\scripts\Test-TouchScreen.ps1
.\scripts\Start-TouchShell.ps1
```

Można też uruchomić bezpośrednio:

```powershell
powershell.exe -NoProfile -STA -File .\ui\TouchShell.ps1
```

**Pokaż pulpit** minimalizuje nakładkę. **Zamknij nakładkę** kończy program. Klawisz Escape też minimalizuje (przy podłączonej klawiaturze). Nic nie uruchamia się automatycznie przy starcie systemu.

## Funkcje dotykowe

Duże przyciski uruchamiają:
- Eksplorator plików, Ustawienia, panel ustawień wyświetlania, skróty aplikacji Windows.
- Klawiaturę dotykową (`TabTip.exe`) lub alternatywną ekranową (`osk.exe`).
- PowerShell, Menedżera zadań.
- ChatGPT, Codex i przeglądarkę (strony oficjalne).
- Panel czatu Alex/Aria/Astyria/Aurelius oraz odbiór wiadomości.

Wbudowane gesty systemowe Windows (przesuwanie, przewijanie, dotknięcie, długie przytrzymanie i powiększanie) działają na sprzęcie obsługującym dotyk; nasza aplikacja korzysta ze standardowej obsługi dotyku WPF. **Nie modyfikujemy zachowania wszystkich obcych aplikacji** i nie instalujemy wirtualnych sterowników dotyku.

## Włączenie dotyku dla całego Windows

1. Upewnij się, że panel dotykowy jest wykrywany i sterownik działa. W systemie VM potrzebny jest host/klient z przekazywaniem dotyku.
2. Windows 10: Otwórz Centrum akcji (obok zegara), rozwiń i wybierz **Tryb tabletu**. Jeśli nie widzisz przycisku, sprawdź ustawienia szybkich akcji.
3. Przytrzymaj palcem pasek zadań, następnie wybierz **Pokaż przycisk klawiatury dotykowej**.
4. Otwórz **Ustawienia → Urządzenia → Pisanie** i wybierz automatyczne pokazywanie klawiatury w odpowiednich warunkach.
5. Otwórz **Ustawienia → System → Ekran**, dostosuj skalowanie i rozmiar tekstu do palca.
6. Używaj natywnych gestów Windows. Przy problemach sterownika sprawdź Menedżer urządzeń → Urządzenia interfejsu HID.

Oficjalne instrukcje Microsoft:
- [Tryb tabletu Windows 10](https://support.microsoft.com/en-us/windows/hardware/input-devices/turn-tablet-mode-on-or-off-in-windows)
- [Klawiatura dotykowa](https://support.microsoft.com/en-us/windows/hardware/input-devices/enable-and-disable-the-touch-keyboard-in-windows)
- [Gesty dotykowe](https://support.microsoft.com/pl-pl/windows/hardware/input-devices/touch-gestures-for-windows)

## Łączenie z lokalnym czatem agentów

Panel wywołuje istniejące lokalne API (`agents/agentctl.py`). W **tym samym oknie PowerShell** ustaw token (przykład):

```powershell
$env:WINDOWS10_LOCAL_TOKEN=[guid]::NewGuid().ToString('N')
python agents/agentctl.py serve --port 8765
```

W **drugim oknie PowerShell** ustaw *ten sam token* dla panelu (w systemie token nie przenosi się automatycznie między niezależnymi oknami):

```powershell
$env:WINDOWS10_LOCAL_TOKEN="WKLEJ-TEN-SAM-LOKALNY-TOKEN"
.\scripts\Start-TouchShell.ps1
```

Panel działa również bez serwera agentów — przyciski systemowe są niezależne. Bez zewnętrznego backendu AI wiadomości pozostają lokalne i nie generują odpowiedzi modeli. `WINDOWS10_LOCAL_TOKEN` jest sekretem — nie zapisuj go w repo.

## Ograniczenia

- Realny dotyk wymaga sprzętowej obsługi dotyku albo poprawnej obsługi przez sesję zdalną. Wirtualny Windows z samym emulowanym wskaźnikiem myszy nie zyskuje funkcji multitouch.
- Tryb tabletu dotyczy Windows 10 (Windows 11 zachowuje się inaczej).
- Zakończenie standardowego wsparcia Windows 10: **14 października 2025 r.** Używaj aktualizacji ESU, jeśli są dostępne dla Twojej edycji, lub wspieranego systemu.
