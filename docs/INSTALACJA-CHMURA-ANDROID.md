# Pełny Windows 10 z samego telefonu — instalacja przez przeglądarkę

> **Stan:** metoda wdrożenia przygotowana, ale żadna maszyna nie została zamówiona, utworzona ani uruchomiona. Do dalszej instalacji wymagane jest konto u operatora VPS, serwer i uprawnienie/licencja pozwalające uruchamiać Windows 10 w chmurze.

## Rozwiązanie: VPS z KVM + własny obraz ISO + konsola noVNC

Schemat:

```text
Telefon Android (Chrome / Edge)
  -> panel dostawcy VPS (HTTPS + konto z 2FA)
  -> noVNC / HTML5 KVM (instalator i pulpit Windows)
  -> serwer w chmurze (KVM/x86-64, min. 2-4 vCPU, 4-8 GB RAM, 64+ GB dysku)
  -> Windows 10 64-bit z własnego oryginalnego ISO
```

**To rzeczywista maszyna wirtualna Windows**, a nie emulacja samego okna ani aplikacja ChatGPT. noVNC ma obsługę przeglądarek mobilnych i gestów dotykowych, które zwykle symulują kliknięcia myszy — nie gwarantuje natywnego wielodotyku Windows.

### Potwierdzone technicznie możliwości usług (nie potwierdzono licencji Windows 10)

| Dostawca | Panel i instalacja | Co trzeba sprawdzić przed zamówieniem |
| --- | --- | --- |
| [Virtuasys](https://www.virtuasys.eu/en/cloud/custom-iso-deployment) | ISO do 10 GB, HTML5 KVM/IPMI, instalacja Windows dopuszczona w dokumentacji | Czy konkretny pakiet ma wymagane zasoby; czy dopuszcza Windows 10 **kliencki**; jaka licencja i opłaty |
| [Victus Cloud](https://support.victuscloud.com/docs/vps-mount-custom-iso) | VPS KVM, uruchomienie własnego ISO, panel noVNC | Czy dopuszcza i wspiera Windows 10, jak przesłać ISO, licencja i zasady instalacji |

Nie zakładaj, że posiadanie zwykłego klucza Windows 10 Home/Pro wystarczy do legalnego uruchomienia na współdzielonym VPS. Microsoft opisuje osobne warunki dla wirtualnych pulpitów Windows Enterprise/VDA. Przed zakupem uzyskaj od operatora pisemne potwierdzenie możliwości instalacji i **poprawnego modelu licencjonowania**. Nie ma potwierdzonej darmowej opcji hostowanej maszyny Windows 10 spełniającej wszystkie wymagania.

Źródła:
- Microsoft — instalator Windows 10 ISO: https://www.microsoft.com/pl-pl/software-download/windows10iso
- Microsoft — aktywacja licencji Windows VDA: https://learn.microsoft.com/en-us/windows/deployment/vda-subscription-activation
- noVNC — zgodność z Android: https://novnc.com/
- Windows 10 — koniec wsparcia: https://support.microsoft.com/en-us/windows/deployment/updates-lifecycle/windows-10-support-has-ended-on-october-14-2025

## Procedura wyłącznie z telefonu

1. Zaloguj się do konta **nowego** VPS z KVM oraz konsolą HTML5/noVNC (najpierw potwierdź w pomocy/operatorze zgodność z Windows 10 i licencję).
2. Wybierz host w Europie, parametry co najmniej 2 vCPU, 4 GB RAM (wygodniej 8 GB), 64–80 GB dysku. Dysk/ISO nie są udostępnione przez repozytorium GitHub.
3. Na oficjalnej witrynie Microsoft wybierz **Windows 10 22H2, polski, 64-bit**. Link do pobrania ISO jest czasowy (24 godziny); nie wklejaj go do publicznego GitHub ani przypadkowych serwisów.
4. W panelu serwera skorzystaj z opcji **Mount/Attach ISO**, a jeśli panel dopuszcza tylko link URL, użyj legalnego, prywatnego bezpośredniego łącza do ISO. Nie udostępniaj go publicznie i przestrzegaj warunków pobierania Microsoft.
5. Ustaw rozruch z CD/DVD/ISO i otwórz przycisk **Console / HTML5 KVM / noVNC** w mobilnej przeglądarce. Przy problemach obróć telefon poziomo, wybierz widok komputerowy i użyj narzędzi klawiatury ekranowej noVNC.
6. W instalatorze Windows wybierz język polski, prawidłową edycję i **Instalacja niestandardowa (Custom)**, a następnie **wyłącznie nowy pusty dysk VPS**. Instalacja na istniejącym dysku kasuje jego dane; nie wykonuj jej na serwerze z innymi projektami.
7. Po skopiowaniu plików odłącz ISO, ustaw boot z dysku VPS i uruchom ponownie.
8. W konsoli noVNC dokończ początkową konfigurację Windows i aktywuj go tylko przy użyciu prawidłowej licencji uprawniającej do takiego hostingu.
9. Zabezpiecz konto VPS (2FA), używaj wyłącznie zabezpieczonego panelu WWW. **Nie wystawiaj portów 3389 (RDP) ani 5900 (VNC) bezpośrednio do Internetu.** Zadbaj o kopie bezpieczeństwa. Jeśli operator wspiera bezpieczny dostęp do pulpitu po HTTPS, korzystaj z niego.
10. Gdy Windows działa, otwórz terminal w maszynie i pobierz przygotowany projekt `u6930438163-code/Windows_10` — opcjonalny pulpit dotykowy można uruchomić później. Sam pulpit z repo nie jest systemem instalacyjnym.

## Ważne: przeglądarka vs. aplikacja mobilna

- **noVNC**: działa w przeglądarkach mobilnych, często z dotykiem jako emulacją myszy. Wygodne do instalacji i awaryjnej obsługi, ale wolniejsze niż profesjonalny protokół pulpitu.
- **Microsoft Windows 365**: klient przeglądarkowy Windows 365 oficjalnie **nie jest dostępny na urządzeniach mobilnych**; na telefonie wymaga aplikacji, więc nie spełnia warunku „tylko przeglądarka”. Źródło: https://learn.microsoft.com/en-us/windows-365/end-user-access-cloud-pc
- **Shadow PC**: ma zdalny Windows uruchamiany w przeglądarce, ale usługa nie wymienia Polski jako wspieranego kraju i nie gwarantuje wyboru licencji/wersji Windows 10. Źródła: https://support.shadow.tech/hc/en-us/articles/32731806257297-Shadow-PC-in-Browser-FAQ oraz https://support.shadow.tech/hc/en-us/articles/33667839889169-What-is-Shadow

## Co pozostaje do zrobienia

- Zweryfikować ofertę i licencję wybranego operatora.
- Utworzyć własny serwer VPS.
- Udostępnić ISO w panelu operatora i otworzyć konsolę.
- Ukończyć instalację Microsoft, sprawdzić pulpit i aktywację.

**Bez wykupionej lub udostępnionej maszyny Windows nie można faktycznie zainstalować systemu jedynie wewnątrz rozmowy ChatGPT.**

Ważne bezpieczeństwo: zwykły Windows 10 stracił wsparcie 14 października 2025 r. Program ESU zależy od uprawnień i edycji. Dla serwera stale podłączonego do Internetu lepszy może być obsługiwany Windows 11 lub Windows Server.
