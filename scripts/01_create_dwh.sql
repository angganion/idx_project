IF DB_ID('DWH') IS NULL
    CREATE DATABASE DWH;
GO

USE DWH;
GO

IF OBJECT_ID('dbo.FactTransaction', 'U') IS NOT NULL DROP TABLE dbo.FactTransaction;
IF OBJECT_ID('dbo.DimAccount', 'U') IS NOT NULL DROP TABLE dbo.DimAccount;
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NOT NULL DROP TABLE dbo.DimCustomer;
IF OBJECT_ID('dbo.DimBranch', 'U') IS NOT NULL DROP TABLE dbo.DimBranch;
GO

CREATE TABLE dbo.DimBranch (
    BranchID       INT PRIMARY KEY,
    BranchName     VARCHAR(50),
    BranchLocation VARCHAR(50)
);
GO

CREATE TABLE dbo.DimCustomer (
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Address      VARCHAR(MAX),
    CityName     VARCHAR(50),
    StateName    VARCHAR(50),
    Age          VARCHAR(3),
    Gender       VARCHAR(10),
    Email        VARCHAR(50)
);
GO

CREATE TABLE dbo.DimAccount (
    AccountID   INT PRIMARY KEY,
    CustomerID  INT NOT NULL,
    AccountType VARCHAR(10),
    Balance     INT,
    DateOpened  DATETIME2,
    Status      VARCHAR(10),
    CONSTRAINT FK_DimAccount_DimCustomer FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID)
);
GO

CREATE TABLE dbo.FactTransaction (
    TransactionID   INT PRIMARY KEY,
    AccountID       INT NOT NULL,
    TransactionDate DATETIME2,
    Amount          INT,
    TransactionType VARCHAR(50),
    BranchID        INT NOT NULL,
    CONSTRAINT FK_FactTransaction_DimAccount FOREIGN KEY (AccountID) REFERENCES DimAccount(AccountID),
    CONSTRAINT FK_FactTransaction_DimBranch  FOREIGN KEY (BranchID)  REFERENCES DimBranch(BranchID)
);
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

SELECT
    tc.TABLE_NAME,
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_SCHEMA = 'dbo'
ORDER BY tc.TABLE_NAME, tc.CONSTRAINT_TYPE;
GO
