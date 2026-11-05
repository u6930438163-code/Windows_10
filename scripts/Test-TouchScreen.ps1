#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($env:OS -ne "Windows_NT") { throw "Wymagany jest Windows." }

Write-Host "Windows 10 — diagnostyka obsługi dotyku (tylko odczyt)" -ForegroundColor Cyan
$devices = @(Get-CimInstance Win32_PnPEntity | Where-Object {
    $_.Name -match 'touch|dotyk|digitizer|digitiser|screen HID'
} | Select-Object Name, Status, PNPClass)

if ($devices.Count -eq 0) {
    Write-Warning "Nie wykryto urządzenia o nazwie sugerującej panel dotykowy. Nazwy sterowników różnią się między producentami."
} else {
    $devices | Format-Table -AutoSize
}

Write-Host ""
Write-Host "Prawdziwy dotyk wymaga panelu dotykowego i jego sterownika." -ForegroundColor Yellow
Write-Host "Tablet mode: Centrum akcji > Rozwiń > Tryb tabletu (Windows 10)."
Write-Host "Klawiatura dotykowa: przytrzymaj pasek zadań > Pokaż przycisk klawiatury dotykowej."
Write-Host "Skalowanie: Ustawienia > System > Ekran."
Write-Host "Kalibracja: Panel sterowania > Sprzęt i dźwięk > Ustawienia komputera typu Tablet."
