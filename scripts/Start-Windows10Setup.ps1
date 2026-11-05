#Requires -Version 5.1
<#
.SYNOPSIS
  Przygotuj i uruchom czysta instalacje Windows 10 w nowej maszynie Hyper-V.
.DESCRIPTION
  Domyslnie wyłącznie pokazuje plan: nie tworzy ani nie uruchamia VM.
  -Create tworzy nowa maszyne z ISO po potwierdzeniu.
  -Boot uruchamia instalator z ISO (wymaga -Create).
  Nie instaluje aplikacji OpenAI, nie zmienia istniejących VM ani dyskow hosta.
.EXAMPLE
  .\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso"
.EXAMPLE
  .\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso" -Create -Boot
#>
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$IsoPath,

    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,60}$')]
    [string]$VMName = "Windows10Clean",

    [string]$Destination = "$env:PUBLIC\Documents\Hyper-V",

    [switch]$Create,
    [switch]$Boot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Boot -and -not $Create) {
    throw "Uruchomienie instalatora (-Boot) wymaga jawnego -Create."
}
if ($env:OS -ne "Windows_NT") {
    throw "Ten skrypt dziala tylko na hoście Windows z Hyper-V."
}

$isoItem = Get-Item -LiteralPath $IsoPath -ErrorAction Stop
if ($isoItem.PSIsContainer -or $isoItem.Extension -ine ".iso") {
    throw "Wybierz legalnie pobrany plik .iso Windows 10."
}
if ($isoItem.Length -lt 1GB) {
    throw "ISO ma mniej niz 1 GB. Sprawdz, czy to pelny obraz instalacyjny."
}
$isoFullPath = $isoItem.FullName

$os = Get-CimInstance Win32_OperatingSystem
$systemDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
$hyperv = Get-Command New-VM -ErrorAction SilentlyContinue
if (-not $hyperv) {
    throw "Nie znaleziono Hyper-V. Wymagany jest host Windows Pro/Enterprise/Education z aktywnym Hyper-V."
}

$existing = Get-VM -Name $VMName -ErrorAction SilentlyContinue
if ($null -ne $existing) {
    throw "Maszyna $VMName juz istnieje. Nic nie zostalo zmienione; wybierz inna nazwe."
}

$sha = (Get-FileHash -LiteralPath $isoFullPath -Algorithm SHA256).Hash
$vmScript = Join-Path $PSScriptRoot "New-Windows10VM.ps1"
if (-not (Test-Path -LiteralPath $vmScript)) {
    throw "Brak skryptu New-Windows10VM.ps1 w repozytorium."
}

Write-Host ""
Write-Host "=== WINDOWS 10 | INSTALACJA W HYPER-V ===" -ForegroundColor Cyan
Write-Host "Host: $($os.Caption)"
Write-Host "Obraz: $isoFullPath"
Write-Host "SHA256: $sha"
Write-Host "Maszyna: $VMName"
Write-Host "Dysk VHDX: 64 GB, RAM: 4 GB, 2 vCPU, Gen2"
if ($null -ne $systemDrive) {
    $free = [math]::Round($systemDrive.FreeSpace / 1GB, 1)
    Write-Host "Wolne miejsce dysku systemowego: $free GB"
}
Write-Host "To jest weryfikacja integralnosci; suma SHA256 bez oficjalnego wzorca nie potwierdza autentycznosci."
Write-Host "Licencja/aktywacja Windows 10 nie jest zawarta w repozytorium."
Write-Host ""

if (-not $Create) {
    Write-Host "TRYB PLANU: nic nie utworzono ani nie uruchomiono." -ForegroundColor Yellow
    Write-Host 'Aby utworzyc nowa VM i uruchomic instalator:'
    Write-Host '  .\scripts\Start-Windows10Setup.ps1 -IsoPath "C:\ISO\Win10.iso" -Create -Boot'
    return
}

$target = Join-Path ([IO.Path]::GetFullPath($Destination)) $VMName
if (-not $PSCmdlet.ShouldProcess($target, "Utworz nowa maszyne Hyper-V z Windows 10 ISO")) {
    return
}

# Wewnetrzny skrypt ma wlasny mechanizm potwierdzenia; tutaj zgodę juz uzyskano.
& $vmScript -IsoPath $isoFullPath -Name $VMName -Destination $Destination -Create -Confirm:$false

if (-not (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
    throw "Nie wykryto utworzonej VM. Instalator nie zostanie uruchomiony."
}

if ($Boot) {
    if ($PSCmdlet.ShouldProcess($VMName, "Uruchom VM z ISO i rozpocznij interaktywna instalacje")) {
        Start-VM -Name $VMName
        Write-Host "VM uruchomiona. Otworz Hyper-V Manager i polacz sie z $VMName."
        Write-Host "Instalacje Windows, wybor dysku VHDX i aktywacje wykonuje sie w kreatorze Microsoft."
    }
} else {
    Write-Host "VM utworzona, ale nie uruchomiona. Aby wystartowac:"
    Write-Host "  Start-VM -Name '$VMName'"
}
