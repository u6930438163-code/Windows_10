#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$IsoPath,
    [string]$Name = 'Windows10Clean',
    [string]$Destination = "$env:PUBLIC\Documents\Hyper-V",
    [switch]$Create
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) { throw 'Nie znaleziono podanego ISO.' }
if ([IO.Path]::GetExtension($IsoPath) -ine '.iso') { throw 'Wymagany plik ISO.' }
if (-not (Get-Command New-VM -ErrorAction SilentlyContinue)) {
    throw 'Brak Hyper-V PowerShell. Hyper-V nie jest dostępny na Windows 10 Home.'
}
if (Get-VM -Name $Name -ErrorAction SilentlyContinue) { throw "Maszyna $Name juz istnieje." }

$destinationFull = [IO.Path]::GetFullPath($Destination)
$vmPath = Join-Path $destinationFull $Name
$vhdPath = Join-Path $vmPath "$Name.vhdx"

Write-Host "VM: $Name"
Write-Host "ISO: $IsoPath"
Write-Host "Sciezka VM: $vmPath"
Write-Host 'Konfiguracja: Generation 2, RAM 4 GB, dysk 64 GB, 2 vCPU, bez automatycznego uruchamiania.'
if (-not $Create) {
    Write-Host 'Tylko podglad. Aby utworzyc, dodaj -Create (ewentualnie -WhatIf do testu).'
    return
}
if ($PSCmdlet.ShouldProcess($vmPath, "Utworzenie VM Hyper-V $Name")) {
    New-Item -ItemType Directory -Path $vmPath -Force | Out-Null
    New-VM -Name $Name -Generation 2 -MemoryStartupBytes 4GB -NewVHDPath $vhdPath -NewVHDSizeBytes 64GB -Path $vmPath | Out-Null
    Set-VMProcessor -VMName $Name -Count 2
    $dvd = Add-VMDvdDrive -VMName $Name -Path (Resolve-Path -LiteralPath $IsoPath).ProviderPath -PassThru
    Set-VMFirmware -VMName $Name -FirstBootDevice $dvd
    Write-Host "Maszyna jest utworzona, ale NIE uruchomiona. Uruchom recznie: Start-VM -Name '$Name'"
}
