# Parametry pro pull request ID a prostredi
$pullRequestId = 11
$environment = "TEST" # Specify the environment (e.g., TEST or PROD)

Write-Output "Skript: ps-pr.ps1 Aktualni adresar: $(Get-Location)"

# Zavolání funkce
$files = Get-BitbucketPullRequestFiles -PullRequestId $pullRequestId -Environment $environment

# Filtrace na zaklade podminek a ulozeni pouze atributu File
$filesMs = $files | Where-Object { $_.File -like "*/MS/*" } | Select-Object -ExpandProperty File
$filesTd = $files | Where-Object { $_.File -like "*/TD/*" } | Select-Object -ExpandProperty File

Write-Output "Files MS:"
$filesMs | Format-Table -AutoSize

Write-Output "Files TD:"
$filesTd | Format-Table -AutoSize

# Kontrola, zda je $PSScriptRoot definován
if (-not $psScriptRoot) {
    throw "Proměnná `$PSScriptRoot není definována. Skript musí být spuštěn z PowerShell souboru."
}

# Nastavení pracovní složky na základě relativní cesty
Set-Location -Path (Join-Path -Path $psScriptRoot -ChildPath "..\..\GitRepos\DWHIBI\dwhbi.testovaci")

$outputFile = Join-MSSQLSqlFiles -SqlFiles $filesMs

Write-Output "Vystupni soubor byl vytvoren: $outputFile"