-- Tento soubor obsahuje SQL příkazy pro aktualizaci a mazání dat.

UPDATE TestDB.TestTable
SET Name = 'Updated Name'
WHERE ID = 1;

DELETE FROM TestDB.TestTable
WHERE ID = 3;
