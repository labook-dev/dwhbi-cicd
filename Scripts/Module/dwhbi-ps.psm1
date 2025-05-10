<#
.SYNOPSIS
    Modul pro načítání funkcí ze složek 'public' a 'private'.

.DESCRIPTION
    Tento modul načítá všechny .ps1 soubory ze složek 'public' a 'private' a dot-source je, aby byly dostupné jako součást modulu.

.NOTES
    Autor: [Tve jmeno]
    Datum: [Aktualni datum]
#>

# Ziskani cesty ke slozce skriptu
$scriptRoot = $psScriptRoot

# Definice složek pro veřejné a soukromé funkce
$publicSubfolder = "public"
$privateSubfolder = "private"

$publicPath = Join-Path -Path $scriptRoot -ChildPath $publicSubfolder
$privatePath = Join-Path -Path $scriptRoot -ChildPath $privateSubfolder

# Kontrola existence složek
if (-not (Test-Path -Path $publicPath)) {
    Write-Error "Složka s veřejnými funkcemi nebyla nalezena: $publicPath"
    return
}

if (-not (Test-Path -Path $privatePath)) {
    Write-Error "Složka se soukromými funkcemi nebyla nalezena: $privatePath"
    return
}

# Načtení všech .ps1 souborů z veřejných a soukromých složek
$publicFunctionFiles = Get-ChildItem -Path $publicPath -Filter *.ps1 -Recurse -File
$privateFunctionFiles = Get-ChildItem -Path $privatePath -Filter *.ps1 -Recurse -File

# Spojení kolekcí publicFunctionFiles a privateFunctionFiles
$allFunctionFiles = @()
$allFunctionFiles += $publicFunctionFiles
$allFunctionFiles += $privateFunctionFiles

foreach ($file in $allFunctionFiles) {
    try {
        Write-Verbose "Načítám funkci ze souboru: $($file.FullName)"
        . $file.FullName
    } catch {
        Write-Error "Chyba při načítání souboru $($file.FullName): $($_.Exception.Message)"
    }
}

# Export názvů funkcí z veřejných složek (bez přípony)
$exportedFunctions = $publicFunctionFiles.BaseName | Sort-Object -Unique
Export-ModuleMember -Function $exportedFunctions
