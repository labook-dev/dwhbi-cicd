function Invoke-BuildSSISProject {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProjectFile
    )

    # Kontrola existence projektu
    if (-not (Test-Path -Path $ProjectFile)) {
        throw "SSIS projekt nebyl nalezen: $ProjectFile"
    }

    # Build SSIS projektu
    Write-Output "Zahajuji build SSIS projektu: $ProjectFile"
    $msbuildCommand = "D:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"
    $msbuildArgs = "$ProjectFile /p:Configuration=Release /p:Platform='Any CPU' /p:SSISDeploymentModel=Package /t:Rebuild /v:m"
    Write-Verbose "Spouštím příkaz: `$msbuildCommand $msbuildArgs"
    & $msbuildCommand $msbuildArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Build SSIS projektu selhal: $ProjectFile"
    }

    Write-Output "Build SSIS projektu byl úspěšný: $ProjectFile"
}
