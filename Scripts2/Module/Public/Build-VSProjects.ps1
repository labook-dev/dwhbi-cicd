function Build-VSProjects {
    param (
        [Parameter(Mandatory = $true)]
        [string]$projectFile
    )

    # Určení typu projektu na základě cesty
    $ProjectType = if ($projectFile -match "SSIS") {
        "SSIS"
    } elseif ($projectFile -match "SSRS") {
        "SSRS"
    } elseif ($projectFile -match "SSAS") {
        "SSAS"
    } else {
        throw "Cesta projektu neobsahuje platný typ projektu (SSIS, SSRS, SSAS): $projectFile"
    }

    switch ($ProjectType) {
        "SSIS" {
            Write-Output "Spouštím build pro SSIS projekt: $projectFile"
            Invoke-BuildSSISProject @PSBoundParameters
        }
        "SSRS" {
            Write-Output "Spouštím build pro SSRS projekt: $projectFile"
            Invoke-BuildSSRSProject  @PSBoundParameters
        }
        "SSAS" {
            Write-Output "Spouštím build pro SSAS projekt: $projectFile"
            Invoke-BuildSSASProject  @PSBoundParameters
        }
        default {
            throw "Neznámý typ projektu: $ProjectType"
        }
    }
}
