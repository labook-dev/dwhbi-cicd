# Funkce pro ziskani seznamu souboru ve slozce
function Get-FilesInFolder {
    # Lokalni promenna s pevnou hodnotou
    $folderPath = "D:\vscode\powershell\dwhbi-cicd\Repos"

    # Kontrola, zda slozka existuje
    if (-not (Test-Path -Path $folderPath)) {
        throw "Slozka '$folderPath' neexistuje."
    }

    # Ziskani seznamu souboru ve slozce rekurzivne
    $files = Get-ChildItem -Path $folderPath -File -Recurse | ForEach-Object { $_.FullName }

    return $files
}
