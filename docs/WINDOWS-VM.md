# Czysta maszyna wirtualna Windows 10 (Hyper-V)

Repozytorium nie zawiera obrazu Windows 10 ani licencji. VM zostanie uruchomiona **tylko na Twoim komputerze** po podaniu legalnie pobranego ISO.

## Wymagania

- Host: Windows 10 Pro/Enterprise (ew. wspierany Windows 11 Pro/Enterprise), nie Windows 10 Home.
- Hyper-V, procesor x64 z SLAT, wirtualizacja w BIOS/UEFI, wystarczająca pamięć i miejsce na dysku.
- PowerShell uruchomiony z uprawnieniami wymaganymi przez Hyper-V.
- Zapas miejsca: co najmniej 64 GB na wirtualny dysk (dynamiczny) i dodatkowe miejsce na system.
- Nie korzystaj z Windows 10 bez wymaganych aktualizacji zabezpieczeń; standardowe wsparcie zakończyło się 14.10.2025.

Dokumentacja Microsoft: https://learn.microsoft.com/windows-server/virtualization/hyper-v/get-started/install-hyper-v

## Diagnostyka

```powershell
.\scripts\Test-WindowsVM.ps1
```

## Plan bez zmian

```powershell
.\scripts\New-Windows10VM.ps1 -IsoPath "D:\ISO\Win10.iso"
```

## Faktyczne utworzenie (wymaga decyzji administratora)

```powershell
.\scripts\New-Windows10VM.ps1 -IsoPath "D:\ISO\Win10.iso" -Create -WhatIf
.\scripts\New-Windows10VM.ps1 -IsoPath "D:\ISO\Win10.iso" -Create
```

Skrypt tworzy maszynę Gen2, 4 GB RAM, 2 vCPU, dynamiczny dysk VHDX 64 GB, dołącza ISO i ustawia start z DVD. Nie uruchamia systemu, nie instaluje Windows i nie usuwa istniejących VM.

Po sprawdzeniu ustawień administrator może uruchomić: `Start-VM -Name Windows10Clean`, a następnie wykonać standardową instalację Windows. Kwestie przełącznika sieciowego skonfiguruj oddzielnie, nie wystawiaj nieaktualizowanego Windows 10 na publiczny Internet.
