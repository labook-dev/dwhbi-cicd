# Funkce pro načtení SSIS knihovny
function Load-SSISLibrary {
    param (
        [string]$libraryPath = "C:\Program Files\Microsoft SQL Server\150\SDK\Assemblies\Microsoft.SqlServer.Management.IntegrationServices.dll"
    )
    if (Test-Path $libraryPath) {
        Add-Type -Path $libraryPath
        Write-Output "SSIS knihovna byla úspěšně načtena."
    } else {
        Write-Output "SSIS knihovna nebyla nalezena na cestě: $libraryPath"
    }
}
function New-SSISDeployObject {
    param (
        [string]$ssisPackagePath,
        [string]$sqlServer,
        [string]$ssisCatalog,
        [string]$folder,
        [string]$projectName,
        [string]$packageName,
        [PSCredential]$credential,
        [string]$environment = "DEV",
        [bool]$overwrite = $true,
        [hashtable]$parameterValues = @{}
    )

    return [PSCustomObject]@{
        SSISPackagePath  = $ssisPackagePath
        SQLServer        = $sqlServer
        SSISCatalog      = $ssisCatalog
        Folder           = $folder
        ProjectName      = $projectName
        PackageName      = $packageName
        Credential       = $credential
        Environment      = $environment
        Overwrite        = $overwrite
        ParameterValues  = $parameterValues
    }
}

# Funkce pro sestavení SSIS projektu
function Build-SSISProject {
    param (
        [PSCustomObject]$SSISDeployObject
    )

    $devenvPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
    $command = "$devenvPath `"$($SSISDeployObject.SSISProjectPath)`" `
        /Build $($SSISDeployObject.Configuration) `
        /Out `"$($SSISDeployObject.OutputPath)`" " + `
        ($SSISDeployObject.Parameters -join " ")

    Invoke-Expression $command
    Write-Output "SSIS projekt byl sestaven do $($SSISDeployObject.OutputPath) s konfigurací $($SSISDeployObject.Configuration)"
    Write-Output "Build log uložen na $($SSISDeployObject.ErrorLogPath)"
}

# Funkce pro vytvoření objektu nasazení SSIS balíčku


# Funkce pro nasazení SSIS balíčku
function Deploy-SSISPackage {
    param (
        [PSCustomObject]$SSISDeployObject,
        [bool]$useLibrary = $false
    )

    if ($useLibrary) {
        # Nasazení pomocí knihovny
        $connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($SSISDeployObject.SQLServer)
        $connection.LoginSecure = $false
        $connection.Login = $SSISDeployObject.Credential.Username
        $connection.Password = $SSISDeployObject.Credential.GetNetworkCredential().Password

        $ssisServer = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices($connection)
        $ssisDb = $ssisServer.Catalogs[$SSISDeployObject.SSISCatalog]
        $project = $ssisDb.Folders[$SSISDeployObject.Folder].Projects[$SSISDeployObject.ProjectName]

        foreach ($key in $SSISDeployObject.ParameterValues.Keys) {
            $project.Parameters[$key].Set($SSISDeployObject.ParameterValues[$key])
        }

        if ($SSISDeployObject.Overwrite) {
            Write-Output "Existující balíček bude přepsán."
        } else {
            Write-Output "Balíček nebude přepsán."
        }

        $project.Deploy($SSISDeployObject.SSISPackagePath)
        Write-Output "SSIS balíček byl nasazen pomocí Integration Services knihovny do prostředí $($SSISDeployObject.Environment)"
    } else {
        # Nasazení pomocí DTEXEC
        $command = "DTEXEC `
            /File `"$($SSISDeployObject.SSISPackagePath)`" `
            /Server $($SSISDeployObject.SQLServer) `
            /ISServer $($SSISDeployObject.SSISCatalog)\$($SSISDeployObject.Folder)\$($SSISDeployObject.ProjectName)\$($SSISDeployObject.PackageName) `
            /User $($SSISDeployObject.Credential.Username) `
            /Password $($SSISDeployObject.Credential.GetNetworkCredential().Password)"

        foreach ($key in $SSISDeployObject.ParameterValues.Keys) {
            $command += " /SET \Package.$key=$($SSISDeployObject.ParameterValues[$key])"
        }

        if ($SSISDeployObject.Overwrite) {
            Write-Output "Existující balíček bude přepsán."
        } else {
            Write-Output "Balíček nebude přepsán."
        }

        Invoke-Expression $command
        Write-Output "SSIS balíček byl nasazen na serveru $($SSISDeployObject.SQLServer) do prostředí $($SSISDeployObject.Environment)"
    }
}

# Vytvoření přihlašovacího objektu
$securePassword = ConvertTo-SecureString "SuperSecurePass" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $securePassword)

# Vytvoření objektu sestavení SSIS projektu
$buildConfig = New-SSISBuildConfig -ssisProjectPath "C:\SSISProject\MyProject.dtproj" -outputPath "C:\SSISBuildOutput" -parameters @("/p:Parameter1=Value1", "/p:Parameter2=Value2") -configuration "Release" -loggingLevel "Verbose" -errorLogPath "C:\Logs\SSISBuild.log"

# Vytvoření objektu nasazení SSIS balíčku
$deployConfig = New-SSISDeployObject -ssisPackagePath "C:\SSISBuildOutput\Package.dtsx" -sqlServer "MySQLServer" -ssisCatalog "SSISDB" -folder "MyFolder" -projectName "MyProject" -packageName "MyPackage" -credential $credential -environment "PROD" -overwrite $false -parameterValues @{Param1="NewValue"; Param2="AnotherValue"}

# Volání funkcí
Build-SSISProject -config $buildConfig
Load-SSISLibrary
Deploy-SSISPackage -config $deployConfig -useLibrary $false
Deploy-SSISPackage -config $deployConfig -useLibrary $true
