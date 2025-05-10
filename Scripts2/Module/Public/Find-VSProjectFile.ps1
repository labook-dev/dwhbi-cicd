function Find-VSProjectFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StartFileWithName
    )

    # Lokální proměnná s příponami projektových souborů
    $Extensions = @("*.dtproj", "*.rptproj", "*.dwproj") # SSIS, SSRS, SSAS project extensions
    Write-Verbose "Definovany seznam pripon projektovych souboru: $Extensions"

    # Kontrola, zda soubor existuje
    if (-not (Test-Path -Path $StartFileWithName)) {
        Write-Verbose "Soubor '$StartFileWithName' neexistuje."
        throw "Soubor '$StartFileWithName' neexistuje."
    }
    Write-Verbose "Soubor '$StartFileWithName' existuje."

    # Ziskani slozky ze zadane cesty k souboru
    $currentFolder = Split-Path -Path $StartFileWithName -Parent
    Write-Verbose "Aktualni slozka nastavena na: $currentFolder"

    # Prohledavani slozky smerem nahoru
    while ($currentFolder -ne (Split-Path -Path $currentFolder -Parent)) {
        Write-Verbose "Prohledavam slozku: $currentFolder"
        foreach ($extension in $Extensions) {
            Write-Verbose "Hledam soubory s priponou: $extension"
            $projectFile = Get-ChildItem -Path $currentFolder -Filter $extension -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($projectFile) {
                Write-Verbose "Projektovy soubor nalezen: $($projectFile.FullName)"
                return $projectFile.FullName
            }
        }
        # Prechod do nadrazene slozky
        $currentFolder = Split-Path -Path $currentFolder -Parent
        Write-Verbose "Prechod do nadrazene slozky: $currentFolder"
    }

    Write-Verbose "Projektovy soubor nebyl nalezen."
    return $null
}
