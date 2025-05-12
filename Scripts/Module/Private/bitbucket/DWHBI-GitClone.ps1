function DWHBI-GitClone {
    param (
        [string]$RepositoryName = "dwhbi.testovaci",
        [string]$BranchName = "jenkins/DWHI-24968-nasazeni-na-prod-repdata-provize"
    )

    # Nacteni konfigurace
    $Config = DWHBI-GetConfig
    $AppRoot = $Config.Path.Root
    $SecureFileParh = Join-Path -Path $AppRoot -ChildPath $Config.Path.Secure
    $passwordFile = Join-Path -Path $SecureFileParh -ChildPath $Config.Bitbucket.PasswordFile
    $Username = $Config.Bitbucket.Username

    # Nacteni prihlasovacich udaju
    $credentials = Get-Credentials -PasswordFilePath $passwordFile -Username $Username

    # Definice promennych
    $BaseUrl = $Config.Bitbucket.BaseUrl
    $ProjectName = $Config.Bitbucket.Project
    $RepositoryUrl = "$BaseUrl/$RepositoryName.git"

    # Bezpecny nazev vetve
    $BranchNameSafe = $BranchName -replace '/', '-'
    $BranchNameLocal = $BranchName

    # Definice cest na disku
    $ReposPath = $Config.Path.Repos    
    $WorkingPath = Join-Path -Path $AppRoot -ChildPath (Join-Path -Path $ReposPath -ChildPath (Join-Path -Path $ProjectName -ChildPath (Join-Path -Path $RepositoryName -ChildPath $BranchNameSafe)))

    Set-Location $AppRoot

    # Kontrola, zda je nainstalovany Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "DWHBI-GitClone: Git neni nainstalovany nebo neni v PATH."
        exit 1
    }

    # Kontrola, zda slozka obsahuje Git repozitar
    if (Test-Path "$WorkingPath\.git") {
        $CurrentRepoUrl = git -C $WorkingPath remote get-url origin
        if ($CurrentRepoUrl -eq $RepositoryUrl) {
            # Aktualizace existujiciho repozitare
            Write-Output "Adresar jiz obsahuje spravny repozitar: $RepositoryUrl"
            git -C $WorkingPath fetch origin | Out-Null
            git -C $WorkingPath checkout -B $BranchNameLocal origin/$BranchNameLocal | Out-Null

            # Mazani lokalnich vetvi, ktere nejsou aktualni
            $LocalBranches = git -C $WorkingPath branch | ForEach-Object { $_.Trim() }
            foreach ($Branch in $LocalBranches) {
                if ($Branch -ne $BranchNameLocal -and $Branch -ne "* $BranchNameLocal") {
                    Write-Output "Mazani lokalni vetve: $Branch"
                    git -C $WorkingPath branch -D $Branch | Out-Null
                }
            }
        } else {
            Write-Error "DWHBI-GitClone: Adresar obsahuje jiny repozitar: $CurrentRepoUrl"
            # Pokud slozka obsahuje jiny repozitar, odstrani se a inicializuje novy
            Write-Output "Adresar obsahuje jiny repozitar: $CurrentRepoUrl"
            Set-Location (Split-Path -Parent $WorkingPath)
            Remove-Item -Recurse -Force $WorkingPath
            Initialize-Repository -Path $WorkingPath -RepoUrl $RepositoryUrl -Branch $BranchNameLocal
        }
    } else {
        # Pokud slozka neexistuje nebo neobsahuje repozitar, inicializuje se novy
        Write-Output "Adresar neobsahuje zadny Git repozitar nebo neexistuje."
        Initialize-Repository -Path $WorkingPath -RepoUrl $RepositoryUrl -Branch $BranchNameLocal
    }

    # Zapis hodnoty $WorkingPath do adresare Temp
    DWHBI-Write-ParameterToTempJson -ParameterName "WorkingPath" -ParameterValue $WorkingPath

    # Vraci cestu k pracovnimu adresari
    return $WorkingPath
}
