function Invoke-EnsureFolderExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath
    )

    # Kontrola, zda složka existuje
    if (-not (Test-Path -Path $FolderPath)) {
        try {
            # Vytvoření složky
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
            Write-Output "Složka byla vytvořena: $FolderPath"
            return $true
        } catch {
            Write-Error "Chyba při vytváření složky: $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-Output "Složka již existuje: $FolderPath"
        return $true
    }
}
