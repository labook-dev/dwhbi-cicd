function DWHBI-SSIS-GetProjectSettings {
    param (
        [string]$xmlPath
    )

    if (-Not (Test-Path $xmlPath)) {
        Write-Error "Soubor XML nebyl nalezen na cestě: $xmlPath"
        return $null
    }

    [xml]$xmlContent = Get-Content -Path $xmlPath

    # Načtení názvu projektu
    $projectName = $xmlContent.Project.DeploymentModelSpecificContent.Manifest.'SSIS:Project'.'SSIS:Properties'.'SSIS:Property' |
                   Where-Object { $_.'SSIS:Name' -eq "Name" } | Select-Object -ExpandProperty "#text"

    # Načtení parametrů balíčků SSIS
    $packageParameters = $xmlContent.Project.DeploymentModelSpecificContent.Manifest.'SSIS:DeploymentInfo'.'SSIS:PackageInfo' |
                         ForEach-Object {
                            $_.'SSIS:PackageMetaData'.'SSIS:Parameters'.'SSIS:Parameter' | ForEach-Object { 
                                [PSCustomObject]@{
                                    PackageName = $_.ParentNode.'SSIS:Name'
                                    ParameterName = $_.'SSIS:Name'
                                    ParameterValue = $_.'SSIS:Value'
                                }
                            }
                         }

    # Načtení proměnných prostředí
    $environmentVariables = $xmlContent.Project.Configurations.Configuration.Options.ParameterConfigurationValues.ConfigurationSetting |
                            ForEach-Object {
                                [PSCustomObject]@{
                                    VariableName = $_.Name
                                    VariableValue = $_.Value
                                }
                            }

    # Sestavení výstupního objektu
    return [PSCustomObject]@{
        ProjectName = $projectName
        PackageParameters = $packageParameters
        EnvironmentVariables = $environmentVariables
    }
}