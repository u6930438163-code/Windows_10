#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$systemDisk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"

[pscustomobject]@{
    ComputerName     = $env:COMPUTERNAME
    WindowsEdition   = $os.Caption
    Version          = $os.Version
    Build            = $os.BuildNumber
    Architecture     = $os.OSArchitecture
    LastBootUpTime   = $os.LastBootUpTime
    TotalMemoryGB    = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    FreeDiskGB       = if ($null -ne $systemDisk) { [math]::Round($systemDisk.FreeSpace / 1GB, 2) } else { $null }
    SupportNote      = 'Standardowy Windows 10: koniec wsparcia 2025-10-14; sprawdz ESU.'
} | Format-List
