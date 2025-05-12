# Funkce pro nacteni prihlasovacich udaju
function DWHBI-Get-Credentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PasswordFilePath, # cesta k souboru s heslem
        [Parameter(Mandatory = $true)]
        [string]$Username
    )

    Write-Output "Skript: Get-Credentials.ps1 Aktualni adresar: $(Get-Location)"

    # Nacteni zasifrovaneho hesla ze souboru
    if (Test-Path $PasswordFilePath) {
        $securePassword = Get-Content $PasswordFilePath | ConvertTo-SecureString
    } else {
        Write-Error "DWHBI-Get-Credentials: Soubor s heslem nebyl nalezen na ceste: $PasswordFilePath."
        exit 1
    }

    # Vytvoreni objektu PSCredential
    return New-Object System.Management.Automation.PSCredential($Username, $securePassword)
}