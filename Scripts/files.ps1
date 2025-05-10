# Nacteni konfigurace
$Config = Get-FullConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPatha

# Import funkce Get-FilesInFolder
. Scripts\Fake\Get-FilesInFolder.ps1

# Volani funkce Get-FilesInFolder
$files = Get-FilesInFolder

# Filtrovani souboru v MS slozce
$msFiles = $files | Where-Object { $_ -like "*\MS\*" }
Write-Output "Soubory v MS slozce:"
Write-Output $msFiles

# Filtrovani souboru v TD slozce
$tdFiles = $files | Where-Object { $_ -like "*\TD\*" }
Write-Output "Soubory v TD slozce:"
Write-Output $tdFiles

# Volani funkce Join-MSSQLSqlFiles s parametrem $msFiles
$outputFile = Join-MSSQLSqlFiles -SqlFiles $msFiles -Verbose
Write-Output "Vystupni soubor byl vytvoren: $outputFile"

# Volani funkce Join-TeradataSqlFiles s parametrem $tdFiles
$outputTdFile = Join-TeradataSqlFiles -SqlFiles $tdFiles -Verbose
Write-Output "Vystupni soubor pro Teradata byl vytvoren: $outputTdFile"

# Pole obsahujici cesty k SSIS balickum
$ssisPackages = @(
    "SSIS\Solution1\Project1\Package1.dtsx",
    "SSIS\Solution2\Project2\Package2.dtsx"
)

Write-Output "Cesty k SSIS balickum:"
Write-Output $ssisPackages
$RootPath

# Definice promene $Repository
$Repository = "dwhbi.testovaci"

# Volani funkce Find-VSProjectFile pro kazdy soubor v $ssisPackages
foreach ($package in $ssisPackages) {
    $fullPath = Join-Path -Path $RootPath -ChildPath (Join-Path -Path $Config.Path.Repos -ChildPath (Join-Path -Path $Config.Bitbucket.Project -ChildPath (Join-Path -Path $Repository -ChildPath $package)))
    $projectFile = Find-VSProjectFile -StartFileWithName $fullPath -Verbose
    Write-Output "Projektovy soubor pro balicek '$package': $projectFile"
}



