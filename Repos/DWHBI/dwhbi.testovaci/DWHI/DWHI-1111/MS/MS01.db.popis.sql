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
