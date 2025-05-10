# Parametry pro pull request ID a prostredi
$pullRequestId = 11
$environment = "TEST" # Specify the environment (e.g., TEST or PROD)

Write-Output "Skript: ps-pr.ps1 Aktualni adresar: $(Get-Location)"

# Zavolani funkce
$files = DWHBI-Bitbucket-GetPullRequestFiles -PullRequestId $pullRequestId -Environment $environment

# Filtrace na zaklade podminek a ulozeni pouze atributu File
$filesMs = $files | Where-Object { $_.File -like "*/MS/*" } | Select-Object -ExpandProperty File
$filesTd = $files | Where-Object { $_.File -like "*/TD/*" } | Select-Object -ExpandProperty File

Write-Output "Files MS:"
$filesMs | Format-Table -AutoSize

Write-Output "Files TD:"
$filesTd | Format-Table -AutoSize

# Kontrola, zda je $PSScriptRoot definovan
if (-not $psScriptRoot) {
    throw "Promenna `$PSScriptRoot neni definovana. Skript musi byt spusten z PowerShell souboru."
}

# Nastaveni pracovni slozky na zaklade relativni cesty
Set-Location -Path (Join-Path -Path $psScriptRoot -ChildPath "..\..\GitRepos\DWHIBI\dwhbi.testovaci")

$outputFile = DWHBI-SQL-MSSqlJoinSqlFiles  -SqlFiles $filesMs

Write-Output "Vystupni soubor byl vytvoren: $outputFile"