param (
    [string]$RepositoryName = "dwhbi.testovaci",
    [string]$BranchName = "main"
)

# Nacteni konfigurace
$Config = DWHBI-GetConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPath

try {
    # Klonovani repozitare
    $WorkingPath = DWHBI-GitClone -RepositoryName $RepositoryName -BranchName $BranchName
    
    Write-Output "Repozitar byl uspesne klonovan do: $WorkingPath"
} catch {
    # Zpracovani chyby
    Write-Error "Chyba pri klonovani repozitare: $($_.Exception.Message)"
}
