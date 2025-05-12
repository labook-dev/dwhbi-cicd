function DWHBI-VSProject-FindProjectFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StartFileWithName
    )

    <#
    .SYNOPSIS
    Function searches for Visual Studio project files by scanning parent directories.

    .DESCRIPTION
    This function starts from the given file path and moves up the directory structure 
    until it finds a project file with predefined extensions.

    .PARAMETER StartFileWithName
    Full path to the file from which the search begins.

    .OUTPUTS
    Returns the full path of the first found project file or $null if not found.

    .EXAMPLE
    DWHBI-VSProject-FindProjectFile -StartFileWithName "C:\Projects\MyProject\TestFile.txt"

    .NOTES
    - Supported project file extensions: SSIS (*.dtproj), SSRS (*.rptproj), SSAS (*.dwproj)
    - If no project file is found, function returns $null.
    #>

    # Local variable containing project file extensions
    $Extensions = @("*.dtproj", "*.rptproj", "*.dwproj") # SSIS, SSRS, SSAS project extensions
    Write-Verbose "Defined list of project file extensions: $Extensions"

    # Check if the specified file exists
    if (-not (Test-Path -Path $StartFileWithName)) {
        Write-Verbose "File '$StartFileWithName' does not exist."
        throw "File '$StartFileWithName' does not exist."
    }
    Write-Verbose "File '$StartFileWithName' exists."

    # Extract directory from the given file path
    $currentFolder = Split-Path -Path $StartFileWithName -Parent
    Write-Verbose "Current folder set to: $currentFolder"

    # Search for project file by moving up the directory tree
    while ($currentFolder -ne (Split-Path -Path $currentFolder -Parent)) {
        Write-Verbose "Searching in folder: $currentFolder"
        foreach ($extension in $Extensions) {
            Write-Verbose "Looking for files with extension: $extension"
            $projectFile = Get-ChildItem -Path $currentFolder -Filter $extension -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($projectFile) {
                Write-Verbose "Project file found: $($projectFile.FullName)"
                return $projectFile.FullName
            }
        }
        # Move to parent directory
        $currentFolder = Split-Path -Path $currentFolder -Parent
        Write-Verbose "Moving to parent folder: $currentFolder"
    }

    Write-Verbose "Project file not found."
    return $null
}
