function DWHBI-SQL-MSSqlJoinSqlFiles  {
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
    DWHBI-SQL-MSSqlJoinSqlFiles  -SqlFiles @("file1.sql", "file2.sql") -RootFolder "C:\projekt"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$SqlFiles
    )

    #Write-Output "Skript: Join-MSSQLSqlFiles.ps1 Aktualni adresar: $(Get-Location)"

    try {
        # Kontrola, zda je $PSScriptRoot definovan
        if (-not $psScriptRoot) {
            throw "Promenna `$PSScriptRoot neni definovana. Skript musi byt spusten z PowerShell souboru."
        }

        # Nacteni konfigurace
        $config = DWHBI-GetConfig 
        Write-Verbose "Konfigurace nactena."

        # Nacteni hodnot Path a Filename pro MS z config.json
        $artefaktPath = Join-Path -Path $config.Path.Root -ChildPath $config.Path.Artefakt
        $outputFilename = "MS.sql"

        # Sestaveni uplne cesty k vystupnimu souboru
        $outputFile = Join-Path -Path $artefaktPath -ChildPath $outputFilename
        Write-Verbose "Cesta k vystupnimu souboru: $outputFile"

        # Validace vstupnich souboru
        foreach ($file in $sqlFiles) {
            if (-Not (Test-Path -Path $file)) {
                Write-Verbose "Soubor $file neexistuje."
                throw "Vstupni soubor '$file' neexistuje."
            }
        }
        Write-Verbose "Validace vstupnich souboru dokoncena."

       # Validace a vytvoreni vystupni slozky
        $folderCreated = DWHBI-EnsureFolderExists -FolderPath $artefaktPath
        Write-Verbose "Kontrola slozky pro artefakty dokoncena."

        if (-not $folderCreated) {
            Write-Verbose "Vytvoreni slozky selhalo."
            throw "Nelze vytvorit vystupni slozku: $artefaktPath"
        }

        # Seradit soubory podle nazvu
        $sortedSqlFiles = $sqlFiles | Sort-Object
        Write-Verbose "SQL soubory serazeny."

        # Vytvorit nebo vymazat vystupni soubor
        if (-not $artefaktPath -or -not $outputFilename) {
            throw "Konfigurace obsahuje neplatne hodnoty pro 'Path' nebo 'Filename'."
        }

        # Vytvoreni prazdneho vystupniho souboru
        New-Item -Path $outputFile -ItemType File -Force | Out-Null
        Write-Verbose "Vystupni soubor vytvoren."

        # Nacist obsah vsech souboru a pridat "GO", pokud chybi
        foreach ($sqlFile in $sortedSqlFiles) {
            Write-Verbose "Zpracovavam soubor: $sqlFile"
            
            $sqlContent = Get-Content -Path $sqlFile -Raw -Encoding UTF8
            Write-Verbose "Obsah souboru nacten."

            if ($sqlContent) {
                # Odstraneni BOM znaku, pokud existuje
                $sqlContent = $sqlContent.TrimStart([char]0xFEFF)
                Write-Verbose "Odstranen BOM znak."
                
                # Pridani GO na konec, pokud chybi
                if ($sqlContent -notmatch "(?ms).*\bGO\s*$") {
                    $sqlContent = $sqlContent.TrimEnd() + "`r`nGO`r`n"
                    Write-Verbose "Pridan prikaz GO na konec obsahu."
                }

                # Pridat obsah SQL souboru do vystupniho souboru
                Add-Content -Path $outputFile -Value $sqlContent -Encoding UTF8
                Write-Verbose "Obsah pridan do vystupniho souboru."
            }
        }

        Write-Debug "Soubor $outputFile byl uspesne vytvoren"
        return $outputFile
    }
    catch {
        throw "Doslo k chybe pri spojovani SQL souboru: $_"
    }
}
