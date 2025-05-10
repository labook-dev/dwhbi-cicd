<#
.SYNOPSIS
    Modul pro nacitani funkci ze slozek 'public' a 'private'.

.DESCRIPTION
    Tento modul nacita vsechny .ps1 soubory ze slozek 'public' a 'private' a dot-source je, aby byly dostupne jako soucast modulu.

.NOTES
    Autor: [Tve jmeno]
    Datum: [Aktualni datum]
#>

# Ziskani cesty ke slozce skriptu
$scriptRoot = $psScriptRoot

# Definice slozek pro verejne a soukrome funkce
$publicSubfolder = "public"
$privateSubfolder = "private"

$publicPath = Join-Path -Path $scriptRoot -ChildPath $publicSubfolder
$privatePath = Join-Path -Path $scriptRoot -ChildPath $privateSubfolder

# Kontrola existence slozek
if (-not (Test-Path -Path $publicPath)) {
    Write-Error "Slozka s verejnymi funkcemi nebyla nalezena: $publicPath"
    return
}

if (-not (Test-Path -Path $privatePath)) {
    Write-Error "Slozka se soukromymi funkcemi nebyla nalezena: $privatePath"
    return
}

# Nacteni vsech .ps1 souboru z verejnych a soukromych slozek
$publicFunctionFiles = Get-ChildItem -Path $publicPath -Filter *.ps1 -Recurse -File
$privateFunctionFiles = Get-ChildItem -Path $privatePath -Filter *.ps1 -Recurse -File

# Spojeni kolekci publicFunctionFiles a privateFunctionFiles
$allFunctionFiles = @()
$allFunctionFiles += $publicFunctionFiles
$allFunctionFiles += $privateFunctionFiles

foreach ($file in $allFunctionFiles) {
    try {
        Write-Verbose "Nacitam funkci ze souboru: $($file.FullName)"
        . $file.FullName
    } catch {
        Write-Error "Chyba pri nacitani souboru $($file.FullName): $($_.Exception.Message)"
    }
}

# Export nazvu funkci z verejnych slozek (bez pripony)
$exportedFunctions = $publicFunctionFiles.BaseName | Sort-Object -Unique
Export-ModuleMember -Function $exportedFunctions
