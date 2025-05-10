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
