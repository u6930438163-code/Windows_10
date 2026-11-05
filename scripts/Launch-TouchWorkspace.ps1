#Requires -Version 5.1
<#
.SYNOPSIS
  Uruchamia lokalny backend i pulpit dotykowy w jednej sesji PowerShell.
.DESCRIPTION
  Wspolny token jest przekazywany przez środowisko procesów potomnych, nie przez argumenty CLI.
  Po zamknięciu panelu uruchomiony tu backend jest zatrzymywany.
.EXAMPLE
  powershell.exe -NoProfile -File .\scripts\Launch-TouchWorkspace.ps1
#>
[CmdletBinding()]
param([switch]$WithoutAgentServer)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($env:OS -ne "Windows_NT") { throw "Wymagany Windows." }

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ui = Join-Path $root "ui\TouchShell.ps1"
$server = Join-Path $root "agents\agentctl.py"
if (-not (Test-Path -LiteralPath $ui)) { throw "Nie znaleziono ui\TouchShell.ps1." }

$serverProcess = $null
$originalToken = [Environment]::GetEnvironmentVariable("WINDOWS10_LOCAL_TOKEN", "Process")
try {
    if (-not $WithoutAgentServer) {
        $python = Get-Command python -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $server)) { throw "Nie znaleziono agents\agentctl.py." }
        $env:WINDOWS10_LOCAL_TOKEN = [guid]::NewGuid().ToString("N")
        $serverProcess = Start-Process -FilePath $python.Source -ArgumentList @(
            ('"' + $server + '"'), 'serve', '--port', '8765'
        ) -PassThru -WindowStyle Minimized
        Start-Sleep -Milliseconds 700
        $serverProcess.Refresh()
        if ($serverProcess.HasExited) { throw "Nie uruchomiono lokalnego serwera agentów." }
        Write-Host "Lokalny serwer agentów działa na 127.0.0.1:8765."
    } else {
        Write-Host "Panel uruchomiony bez automatycznego serwera agentów."
    }

    $powershellExe = Join-Path $PSHOME "powershell.exe"
    $uiProcess = Start-Process -FilePath $powershellExe -ArgumentList @(
        '-NoProfile', '-STA', '-File', ('"' + $ui + '"')
    ) -PassThru
    Write-Host "Pulpit dotykowy uruchomiony. Zamknij jego okno, aby zakonczyc te sesje."
    $uiProcess.WaitForExit()
}
finally {
    if ($null -ne $serverProcess) {
        $serverProcess.Refresh()
        if (-not $serverProcess.HasExited) { Stop-Process -Id $serverProcess.Id -ErrorAction SilentlyContinue }
    }
    if ($null -eq $originalToken) {
        [Environment]::SetEnvironmentVariable("WINDOWS10_LOCAL_TOKEN", $null, "Process")
    } else { $env:WINDOWS10_LOCAL_TOKEN = $originalToken }
}
