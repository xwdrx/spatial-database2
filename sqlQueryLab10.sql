CREATE DATABASE lab10;
use lab10;

CREATE TABLE Customers_402789 (
    ProductKey INT,
    CurrencyAlternateKey VARCHAR(3),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    OrderDateKey INT,
    OrderQuantity INT,
    UnitPrice VARCHAR(24),
    SecretCode VARCHAR(10) NULL
);

UPDATE CUSTOMERS_402789
SET SecretCode = LEFT(CAST(NEWID() AS VARCHAR(36)), 10);

select * from lab10.dbo.Customers_402789;

--drop table lab10.dbo.Customers_402789;
