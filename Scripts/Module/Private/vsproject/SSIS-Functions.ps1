# Funkce pro nacteni SSIS knihovny
function Load-SSISLibrary {
    param (
        [string]$libraryPath = "C:\Program Files\Microsoft SQL Server\150\SDK\Assemblies\Microsoft.SqlServer.Management.IntegrationServices.dll"
    )
    if (Test-Path $libraryPath) {
        Add-Type -Path $libraryPath
        Write-Output "SSIS knihovna byla uspesne nactena."
    } else {
        Write-Output "SSIS knihovna nebyla nalezena na ceste: $libraryPath"
    }
}

# Funkce pro vytvoreni konfigurace sestaveni SSIS projektu
function New-SSISBuildConfig {
    param (
        [string]$SsisProjectPath,
        [string]$OutputPath,
        [array]$Parameters = @(),
        [string]$Configuration = "Release"
    )

    return [PSCustomObject]@{
        SsisProjectPath = $SsisProjectPath
        OutputPath      = $OutputPath
        Parameters      = $Parameters
        Configuration   = $Configuration
    }
}

# Funkce pro sestaveni SSIS projektu
function Build-SSISProject {
    param (
        [PSCustomObject]$config
    )

    $devenvPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
    if (-Not (Test-Path $devenvPath)) {
        throw "Visual Studio nebylo nalezeno na ocekavane ceste: $devenvPath"
    }

    $command = "$devenvPath `"$($config.SsisProjectPath)`" /Build $($config.Configuration) /Out `"$($config.OutputPath)`" " + ($config.Parameters -join " ")

    Invoke-Expression $command
    Write-Output "SSIS projekt byl sestaven do $($config.OutputPath) s konfiguraci $($config.Configuration)"
    Write-Output "Build log ulozen na $($config.ErrorLogPath)"
}

# Funkce pro vytvoreni konfigurace nasazeni SSIS balicku
function New-SSISDeployConfig {
    param (
        [string]$SsisPackagePath,
        [string]$SqlServer,
        [string]$SsisCatalog,
        [string]$Folder,
        [string]$ProjectName,
        [string]$PackageName,
        [PSCredential]$Credential,
        [string]$Environment = "DEV",
        [bool]$Overwrite = $true,
        [hashtable]$ParameterValues = @{ }
    )

    return [PSCustomObject]@{
        SsisPackagePath  = $SsisPackagePath
        SqlServer        = $SqlServer
        SsisCatalog      = $SsisCatalog
        Folder           = $Folder
        ProjectName      = $ProjectName
        PackageName      = $PackageName
        Credential       = $Credential
        Environment      = $Environment
        Overwrite        = $Overwrite
        ParameterValues  = $ParameterValues
    }
}

# Funkce pro nasazeni SSIS balicku
function Deploy-SSISPackage {
    param (
        [PSCustomObject]$config,
        [bool]$useLibrary = $false
    )

    if ($useLibrary) {
        # Nasazeni pomoci knihovny
        $connection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($config.SqlServer)
        $connection.LoginSecure = $false
        $connection.Login = $config.Credential.Username
        $connection.Password = $config.Credential.GetNetworkCredential().Password

        $ssisServer = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices($connection)
        $ssisDb = $ssisServer.Catalogs[$config.SsisCatalog]
        $project = $ssisDb.Folders[$config.Folder].Projects[$config.ProjectName]

        foreach ($key in $config.ParameterValues.Keys) {
            $project.Parameters[$key].Set($config.ParameterValues[$key])
        }

        if ($config.Overwrite) {
            Write-Output "Existujici balicek bude prepsan."
        } else {
            Write-Output "Balicek nebude prepsan."
        }

        $project.Deploy($config.SsisPackagePath)
        Write-Output "SSIS balicek byl nasazen pomoci Integration Services knihovny do prostredi $($config.Environment)"
    } else {
        # Nasazeni pomoci DTEXEC
        $command = "DTEXEC /File `"$($config.SsisPackagePath)`" /Server $($config.SqlServer) /ISServer $($config.SsisCatalog)\$($config.Folder)\$($config.ProjectName)\$($config.PackageName) /User $($config.Credential.Username) /Password $($config.Credential.GetNetworkCredential().Password)"

        foreach ($key in $config.ParameterValues.Keys) {
            $command += " /SET \Package.$key=$($config.ParameterValues[$key])"
        }

        if ($config.Overwrite) {
            Write-Output "Existujici balicek bude prepsan."
        } else {
            Write-Output "Balicek nebude prepsan."
        }

        Invoke-Expression $command
        Write-Output "SSIS balicek byl nasazen na serveru $($config.SqlServer) do prostredi $($config.Environment)"
    }
}

# Vytvoreni prihlasovaciho objektu
$securePassword = ConvertTo-SecureString "SuperSecurePass" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("AdminUser", $securePassword)

# Vytvoreni objektu sestaveni SSIS projektu
$buildConfig = New-SSISBuildConfig -SsisProjectPath "C:\SSISProject\MyProject.dtproj" -OutputPath "C:\SSISBuildOutput" -Parameters @("/p:Parameter1=Value1", "/p:Parameter2=Value2") -Configuration "Release" -LoggingLevel "Verbose" -ErrorLogPath "C:\Logs\SSISBuild.log"

# Vytvoreni objektu nasazeni SSIS balicku
$deployConfig = New-SSISDeployConfig -SsisPackagePath "C:\SSISBuildOutput\Package.dtsx" -SqlServer "MySQLServer" -SsisCatalog "SSISDB" -Folder "MyFolder" -ProjectName "MyProject" -PackageName "MyPackage" -Credential $credential -Environment "PROD" -Overwrite $false -ParameterValues @{Param1="NewValue"; Param2="AnotherValue"}

# Volani funkci
Build-SSISProject -config $buildConfig
Deploy-SSISPackage -config $deployConfig -useLibrary $false
Deploy-SSISPackage -config $deployConfig -useLibrary $true
