function DWHBI-BuildFiles-Create {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Project,       # Nazev projektu
        [Parameter(Mandatory = $true)]
        [string]$Repository,    # Nazev repozitare
        [Parameter(Mandatory = $true)]
        [string]$Branch,        # Nazev vetve
        [Parameter(Mandatory = $true)]
        [string]$BuildNumber    # Cislo buildu
    )

    # Inicializace prazdneho hashtable pro JSON strukturu
    $buildFiles = @{
        files = @{
            VS = @{
                SSIS = @{
                    Projects = @()
                }
                SSRS = @{
                    Projects = @()
                }
            }
            SQL = @{
                MS = $null
                TD = $null
            }
        }
        Project = $Project
        Repository = $Repository
        Branch = $Branch
        BuildNumber = $BuildNumber
    }

    return $buildFiles
}

function Add-ProjectToBuildFiles {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$buildFiles, # Hashtable obsahujici konfiguraci buildFiles
        [Parameter(Mandatory = $true)]
        [string]$section,       # Sekce (napr. SSIS nebo SSRS)
        [Parameter(Mandatory = $true)]
        [string]$projectFile,   # Cesta k projektovemu souboru
        [Parameter(Mandatory = $true)]
        [string]$file           # Cesta k souboru, ktery patri do projektu
    )

    # Inicializace dynamickeho pole, pokud jeste neexistuje
    if (-not $buildFiles.files.VS.$section.PSObject.Properties.Match("Projects")) {
        $buildFiles.files.VS.$section.Projects = @()
    }

    # Zkontroluj, zda jiz existuje projekt se stejnym ProjectFile
    $existingProject = $buildFiles.files.VS.$section.Projects | Where-Object { $_.ProjectFile -eq $projectFile }

    if ($existingProject) {
        # Pokud projekt existuje, pridej $file do pole Files, pokud tam jiz neni
        if (-not ($existingProject.Files -contains $file)) {
            $existingProject.Files += $file
        }
    } else {
        # Pokud projekt neexistuje, vytvor novy objekt a pridej ho do pole Projects
        $newProject = @{
            ProjectFile = $projectFile
            Files = @($file)
        }
        $buildFiles.files.VS.$section.Projects += $newProject
    }
}

function DWHBI-Stage-BuildConfigCreate {
    <#
    .SYNOPSIS
        Vytvori konfiguraci buildFiles na zaklade souboru v repozitari.

    .DESCRIPTION
        Tato funkce nacita soubory z repozitare, filtruje je podle typu (MS SQL, Teradata SQL, SSIS, SSRS),
        a vytvori konfiguraci buildFiles, ktera obsahuje informace o projektech a souborech.
        Konfigurace je ulozena do JSON souboru.

    .PARAMETER Repository
        Nazev repozitare, ze ktereho se nacitaji soubory.

    .PARAMETER Branch
        Nazev vetve, ze ktere se nacitaji soubory.

    .PARAMETER BuildNumber
        Cislo buildu, ktere je zahrnuto do konfigurace.

    .EXAMPLE
        DWHBI-Stage-BuildConfigCreate -Repository "dwhbi.testovaci" -Branch "main" -BuildNumber "123"

        Tento priklad vytvori konfiguraci buildFiles pro repozitar "dwhbi.testovaci", vetve "main" a cisla buildu "123".

    .NOTES
        Autor: [Tve jmeno]
        Datum: [Aktualni datum]
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Repository, # Nazev repozitare
        [Parameter(Mandatory = $true)]
        [string]$Branch,     # Nazev vetve
        [Parameter(Mandatory = $true)]
        [string]$BuildNumber # Cislo buildu
    )


    # Nacteni konfigurace
    $Config = DWHBI-GetConfig # Nacteni konfiguracniho souboru
    $RootPath = $Config.Path.Root # Ziskani korenove cesty z konfigurace

    # Nastaveni aktualniho adresare
    Set-Location -Path $RootPath

    # Import funkce Get-FilesInFolder s absolutni cestou
    . "d:\vscode\powershell\dwhbi-cicd\Scripts\Fake\DWHBI-Get-FilesInFolder.ps1"

    # Volani funkce Get-FilesInFolder
    $files = DWHBI-Get-FilesInFolder

    # Filtrovani souboru v MS slozce
    $msFiles = $files | Where-Object { $_ -like "*\MS\*" }
    Write-Verbose ($msFiles -join ", ")

    # Filtrovani souboru v TD slozce
    $tdFiles = $files | Where-Object { $_ -like "*\TD\*" }
    Write-Verbose ($tdFiles -join ", ")

    # Filtrovani souboru v SSIS slozce
    $ssisPackages = $files | Where-Object { $_ -like "*.dtsx" }
    Write-Verbose ($ssisPackages -join ", ")

    # Filtrovani souboru v SSRS slozce
    $reportFiles = $files | Where-Object { $_ -match "\.(rdl|rds|rsd)$" }
    Write-Verbose ($reportFiles -join ", ")

    # Volani funkce Join-MSSQLSqlFiles s parametrem $msFiles
    $artefaktMSFile = DWHBI-SQL-MSSqlJoinSqlFiles -SqlFiles $msFiles 
    Write-Verbose "Vystupni soubor byl vytvoren: $artefaktMSFile"

    # Volani funkce Join-TeradataSqlFiles s parametrem $tdFiles
    $artefaktTDFile = DWHBI-SQL-TeradataJoinSqlFiles -SqlFiles $tdFiles
    Write-Verbose "Vystupni soubor pro Teradata byl vytvoren: $artefaktTDFile"

    # Inicializace $buildFiles volanim funkce s povinnymi parametry
    $buildFiles = DWHBI-BuildFiles-Create -Project $Config.Bitbucket.Project -Repository $Repository -Branch $Branch -BuildNumber $BuildNumber
    $buildFiles.files.SQL.MS = $artefaktMSFile
    $buildFiles.files.SQL.TD = $artefaktTDFile

    # Volani funkce Find-VSProjectFile pro kazdy soubor v $ssisPackages
    foreach ($package in $ssisPackages) {
        $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $package
        Add-ProjectToBuildFiles -buildFiles $buildFiles -section "SSIS" -projectFile $projectFile -file $package
    }

    # Volani funkce Find-VSProjectFile pro kazdy soubor v $reportFiles
    foreach ($reportFile in $reportFiles) {
        $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $reportFile
        Add-ProjectToBuildFiles -buildFiles $buildFiles -section "SSRS" -projectFile $projectFile -file $reportFile
    }

    # Ulozeni $buildFiles do Artefakt/buildFilesConfig.json
    $folderPath = Join-Path -Path $RootPath -ChildPath $Config.Path.Artefakt
    if (-not (Test-Path -Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath | Out-Null
    }
    $buildFilesConfigPath = Join-Path -Path $folderPath -ChildPath "buildFilesConfig.json"
    $buildFiles | ConvertTo-Json -Depth 10 | Set-Content -Path $buildFilesConfigPath -Encoding UTF8
    Write-Verbose "Konfigurace buildFiles byla ulozena do: $buildFilesConfigPath"
}

# Priklad volani funkce
# DWHBI-Stage-BuildConfigCreate -Repository "dwhbi.testovaci" -Branch "main" -BuildNumber "123"