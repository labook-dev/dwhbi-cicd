# Funkce pro ziskani seznamu souboru ve slozce
function DWHBI-Get-FilesInFolder {
    # Lokalni promenna s pevnou hodnotou
    $folderPath = "D:\vscode\powershell\dwhbi-cicd\Repos"

    # Kontrola, zda slozka existuje
    if (-not (Test-Path -Path $folderPath)) {
        throw "Slozka '$folderPath' neexistuje."
    }

    # Ziskani seznamu souboru ve slozce rekurzivne, vynechani slozek bin a obj
    $files = Get-ChildItem -Path $folderPath -File -Recurse | Where-Object { 
        $_.FullName -notmatch "\\bin\\" -and $_.FullName -notmatch "\\obj\\" 
    } | ForEach-Object { $_.FullName }

    return $files
}
