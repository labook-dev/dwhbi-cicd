-- Tento soubor obsahuje SQL příkazy pro inicializaci databáze.

CREATE DATABASE TestDB;
GO

USE TestDB;
GO

CREATE TABLE TestTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Tento soubor obsahuje SQL příkazy pro vložení dat do tabulky.

USE TestDB;
GO

INSERT INTO TestTable (ID, Name) VALUES (1, 'Test Name 1');
INSERT INTO TestTable (ID, Name) VALUES (2, 'Test Name 2');
INSERT INTO TestTable (ID, Name) VALUES (3, 'Test Name 3');
GO

-- Tento soubor obsahuje SQL příkazy pro aktualizaci a mazání dat.

USE TestDB;
GO

UPDATE TestTable
SET Name = 'Updated Name'
WHERE ID = 1;
GO

DELETE FROM TestTable
WHERE ID = 3;
GO

