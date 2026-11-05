#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$IsoPath,

    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[a-fA-F0-9]{64}$')]
    [string]$ExpectedSha256
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolved = (Resolve-Path -LiteralPath $IsoPath).ProviderPath
$file = Get-Item -LiteralPath $resolved
if ($file.PSIsContainer -or $file.Extension -ine '.iso') {
    throw 'Wskazana ścieżka musi prowadzić do pliku .iso.'
}

$hash = (Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash.ToUpperInvariant()
Write-Output "Plik: $resolved"
Write-Output "Rozmiar: $($file.Length) bajtow"
Write-Output "SHA-256: $hash"

if ($PSBoundParameters.ContainsKey('ExpectedSha256')) {
    if ($hash -eq $ExpectedSha256.ToUpperInvariant()) {
        Write-Output 'Wynik: HASH ZGODNY z podanym wzorcem.'
        exit 0
    }
    Write-Error 'Wynik: HASH NIEZGODNY. Nie instaluj systemu z tego obrazu przed wyjasnieniem roznicy.'
    exit 1
}
Write-Warning 'Nie podano hash wzorcowego. Obliczenie sumy nie potwierdza autentycznosci obrazu.'
