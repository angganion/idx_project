USE DWH;
GO

CREATE OR ALTER PROCEDURE dbo.DailyTransaction
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(TransactionDate AS DATE) AS [Date],
        COUNT(*) AS TotalTransactions,
        SUM(Amount) AS TotalAmount
    FROM dbo.FactTransaction
    WHERE TransactionDate >= @start_date
      AND TransactionDate < DATEADD(DAY, 1, @end_date)
    GROUP BY CAST(TransactionDate AS DATE)
    ORDER BY [Date];
END;
GO

CREATE OR ALTER PROCEDURE dbo.BalancePerCustomer
    @name VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.CustomerName,
        a.AccountType,
        a.Balance,
        a.Balance + ISNULL(SUM(CASE WHEN t.TransactionType = 'Deposit' THEN t.Amount ELSE -t.Amount END), 0) AS CurrentBalance
    FROM dbo.DimAccount a
    JOIN dbo.DimCustomer c
        ON a.CustomerID = c.CustomerID
    LEFT JOIN dbo.FactTransaction t
        ON a.AccountID = t.AccountID
    WHERE a.Status = 'active'
      AND c.CustomerName LIKE '%' + @name + '%'
    GROUP BY c.CustomerName, a.AccountType, a.Balance;
END;
GO
