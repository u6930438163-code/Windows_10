# Windows 10 — instalacja z kodu repozytorium

**Repozytorium GitHub nie jest dyskiem systemowym ani komputerem.** Nie można w nim zainstalować działającego Windows 10. Zawiera jednak instalator, który na zgodnym serwerze Linux x86_64 z KVM przygotowuje nową VM i uruchamia oryginalny instalator Microsoft.

## Warunki

- Osobny serwer VPS/dedykowany x86_64 z Debian 13, dostępem do `/dev/kvm` i prawem uruchamiania Windows 10 (licencja klienta Windows w chmurze może wymagać osobnych uprawnień).
- Minimum 4 GB RAM dla Windows i zapas dla hosta; zalecane 8 GB RAM serwera, 2+ vCPU i wolne miejsce na dysku.
- Legalny obraz **Windows 10 22H2 64-bit ISO** z [Microsoft](https://www.microsoft.com/pl-pl/software-download/windows10iso). Obraz nie jest umieszczany w repozytorium.
- Działający bezpieczny dostęp do zdalnego ekranu przez **uwierzytelnione HTTPS** (np. konsola operatora, albo wcześniej skonfigurowany reverse proxy z logowaniem i MFA). Nie udostępniaj publicznie portów VNC i noVNC.

## Instalacja hosta Debian 13 — polecenia

W terminalu serwera (po skonfigurowaniu konta z dostępem):

```bash
git clone https://github.com/u6930438163-code/Windows_10.git
cd Windows_10
bash scripts/linux/check-kvm.sh
```

Jeśli brakuje pakietów, a serwer ma Debian/Ubuntu, wykonaj świadomie:

```bash
sudo bash scripts/linux/check-kvm.sh --install-deps
```

Umieść legalnie pobrany ISO **poza repozytorium**, np. `/opt/iso/Win10.iso`, i sprawdź oryginalne SHA-256 (jeśli znasz wartość z Microsoft).

### Bezpieczny plan (nic nie tworzy)

```bash
bash scripts/linux/windows10-kvm.sh --iso /opt/iso/Win10.iso
```

### Rozpoczęcie instalacji Windows na nowej VM

```bash
bash scripts/linux/windows10-kvm.sh --iso /opt/iso/Win10.iso --start
```

Opcjonalnie dodaj `--sha256` z **oficjalną sumą dokładnie tej wersji ISO**. Skrypt przygotowuje `vm/Windows10.qcow2` (64 GB), 4 GB RAM i 2 vCPU, uruchamia QEMU/KVM oraz serwer HTML5 noVNC. Zmiana dotyczy tylko **nowego dysku wirtualnego**, nie fizycznych dysków serwera. Katalog `vm/` jest ignorowany przez Git.

**Lokalny podgląd na serwerze:** `http://127.0.0.1:6080/vnc.html`. Ten adres nie zadziała bezpośrednio na telefonie — wymaga odrębnego, uwierzytelnionego dostępu przez HTTPS. Panel bez zabezpieczeń celowo nie jest wystawiany w Internecie.

## Z telefonu

1. Uruchom w przeglądarce panel zdalnego dostępu do serwera, zabezpieczony HTTPS i logowaniem.
2. Otwórz ekran noVNC chroniony przez operatora lub wcześniej przygotowany reverse proxy.
3. W instalatorze Microsoft wybierz instalację niestandardową i **pusty dysk wirtualny 64 GB**.
4. Dokończ konfigurację, przeprowadź aktywację zgodnie z licencją i zweryfikuj pulpit Windows.

Pierwsze uruchomienie z ISO jest ustawione tylko na jeden rozruch VM. Przy restarcie instalator powinien kontynuować z wirtualnego dysku.

## Czego instalator nie robi

- Nie pobiera Windows z nieoficjalnych serwisów i nie dołącza licencji ani klucza.
- Nie zamawia ani nie opłaca VPS, nie podłącza zewnętrznego konta.
- Nie instaluje Windows bez dostarczenia ISO i hosta z KVM.
- Nie otwiera publicznych portów 5901/6080 i nie pomija zabezpieczeń.
- Nie instaluje agentów ani aplikacji OpenAI — dotyczy **wyłącznie Windows 10**.

## Wsparcie systemu

Standardowe wsparcie Windows 10 zakończyło się 14 października 2025 r. Do użytku w sieci zadbaj o odpowiednią opcję aktualizacji bezpieczeństwa ESU lub rozważ wspierany Windows.

Źródła: [Debian QEMU](https://packages.debian.org/trixie/qemu-system-x86), [Debian noVNC](https://packages.debian.org/trixie/novnc), [Microsoft ISO](https://www.microsoft.com/pl-pl/software-download/windows10iso).

Wariant na hoście Windows/Hyper-V: [WINDOWS-VM.md](WINDOWS-VM.md). Wariant z konsolą operatora VPS: [INSTALACJA-CHMURA-ANDROID.md](INSTALACJA-CHMURA-ANDROID.md).
