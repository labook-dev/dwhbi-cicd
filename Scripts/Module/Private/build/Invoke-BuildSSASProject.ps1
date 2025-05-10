function Invoke-SSASProjectBuild {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProjectFile
    )

    # Kontrola existence projektu
    if (-not (Test-Path -Path $ProjectFile)) {
        throw "SSAS projekt nebyl nalezen: $ProjectFile"
    }

    # Build SSAS projektu
    Write-Output "Zahajuji build SSAS projektu: $ProjectFile"
    $msbuildCommand = "D:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"
    $msbuildArgs = "$ProjectFile /p:Configuration=Release /p:Platform='Any CPU' /t:Rebuild /v:m"
    Write-Verbose "Spouštím příkaz: `$msbuildCommand $msbuildArgs"
    & $msbuildCommand $msbuildArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Build SSAS projektu selhal: $ProjectFile"
    }

    Write-Output "Build SSAS projektu byl uspesny: $ProjectFile"
}
