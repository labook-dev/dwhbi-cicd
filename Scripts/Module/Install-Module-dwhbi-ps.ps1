Write-Output "Aktualni adresar: $(Get-Location)"

# Nastaveni cesty k modulu
$appRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$moduleName = "dwhbi-ps"
$moduleFileName = "$moduleName.psm1"
$modulePath = Join-Path -Path $psScriptRoot -ChildPath "dwhbi-ps.psm1"
if (-not (Test-Path -Path $modulePath)) {
    throw "Modul '$modulePath' nebyl nalezen."
}
$moduleDirectory = Split-Path -Path $modulePath

# Ulozeni aktualniho adresare
$currentDirectory = Get-Location

# Volitelne: zmena politiky spousteni pro aktualni relaci
#$PreviousPolicy = Get-ExecutionPolicy
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    # Presun do adresare s modulem
    Set-Location -Path $moduleDirectory

    # Odebrani predchozi verze modulu (pokud je nacten)
    if (Get-Module -Name $moduleName) {
        Remove-Module -Name $moduleName -Force
    }

    # Kontrola existence a import modulu
    if (Test-Path -Path $modulePath) {
        Write-Host "Importuji modul '$moduleName' z cesty: $modulePath" -ForegroundColor Cyan
        Import-Module $modulePath -Force
    } else {
        Write-Error "Modul nebyl nalezen na zadane ceste: $modulePath"
    }
}
catch {
    Write-Error "Doslo k chybe pri importu modulu: $_"
}
finally {
    # Obnoveni puvodniho adresare
    Set-Location -Path $currentDirectory

    # Volitelne: obnoveni puvodni politiky spousteni
    #Set-ExecutionPolicy -Scope Process -ExecutionPolicy $PreviousPolicy -Force
}
