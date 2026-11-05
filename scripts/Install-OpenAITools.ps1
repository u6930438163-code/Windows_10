#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$InstallChatGPT,
    [switch]$InstallCodexCLI,
    [switch]$InstallPythonSDK,
    [switch]$ConfigureDocsMCP
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not ($InstallChatGPT -or $InstallCodexCLI -or $InstallPythonSDK -or $ConfigureDocsMCP)) {
    Write-Host 'Dostepne opcje: -InstallChatGPT, -InstallCodexCLI, -InstallPythonSDK, -ConfigureDocsMCP'
    Write-Host 'Domyslnie skrypt niczego nie instaluje. Uzyj -WhatIf, aby zobaczyc plan.'
    Write-Host 'OpenAI CLI: oficjalna instrukcja ZIP https://developers.openai.com/api/reference/cli'
    return
}

if ($InstallChatGPT) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'Brak winget. Zainstaluj App Installer / Microsoft Store.'
    }
    if ($PSCmdlet.ShouldProcess('Microsoft Store: 9PLM9XGG6VKS', 'Instalacja oficjalnej aplikacji ChatGPT/Codex')) {
        & winget install --id 9PLM9XGG6VKS --source msstore --exact --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "winget zakonczyl sie kodem $LASTEXITCODE" }
    }
}

if ($InstallCodexCLI) {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'Codex CLI wymaga Node.js/npm.' }
    if ($PSCmdlet.ShouldProcess('@openai/codex', 'npm install -g')) {
        & npm install -g '@openai/codex@latest'
        if ($LASTEXITCODE -ne 0) { throw "npm zakonczyl sie kodem $LASTEXITCODE" }
    }
}

if ($InstallPythonSDK) {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw 'Zainstaluj Python 3.11+.' }
    $root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $venv = Join-Path $root '.venv'
    $pythonExe = Join-Path $venv 'Scripts\python.exe'
    if ($PSCmdlet.ShouldProcess($venv, 'Utworzenie venv i instalacja bibliotek OpenAI + MCP')) {
        & python -m venv $venv
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie utworzyc srodowiska Python.' }
        & $pythonExe -m pip install --upgrade openai openai-agents 'mcp>=2,<3'
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie zainstalowac SDK.' }
    }
}

if ($ConfigureDocsMCP) {
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { throw 'Najpierw zainstaluj Codex CLI.' }
    if ($PSCmdlet.ShouldProcess('Codex', 'Dodanie oficjalnego serwera dokumentacji OpenAI MCP')) {
        & codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
        if ($LASTEXITCODE -ne 0) { throw 'Nie udalo sie skonfigurowac Docs MCP.' }
    }
}
