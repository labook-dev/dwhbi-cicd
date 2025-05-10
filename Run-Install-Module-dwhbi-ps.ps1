# Odebrání modulu dwhbi-ps, pokud je načten
if (Get-Module -Name dwhbi-ps -ListAvailable) {
    Write-Output "Odebírám modul dwhbi-ps..."
    Remove-Module -Name dwhbi-ps -Force -ErrorAction SilentlyContinue
}

# Spusteni skriptu Install-Module-dwhbi-ps.ps1
Write-Output "Spoustim skript Install-Module-dwhbi-ps.ps1..."

# Nastaveni politiky spousteni
$previousPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    $scriptPath = Join-Path -Path $psScriptRoot -ChildPath "Scripts\Module\Install-Module-dwhbi-ps.ps1"
    if (-not (Test-Path -Path $scriptPath)) {
        throw "Skript '$scriptPath' nebyl nalezen."
    }
    & $scriptPath
}
finally {
    # Obnoveni puvodni politiky spousteni
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy $previousPolicy -Force
    
}


