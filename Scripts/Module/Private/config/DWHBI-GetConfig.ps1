function DWHBI-GetConfig {
    # Nastaveni cesty k aplikaci
    $appRoot = "D:\\vscode\\powershell\\dwhbi-cicd\\"
    if (-not (Test-Path -Path $appRoot)) {
        Write-Error "DWHBI-GetConfig: Cesta k aplikaci neexistuje: $appRoot"
        return $null
    }

    Push-Location -Path $appRoot
    try {
        # Nastaveni relativni cesty k souboru config.json
        $relativePath = "Config\config.json"
        $path = Join-Path -Path (Get-Location) -ChildPath $relativePath

        # Kontrola existence souboru
        if (-not (Test-Path -Path $path)) {
            Write-Error "DWHBI-GetConfig: Konfiguracni soubor nebyl nalezen: $path"
            return $null
        }

        # Nacteni obsahu souboru a prevod na PSCustomObject
        $configContent = Get-Content -Path $path -Raw | ConvertFrom-Json
    } catch {
        Write-Error "DWHBI-GetConfig: Chyba pri nacteni konfigurace: $($_.Exception.Message)"
        return $null
    } finally {
        # Prepnuti zpet do puvodni cesty
        Pop-Location
    }
    return $configContent
}
