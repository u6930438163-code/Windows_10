#Requires -Version 5.1
[CmdletBinding()]
param([switch]$DiagnoseOnly)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ($DiagnoseOnly) {
    & (Join-Path $root "scripts\Test-TouchScreen.ps1")
    return
}
$uiPath = Join-Path $root "ui\TouchShell.ps1"
if (-not (Test-Path -LiteralPath $uiPath -PathType Leaf)) {
    throw "Nie znaleziono ui\TouchShell.ps1"
}
# WPF wymaga procesu PowerShell w STA; nie modyfikujemy systemowego pulpitu.
Start-Process -FilePath (Join-Path $PSHOME "powershell.exe") -ArgumentList @(
    "-NoProfile", "-STA", "-ExecutionPolicy", "RemoteSigned", "-File", ('"' + $uiPath + '"')
)
