<#
.SYNOPSIS
    Zapisuje zadanou promennou jako parametr do JSON souboru v adresari Temp.

.DESCRIPTION
    Tento skript prijima nazev parametru a jeho hodnotu, vytvori JSON soubor v adresari Temp a zapise do nej tento parametr.

.PARAMETER ParameterName
    Nazev parametru, ktery bude zapsan do JSON souboru.

.PARAMETER ParameterValue
    Hodnota parametru, ktera bude zapsana dDWHBI-Write-ParameterToTempJsono JSON souboru.

.NOTES
    Autor: [Tve jmeno]
    Datum: [Aktualni datum]
#>

function DWHBI-Write-ParameterToTempJson{
    param (
        [Parameter(Mandatory = $true)]
        [string]$ParameterName,

        [Parameter(Mandatory = $true)]
        [string]$ParameterValue
    )

    # Cesta k adresari Temp
    $TempDir = "Temp"

    # Vytvoreni cesty k JSON souboru
    $JsonFilePath = Join-Path -Path $TempDir -ChildPath "parameters.json"

    # Nacteni existujiciho obsahu JSON souboru, pokud existuje
    if (Test-Path -Path $JsonFilePath) {
        $JsonContent = Get-Content -Path $JsonFilePath -Raw | ConvertFrom-Json
    } else {
        $JsonContent = @{}
    }

    if (-not (Test-Path -Path $JsonFilePath)) {
        Write-Error "DWHBI-Write-ParameterToTempJson: Nelze najit nebo vytvorit JSON soubor: $JsonFilePath."
    }

    # Pridani nebo aktualizace parametru
    $JsonContent.$ParameterName = $ParameterValue

    # Zapis do JSON souboru
    $JsonContent | ConvertTo-Json -Depth 10 | Set-Content -Path $JsonFilePath -Force

    Write-Output "Parametr '$ParameterName' byl zapsan do souboru: $JsonFilePath"
}
