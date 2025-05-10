function DWHBI-SQL-DWHBI-GetConfigSqlFileTest {
    param(
        [string]$InputFilePath,
        [string]$ConnectionString
    )

    # Vypis aktualniho adresare a informace o skriptu
    Write-Output "Skript: ValidateSqlFile.TD.ps1 Aktualni adresar: $(Get-Location)"

    # Kontrola, zda existuje vstupni soubor
    if (-Not (Test-Path -Path $InputFilePath)) {
        Write-Error "DWHBI-SQL-DWHBI-GetConfigSqlFileTest: The file '$InputFilePath' does not exist."
        return $false
    }

    # Nacteni obsahu vstupniho souboru
    $fileContent = Get-Content -Path $InputFilePath -Raw

    # Validace SQL kodu provedenim v transakci s Windows autentizaci
    try {
        # Zacatek transakce, provedeni SQL kodu a rollback v pripade chyby
        $transactionQuery = @"
BEGIN TRY
    BEGIN TRANSACTION;
    $fileContent
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF (@@TRANCOUNT > 0)
    BEGIN
        ROLLBACK TRANSACTION;
    END
    THROW;
END CATCH
"@
        # Provedeni SQL dotazu
        Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $transactionQuery -QueryTimeout 10
        
        # Zapis hodnoty do JSON souboru
        DWHBI-Write-ParameterToTempJson -ParameterName "ValidationStatus" -ParameterValue "Success"

        # Vypis informace o uspesne validaci
        Write-Output "Validace Teradata SQL OK"
        return $true
    }
    catch {
        # Zapis chyby do JSON souboru
        DWHBI-Write-ParameterToTempJson -ParameterName "ValidationStatus" -ParameterValue "Failure"

        # Vypis chyby v pripade neplatneho SQL kodu
        Write-Error "DWHBI-SQL-TeradataSqlFileTest: SQL code is invalid. Error details: $_"
        return $false
    }
}