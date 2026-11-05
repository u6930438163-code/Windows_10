#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Create)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($env:OS -ne "Windows_NT") { throw "Wymagany Windows." }
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$launcher = Join-Path $root "scripts\Launch-TouchWorkspace.ps1"
$desktop = [Environment]::GetFolderPath("Desktop")
$linkPath = Join-Path $desktop "Windows_10 - Dotyk.lnk"
Write-Host "Skrót: $linkPath"
if (-not $Create) {
    Write-Host "Podgląd: użyj -Create, aby utworzyć skrót na pulpicie."
    return
}
if ($PSCmdlet.ShouldProcess($linkPath, "Utworzenie skrótu dla pulpitu dotykowego")) {
    $shell = New-Object -ComObject WScript.Shell
    $link = $shell.CreateShortcut($linkPath)
    $link.TargetPath = (Join-Path $PSHOME "powershell.exe")
    $link.Arguments = '-NoProfile -File "' + $launcher + '"'
    $link.WorkingDirectory = $root
    $link.Description = "Własny pulpit dotykowy Windows_10 i kanały AI"
    $link.IconLocation = "$env:SystemRoot\system32\shell32.dll,43"
    $link.Save()
    Write-Host "Utworzono skrót. Kliknij go albo dotknij dwukrotnie, aby uruchomić panel."
}
