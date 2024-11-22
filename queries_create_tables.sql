
DROP TABLE IF EXISTS dbo.stg_dimemp;

-- create table stg_dimemp
SELECT EmployeeKey, FirstName, LastName, Title
INTO dbo.stg_dimemp
FROM dbo.DimEmployee
WHERE EmployeeKey BETWEEN 270 AND 275;


DROP TABLE IF EXISTS dbo.scd_dimemp;

-- create table scd_dimemp
CREATE TABLE dbo.scd_dimemp (
    EmployeeKey int,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL,
    Title nvarchar(50),
    StartDate datetime,
    EndDate datetime
);

-- upload data from DimEmployee
SELECT EmployeeKey, FirstName, LastName, Title, StartDate, EndDate
FROM dbo.DimEmployee
WHERE EmployeeKey >=  270 AND EmployeeKey <= 275;


