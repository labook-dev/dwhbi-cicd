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
