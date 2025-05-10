# Nacteni konfigurace
$Config = DWHBI-GetConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPath

# Pole obsahujici cesty k SSIS balickum
$ssisPackages = @(
    "SSIS\Solution11\Project1\Package1.dtsx",
    "SSIS\Solution12\Project1\Package2.dtsx"
)

Write-Output "Cesty k SSIS balickum:"
Write-Output $ssisPackages

# Definice promenne $Repository
$Repository = "dwhbi.testovaci"

# Volani funkce Find-VSProjectFile pro kazdy soubor v $ssisPackages
foreach ($package in $ssisPackages) {
    $fullPath = Join-Path -Path $RootPath -ChildPath (Join-Path -Path $Config.Path.Repos -ChildPath (Join-Path -Path $Config.Bitbucket.Project -ChildPath (Join-Path -Path $Repository -ChildPath $package))))
    $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $fullPath -Verbose
    Write-Output "Projektovy soubor pro balicek '$package': $projectFile"
    DWHBI-VSProjects-Build -ProjectFile $projectFile -Verbose
}



