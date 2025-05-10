# Nacteni konfigurace
$Config = Get-FullConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPatha

# Pole obsahujici cesty k SSIS balickum
$ssisPackages = @(
    "SSIS\Solution11\Project1\Package1.dtsx",
    "SSIS\Solution12\Project1\Package2.dtsx"
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
    Invoke-BuildProjects -ProjectFile $projectFile -Verbose
}



