function DWHBI-Bitbucket-GetPullRequestFiles {
    <#
    .SYNOPSIS
    Nacte seznam souboru z pull requestu vcetne jejich vlastnosti.

    .DESCRIPTION
    Tato funkce nacte seznam souboru z pull requestu pomoci Bitbucket API. 
    Parametry jako BaseUrl, ProjectKey, Repository a ApiToken jsou nacteny z konfigurace (config.json).
    Vraci seznam souboru s jejich vlastnostmi, jako je nazev, cesta, pripona a akce v Gitu.

    .PARAMETER PullRequestId
    ID pull requestu, ze ktereho se maji nacist soubory.

    .PARAMETER Repository
    Nazev repozitare, ze ktereho se maji nacist soubory.

    .OUTPUTS
    Vraci seznam souboru jako objekt PowerShellu.

    .EXAMPLE
    $Files = DWHBI-Bitbucket-GetPullRequestFiles -PullRequestId 4 -Repository "my-repo"
    $Files | Format-Table -AutoSize
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $true)]
        [int]$PullRequestId
    )

    Write-Output "Skript: Get-BitbucketPullRequestFiles.ps1 Aktualni adresar: $(Get-Location)"

    $allChangedFiles = @()

    try {
        # Nacteni konfigurace
        $config = DWHBI-GetConfig

        # Lokalni promenne z konfigurace
        $baseUrl    = $config.Bitbucket.BaseUrl
        $projectKey = $config.Bitbucket.Project
        $tokenFile = $config.Bitbucket.TokenFile
        if (-not (Test-Path -Path $tokenFile)) {
            throw "DWHBI-Bitbucket-GetPullRequestFiles: Token file nebyl nalezen: $tokenFile"
        }
        $apiToken = Get-Content -Path $tokenFile -Raw
        
        # Nastaveni hlavicek pro autorizaci
        $headers = @{
            "Authorization" = "Bearer $apiToken"
            "Accept"        = "application/json"
        }

        $start = 0
        
        do {
            # Sestaveni URL s parametrem pro strankovani
            $uri = "$baseUrl/projects/$projectKey/repos/$Repository/pull-requests/$PullRequestId/changes?start=$start"
            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

            if (-Not $response.values) {
                throw "API nevratilo zadne soubory."
            }

             # Zpracovani souboru
            $changedFiles = $response.values | ForEach-Object {
                [PSCustomObject]@{
                    File           = $_.path.toString
                    FileName       = $_.path.name
                    FilePath       = $_.path.parent
                    FileExtension  = $_.path.extension
                    GitAction      = $_.type
                }
            }

            $allChangedFiles += $changedFiles
        
            # Kontrola strankovani: pokud je aktualni stranka posledni, ukoncime cyklus
            if ($response.isLastPage -eq $true) {
                break
            } else {
                $start = $response.nextPageStart
            }
        } while ($true)

        # Vraceni seznamu souboru
        return $allChangedFiles

    } catch {
        throw "DWHBI-Bitbucket-GetPullRequestFiles: Chyba pri ziskavani souboru z pull requestu: $($_.Exception.Message)"
    }
}