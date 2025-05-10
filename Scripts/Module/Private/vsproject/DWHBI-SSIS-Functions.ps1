# Funkce pro nacteni SSIS knihovny
function DWHBI-Load-SSISLibrary {
    param (
        [string]$libraryPath
    )
    # Overeni, zda cesta ke knihovne existuje
    if (Test-Path $libraryPath) {
        # Pridani typu z knihovny
        Add-Type -Path $libraryPath
        Write-Output "SSIS knihovna byla uspesne nactena."
    } else {
        # Vypis chyby, pokud knihovna nebyla nalezena
        Write-Output "SSIS knihovna nebyla nalezena na ceste: $libraryPath"
    }
}
function DWHBI-New-SSISDeployObject {
    # Vytvoreni noveho objektu pro nasazeni SSIS balicku
    return [PSCustomObject]@{
        SSISPackagePath  = ""
        SQLServer        = ""
        SSISCatalog      = ""
        Folder           = ""
        ProjectName      = ""
        PackageName      = ""
        Credential       = $null
        Environment      = "DEV"
        Overwrite        = $true
        ParameterValues  = @{}
    }
}

# Funkce pro sestaveni SSIS projektu
function DWHBI-Build-SSISProject {
    param (
        [PSCustomObject]$SSISDeployObject
    )

    # Cesta k Visual Studio devenv.exe
    $devenvPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
    # Sestaveni prikazu pro sestaveni projektu
    $command = "$devenvPath `"$($SSISDeployObject.SSISProjectPath)`" `
        /Build $($SSISDeployObject.Configuration) `
        /Out `"$($SSISDeployObject.OutputPath)`" " + `
        ($SSISDeployObject.Parameters -join " ")

    # Spusteni prikazu
    Invoke-Expression $command
    # Vypis vysledku sestaveni
    Write-Output "SSIS projekt byl sestaven do $($SSISDeployObject.OutputPath) s konfiguraci $($SSISDeployObject.Configuration)"
    Write-Output "Build log ulozen na $($SSISDeployObject.ErrorLogPath)"
}

# Funkce pro nasazeni SSIS balicku
function DWHBI-Deploy-SSISPackage {
    param (
        [PSCustomObject]$SSISDeployObject,
        [bool]$useLibrary = $false
    )

    if ($useLibrary) {
        # Nasazeni pomoci knihovny
        $connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SSISDeployObject.SQLServer)
        $connection.LoginSecure = $false
        $connection.Login = $SSISDeployObject.Credential.Username
        $connection.Password = $SSISDeployObject.Credential.GetNetworkCredential().Password

        $ssisServer = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices($connection)
        $ssisDb = $ssisServer.Catalogs[$SSISDeployObject.SSISCatalog]
        $project = $ssisDb.Folders[$SSISDeployObject.Folder].Projects[$SSISDeployObject.ProjectName]

        # Nastaveni parametru projektu
        foreach ($key in $SSISDeployObject.ParameterValues.Keys) {
            $project.Parameters[$key].Set($SSISDeployObject.ParameterValues[$key])
        }

        # Kontrola, zda prepsat existujici balicek
        if ($SSISDeployObject.Overwrite) {
            Write-Output "Existujici balicek bude prepsan."
        } else {
            Write-Output "Balicek nebude prepsan."
        }

        # Nasazeni balicku
        $project.Deploy($SSISDeployObject.SSISPackagePath)
        Write-Output "SSIS balicek byl nasazen pomoci Integration Services knihovny do prostredi $($SSISDeployObject.Environment)"
    } else {
        # Nasazeni pomoci DTEXEC
        $command = "DTEXEC `
            /File `"$($SSISDeployObject.SSISPackagePath)`" `
            /Server $($SSISDeployObject.SQLServer) `
            /ISServer $($SSISDeployObject.SSISCatalog)\$($SSISDeployObject.Folder)\$($SSISDeployObject.ProjectName)\$($SSISDeployObject.PackageName) `
            /User $($SSISDeployObject.Credential.Username) `
            /Password $($SSISDeployObject.Credential.GetNetworkCredential().Password)"

        # Pridani parametru do prikazu
        foreach ($key in $SSISDeployObject.ParameterValues.Keys) {
            $command += " /SET \Package.$key=$($SSISDeployObject.ParameterValues[$key])"
        }

        # Kontrola, zda prepsat existujici balicek
        if ($SSISDeployObject.Overwrite) {
            Write-Output "Existujici balicek bude prepsan."
        } else {
            Write-Output "Balicek nebude prepsan."
        }

        # Spusteni prikazu
        Invoke-Expression $command
        Write-Output "SSIS balicek byl nasazen na serveru $($SSISDeployObject.SQLServer) do prostredi $($SSISDeployObject.Environment)"
    }
}
