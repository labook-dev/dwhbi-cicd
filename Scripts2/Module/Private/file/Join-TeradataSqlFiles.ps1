function Join-TeradataSqlFiles {
    <#
    .SYNOPSIS
    Spoji vice SQL souboru do jednoho vystupniho souboru.

    .DESCRIPTION
    Tato funkce nacte obsah vice SQL souboru, prida prikaz "GO" na konec kazdeho souboru (pokud chybi),
    a zapise je do jednoho vystupniho souboru.

    .PARAMETER SqlFiles
    Seznam cest k SQL souborum, ktere maji byt spojeny.

    .OUTPUTS
    Vraci cestu k vystupnimu souboru.

    .EXAMPLE
    Join-TeradataSqlFiles -SqlFiles @("file1.sql", "file2.sql")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$SqlFiles
    )

    try {
        # Skript zacina, vypis aktualni adresar
        Write-Verbose "Skript: Join-TeradataSqlFiles.ps1 Aktualni adresar: $(Get-Location)"
        $config = Get-FullConfig
        Write-Verbose "Konfigurace nactena."

        # Sestaveni cesty k artefaktum
        $ArtefaktFolder = Join-Path -Path $config.Path.Root -ChildPath $config.Path.Artefakt
        Write-Verbose "Cesta k artefaktum: $ArtefaktFolder"

        # Definice vystupniho souboru
        $OutputFilename = "TD.sql"
        $OutputFile = Join-Path -Path $ArtefaktFolder -ChildPath $OutputFilename
        Write-Verbose "Cesta k vystupnimu souboru: $OutputFile"

        # Validace konfigurace
        if (-not $ArtefaktFolder -or -not $OutputFilename) {
            Write-Verbose "Validace konfigurace selhala."
            throw "Neplatna konfigurace: Path nebo Filename je prazdne"
        }
        Write-Verbose "Validace konfigurace uspesna."

        # Vytvoreni prazdneho vystupniho souboru
        New-Item -Path $OutputFile -ItemType File -Force | Out-Null
        Write-Verbose "Vystupni soubor vytvoren."

        # Kontrola a vytvoreni slozky pro artefakty
        $folderCreated = Invoke-EnsureFolderExists -FolderPath $ArtefaktFolder
        Write-Verbose "Kontrola slozky pro artefakty dokoncena."

        if (-not $folderCreated) {
            Write-Verbose "Vytvoreni slozky selhalo."
            throw "Nelze vytvorit vystupni slozku: $ArtefaktFolder"
        }

        # Serazeni SQL souboru
        $sortedSqlFiles = $SqlFiles | Sort-Object
        Write-Verbose "SQL soubory serazeny."

        # Zpracovani kazdeho SQL souboru
        foreach ($sqlFile in $sortedSqlFiles) {
            Write-Verbose "Zpracovavam soubor: $sqlFile"
            $sqlContent = Get-Content -Path $sqlFile -Raw -Encoding UTF8
            Write-Verbose "Obsah souboru nacten."

            if ($sqlContent) {
                # Pridani nazvu souboru jako SQL komentar
                $sqlContent = "-- File: $sqlFile`r`n" + $sqlContent
                Write-Verbose "Pridan komentar s nazvem souboru."

                # Odstraneni BOM znaku
                $sqlContent = $sqlContent.TrimStart([char]0xFEFF)
                Write-Verbose "Odstranen BOM znak."

                # Pridani stredniku na konec obsahu, pokud chybi
                if (-not $sqlContent.TrimEnd().EndsWith(";")) {
                    $sqlContent += ";"
                    Write-Verbose "Pridan strednik na konec obsahu."
                }

                # Pridani obsahu do vystupniho souboru
                Add-Content -Path $OutputFile -Value $sqlContent -Encoding UTF8
                Write-Verbose "Obsah pridan do vystupniho souboru."
            }
        }

        # Dokonceni skriptu
        Write-Debug "Soubor $OutputFile byl uspesne vytvoren"
        return $OutputFile
    }
    catch {
        # Zpracovani chyby
        Write-Verbose "Doslo k chybe pri spojovani SQL souboru: $_"
        throw "Doslo k chybe pri spojovani SQL souboru: $_"
    }
}