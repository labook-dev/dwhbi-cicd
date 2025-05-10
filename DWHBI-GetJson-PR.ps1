# Inicializace promenne ve specifikovane strukture
$files = [PSCustomObject]@{
    SQL = [PSCustomObject]@{
        MS = @()
        TD = @()
    }
    VS = [PSCustomObject]@{
        SSIS = @{}
    }
}

# Nacteni konfigurace
$Config = DWHBI-GetConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPath

# Import funkce Get-FilesInFolder
.  Scripts\Module\DWHBI-Get-FilesInFolder.ps1


# Volani funkce Get-FilesInFolder
$files = DWHBI-Get-FilesInFolder

# Filtrovani souboru v MS slozce
$msFiles = $files | Where-Object { $_ -like "*\MS\*" }
Write-Output $msFiles


# Filtrovani souboru v TD slozce
$tdFiles = $files | Where-Object { $_ -like "*\TD\*" }
Write-Output $tdFiles


# Volani funkce Join-MSSQLSqlFiles s parametrem $msFiles
$sqloutputFileMS = DWHBI-SQL-MSSqlJoinSqlFiles  -SqlFiles $msFiles -Verbose
Write-Output "Vystupni soubor byl vytvoren: $outputFile"
$files.SQL.MS = $sqloutputFileMS

# Volani funkce Join-TeradataSqlFiles s parametrem $tdFiles
$sqloutputFileTD = DWHBI-SQL-TeradataJoinSqlFiles -SqlFiles $tdFiles -Verbose
Write-Output "Vystupni soubor pro Teradata byl vytvoren: $outputTdFile"
$files.SQL.TD = $sqloutputFileTD

# Filtrovani souboru s priponou .dtsx
$dtsxFiles = $files | Where-Object { $_ -like "*.dtsx" }
Write-Output $dtsxFiles

# Inicializace vlastnosti ProjectFiles, pokud neexistuje
if (-not $files.VS.SSIS.PSObject.Properties.Match("ProjectFiles")) {
    $files.VS.SSIS.ProjectFiles = @()
}

# Pro kazdy soubor s priponou .dtsx najdi prislusny projektovy soubor
foreach ($dtsxFile in $dtsxFiles) {
    $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $dtsxFile
    Write-Verbose "Projektovy soubor pro $dtsxFile je $projectFile"
    $files.VS.SSIS.ProjectFiles += [PSCustomObject]@{
        ProjectFile = $projectFile
        FilesDTSX   = @($dtsxFile)
    }
}

# Vytvoreni JSON ze struktury $files
$jsonOutputPath = Join-Path -Path $RootPath -ChildPath "files.json"
$files | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonOutputPath -Encoding UTF8
Write-Output "JSON soubor byl vytvoren: $jsonOutputPath"

