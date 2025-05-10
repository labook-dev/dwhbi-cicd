function DWHBI-Git-InitializeRepository {
    param (
        [string]$Path,
        [string]$RepoUrl,
        [string]$Branch
    )
    # Kontrola, zda slozka existuje, pokud ne, vytvori se
    if (-not (Test-Path $Path)) {
        Write-Output "Vytvarim slozku: $Path"
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        git config --global --add safe.directory $Path
        git config --global core.longpaths true
    }

    # Prechod do slozky a inicializace Git repozitare
    Set-Location $Path
    Write-Output "Prechod do slozky: $Path"

    git init . | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Chyba pri inicializaci repozitare."
        exit 1
    }

    # Pridani remote a checkout vetve
    try {
        git remote add origin $RepoUrl
        git fetch origin | Out-Null
        git checkout -b $Branch origin/$Branch | Out-Null
    } catch {
        Write-Debug "Repo hotove..."
    }
}
