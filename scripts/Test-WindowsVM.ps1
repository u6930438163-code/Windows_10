#Requires -Version 5.1
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$hypervCmd = Get-Command New-VM -ErrorAction SilentlyContinue
$hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue

[pscustomobject]@{
    WindowsName             = $os.Caption
    OSArchitecture          = $os.OSArchitecture
    HyperVFeatureState      = if ($null -eq $hypervFeature) { 'unavailable' } else { [string]$hypervFeature.State }
    HyperVCmdletsAvailable  = $null -ne $hypervCmd
    VMMonitorModeExtensions = if ($null -eq $cpu) { $null } else { $cpu.VMMonitorModeExtensions }
    VirtualizationFirmware  = if ($null -eq $cpu) { $null } else { $cpu.VirtualizationFirmwareEnabled }
    SecondLevelAddressTranslation = if ($null -eq $cpu) { $null } else { $cpu.SecondLevelAddressTranslationExtensions }
} | Format-List
Write-Host 'Hyper-V wymaga Windows 10 Pro/Enterprise, wspieranego CPU i odpowiedniej konfiguracji BIOS/UEFI.'
