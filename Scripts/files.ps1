function DWHBI-BuildFiles-Create {
    param (
        [string]$Project,
        [string]$Repository
    )

    # Inicializace prázdného hashtable pro JSON strukturu
    $buildFiles = @{}

    # Přidání sekce 'files'
    $buildFiles.files = @{}

    # Přidání sekce 'VS' do 'files'
    $buildFiles.files.VS = @{}
    $buildFiles.files.VS.SSIS = @{}
    $buildFiles.files.VS.SSIS.Projects = @()
    
    # Přidání sekce 'SSRS' do 'files'
    $buildFiles.files.VS.SSRS = @{}
    $buildFiles.files.VS.SSRS.Projects = @()
    
    # Přidání sekce 'SQL' do 'files'
    $buildFiles.files.SQL = @{
        MS = $null
        TD = $null
    }

    $buildFiles.Project = $Project

    # Nastavení sekce 'Repository' z parametru
    $buildFiles.Repository = $Repository

    return $buildFiles
}


# Nacteni konfigurace
$Config = DWHBI-GetConfig
$RootPath = $Config.Path.Root

# Nastaveni aktualniho adresare
Set-Location -Path $RootPath

# Import funkce Get-FilesInFolder s absolutní cestou
. "d:\vscode\powershell\dwhbi-cicd\Scripts\Fake\DWHBI-Get-FilesInFolder.ps1"

# Volani funkce Get-FilesInFolder
$files = DWHBI-Get-FilesInFolder



# Filtrovani souboru v MS slozce
$msFiles = $files | Where-Object { $_ -like "*\MS\*" }
Write-Output "Soubory v MS slozce:"
Write-Output $msFiles

# Filtrovani souboru v TD slozce
$tdFiles = $files | Where-Object { $_ -like "*\TD\*" }
Write-Output "Soubory v TD slozce:"
Write-Output $tdFiles

# Filtrovani souboru v SSIS slozce
$ssisPackages = $files | Where-Object { $_ -like "*.dtsx" }
Write-Output "Soubory v SSIS slozce:"
Write-Output $ssisPackages

# Filtrovani souboru v SSRS slozce
$reportFiles = $files | Where-Object { $_ -match "\.(rdl|rds|rsd)$" }
Write-Output "Soubory v SSRS slozce:"
Write-Output $reportFiles

# Volani funkce Join-MSSQLSqlFiles s parametrem $msFiles
$artefaktMSFile = DWHBI-SQL-MSSqlJoinSqlFiles  -SqlFiles $msFiles -Verbose
Write-Output "Vystupni soubor byl vytvoren: $artefaktMSFile"

# Volani funkce Join-TeradataSqlFiles s parametrem $tdFiles
$artefaktTDFile = DWHBI-SQL-TeradataJoinSqlFiles -SqlFiles $tdFiles -Verbose
Write-Output "Vystupni soubor pro Teradata byl vytvoren: $artefaktTDFile"


# Inicializace $buildFiles voláním funkce s parametrem
$buildFiles = DWHBI-BuildFiles-Create -Project $Config.Bitbucket.Project  -Repository $Config.Bitbucket.Repository
$buildFiles.files.SQL.MS = $artefaktMSFile
$buildFiles.files.SQL.TD = $artefaktTDFile

# Volani funkce Find-VSProjectFile pro kazdy soubor v $ssisPackages
foreach ($package in $ssisPackages) {
    #$fullPath = Join-Path -Path $RootPath -ChildPath (Join-Path -Path $Config.Path.Repos -ChildPath (Join-Path -Path $Config.Bitbucket.Project -ChildPath (Join-Path -Path $Repository -ChildPath $package)))
    $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $package
    
    # Přidání prvního SSIS projektu
    $project = @{
        ProjectFile = $projectFile
        Files = @(
            $package
        )
    }

    # Inicializace dynamického pole, pokud ještě neexistuje
    if (-not $buildFiles.files.VS.SSIS.PSObject.Properties.Match("Projects")) {
        $buildFiles.files.VS.SSIS.Projects = @()
    }

    # Vlozeni $project do $buildFiles.files.VS.SSIS.Projects
    # Zkontroluj, zda již existuje projekt se stejným ProjectFile
    $existingProject = $buildFiles.files.VS.SSIS.Projects | Where-Object { $_.ProjectFile -eq $projectFile }

    if ($existingProject) {
        # Pokud projekt existuje, přidej $package do pole Files, pokud tam již není
        if (-not ($existingProject.Files -contains $package)) {
            $existingProject.Files += $package
        }
    } else {
        # Pokud projekt neexistuje, vytvoř nový objekt a přidej ho do pole Projects
        $newProject = @{
            ProjectFile = $projectFile
            Files = @($package)
        }
        $buildFiles.files.VS.SSIS.Projects += $newProject
    }
}


# Volani funkce Find-VSProjectFile pro kazdy soubor v $ssisPackages
foreach ($reportFile in $reportFiles) {
    #$fullPath = Join-Path -Path $RootPath -ChildPath (Join-Path -Path $Config.Path.Repos -ChildPath (Join-Path -Path $Config.Bitbucket.Project -ChildPath (Join-Path -Path $Repository -ChildPath $package)))
    $projectFile = DWHBI-VSProject-FindProjectFile -StartFileWithName $reportFile
    
    # Přidání prvního SSIS projektu
    $project = @{
        ProjectFile = $projectFile
        Files = @(
            $package
        )
    }

    # Inicializace dynamického pole, pokud ještě neexistuje
    if (-not $buildFiles.files.VS.SSRS.PSObject.Properties.Match("Projects")) {
        $buildFiles.files.VS.SSRS.Projects = @()
    }

    # Vlozeni $project do $buildFiles.files.VS.SSIS.Projects
    # Zkontroluj, zda již existuje projekt se stejným ProjectFile
    $existingProject = $buildFiles.files.VS.SSRS.Projects | Where-Object { $_.ProjectFile -eq $projectFile }

    if ($existingProject) {
        # Pokud projekt existuje, přidej $rdl do pole Files, pokud tam již není
        if (-not ($existingProject.Files -contains $reportFile)) {
            $existingProject.Files += $reportFile
        }
    } else {
        # Pokud projekt neexistuje, vytvoř nový objekt a přidej ho do pole Projects
        $newProject = @{
            ProjectFile = $projectFile
            Files = @($reportFile)
        }
        $buildFiles.files.VS.SSRS.Projects += $newProject
    }
}


# Ulozeni $buildFiles do Temp/buildFilesConfig.json
$tempFolderPath = Join-Path -Path $RootPath -ChildPath "Temp"
if (-not (Test-Path -Path $tempFolderPath)) {
    New-Item -ItemType Directory -Path $tempFolderPath | Out-Null
}
$buildFilesConfigPath = Join-Path -Path $tempFolderPath -ChildPath "buildFilesConfig.json"
$buildFiles | ConvertTo-Json -Depth 10 | Set-Content -Path $buildFilesConfigPath -Encoding UTF8
Write-Output "Konfigurace buildFiles byla ulozena do: $buildFilesConfigPath" 