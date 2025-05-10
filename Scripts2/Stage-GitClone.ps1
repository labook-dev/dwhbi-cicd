param (
    [string]$RepositoryName = "dwhbi.testovaci",
    [string]$BranchName = "main"
)

# Načtení konfigurace
$Config = Get-fullConfig
$RootPath = $Config.Path.Root

# Nastavení aktuálního adresáře
Set-Location -Path $RootPath

try {
    # Klonování repozitáře
    $WorkingPath = Invoke-GitClone -RepositoryName $RepositoryName -BranchName $BranchName
    
    Write-Output "Repozitář byl úspěšně klonován do: $WorkingPath"
} catch {
    # Zpracování chyby
    Write-Error "Chyba při klonování repozitáře: $($_.Exception.Message)"
}
