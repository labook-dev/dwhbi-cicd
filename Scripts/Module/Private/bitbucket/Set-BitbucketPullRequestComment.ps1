function Set-BitbucketPullRequestComment {
    <#
    .SYNOPSIS
    Prida komentar k pull requestu na Bitbucketu.

    .DESCRIPTION
    Tato funkce prida komentar k pull requestu pomoci Bitbucket API. 
    Parametry jako BaseUrl, ProjectKey, Repository a ApiToken jsou nacteny z konfigurace (config.json).

    .PARAMETER PullRequestId
    ID pull requestu, ke kteremu se ma pridat komentar.

    .PARAMETER Comment
    Text komentare, ktery se ma pridat k pull requestu.

    .OUTPUTS
    Zadny vystup.

    .EXAMPLE
    Set-BitbucketPullRequestComment -PullRequestId 4 -Comment "Toto je testovaci komentar."
    #>
    param (
        [Parameter(Mandatory = $true)]
        [int]$PullRequestId,
        [Parameter(Mandatory = $true)]
        [string]$Comment
    )
    
    Write-Output "Skript: Set-BitbucketPullRequestComment.ps1 Aktualni adresar: $(Get-Location)"

    try {
        # Načtení konfigurace
        $config = Get-FullConfig

        # Lokální proměnné z konfigurace
        $BaseUrl    = $config.Bitbucket.BaseUrl
        $ProjectKey = $config.Bitbucket.Project
        $TokenFile = $config.Bitbucket.TokenFile
        if (-not (Test-Path -Path $TokenFile)) {
            throw "Get-BitbucketPullRequestFiles: Token file nebyl nalezen: $TokenFile"
        }
        $ApiToken = Get-Content -Path $TokenFile -Raw
        
        # Nastaveni hlavicek pro autorizaci
        $Headers = @{
            Authorization = "Bearer $ApiToken"
            "Content-Type" = "application/json"
        }

        # Telo pozadavku
        $Body = @{
            text = "Power automat: $Comment"
        } | ConvertTo-Json -Depth 10

        # URL pro pridani komentare k PR
        $Url = "$BaseUrl/projects/$ProjectKey/repos/$Repository/pull-requests/$PullRequestId/comments"

        # Odeslani pozadavku
        try {
            Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
            Write-Host "Komentar uspesne pridan k PR #$PullRequestId."
        } catch {
            Write-Error "Chyba pri pridavani komentare: $($_.Exception.Message)"
        }
    } catch {
        Write-Error "Set-BitbucketPullRequestComment: Chyba pri pridavani komentare: $($_.Exception.Message)"
    }
}
