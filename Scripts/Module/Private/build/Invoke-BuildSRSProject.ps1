function Invoke-SSRSProjectBuild {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProjectFile
    )

    # Kontrola existence projektu
    if (-not (Test-Path -Path $ProjectFile)) {
        throw "SSRS projekt nebyl nalezen: $ProjectFile"
    }

    # Build SSRS projektu
    Write-Output "Zahajuji build SSRS projektu: $ProjectFile"
    $msbuildCommand = "D:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"
    $msbuildArgs = "$ProjectFile /p:Configuration=Release /p:Platform='Any CPU' /t:Rebuild /v:m"
    Write-Verbose "Spouštím příkaz: `$msbuildCommand $msbuildArgs"
    & $msbuildCommand $msbuildArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Build SSRS projektu selhal: $ProjectFile"
    }

    Write-Output "Build SSRS projektu byl uspesny: $ProjectFile"
}
