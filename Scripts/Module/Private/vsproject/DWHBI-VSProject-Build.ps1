function DWHBI-VSProject-Build {
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
        throw "Cesta projektu neobsahuje platny typ projektu (SSIS, SSRS, SSAS): $projectFile"
    }

    switch ($ProjectType) {
        "SSIS" {
            Write-Output "Spoustim build pro SSIS projekt: $projectFile"
            DWHBI-Build-SSISProject @PSBoundParameters
        }
        "SSRS" {
            Write-Output "Spoustim build pro SSRS projekt: $projectFile"
            DWHBI-Build-VSProject @PSBoundParameters
        }
        "SSAS" {
            Write-Output "Spoustim build pro SSAS projekt: $projectFile"
            DWHBI-Build-VSProject @PSBoundParameters
        }
        default {
            throw "Neznamy typ projektu: $ProjectType"
        }
    }
}
