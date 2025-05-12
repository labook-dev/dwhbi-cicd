function DWHBI-Stage-GitClone {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName, # Nazev repozitare
        [Parameter(Mandatory = $true)]
        [string]$BranchName      # Nazev vetve
    )

    # Nacteni konfigurace
    $Config = DWHBI-GetConfig
    $RootPath = $Config.Path.Root

    # Nastaveni aktualniho adresare
    Set-Location -Path $RootPath

    try {
        # Klonovani repozitare
        $WorkingPath = DWHBI-GitClone -RepositoryName $RepositoryName -BranchName $BranchName
        
        Write-Verbose "DWHBI-Stage-GitClone: Repozitar byl uspesne klonovan do: $WorkingPath"
    } catch {
        # Zpracovani chyby
        Write-Error "DWHBI-Stage-GitClone: Chyba pri klonovani repozitare: $($_.Exception.Message)"
    }
}

# Priklad volani funkce
# DWHBI-Stage-GitClone -RepositoryName "dwhbi.testovaci" -BranchName "main"
