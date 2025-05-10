-- File: D:\vscode\powershell\dwhbi-cicd\Repos\DWHBI\dwhbi.testovaci\DWHI\DWHI-1111\TD\TD01.db.popis.sql
-- Tento soubor obsahuje SQL příkazy pro vytvoření databáze a tabulky.

CREATE DATABASE TestDB FROM DBC
AS
    PERM = 5000000,
    SPOOL = 1000000;
    
CREATE TABLE TestDB.TestTable (
    ID INT NOT NULL PRIMARY KEY,
    Name VARCHAR(100),
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- File: D:\vscode\powershell\dwhbi-cicd\Repos\DWHBI\dwhbi.testovaci\DWHI\DWHI-1111\TD\TD02.db.popis.sql
-- Tento soubor obsahuje SQL příkazy pro vložení dat do tabulky.

INSERT INTO TestDB.TestTable (ID, Name) VALUES (1, 'Test Name 1');
INSERT INTO TestDB.TestTable (ID, Name) VALUES (2, 'Test Name 2');
INSERT INTO TestDB.TestTable (ID, Name) VALUES (3, 'Test Name 3');

-- File: D:\vscode\powershell\dwhbi-cicd\Repos\DWHBI\dwhbi.testovaci\DWHI\DWHI-1111\TD\TD03.db.popis.sql
-- Tento soubor obsahuje SQL příkazy pro aktualizaci a mazání dat.

UPDATE TestDB.TestTable
SET Name = 'Updated Name'
WHERE ID = 1;

DELETE FROM TestDB.TestTable
WHERE ID = 3;

