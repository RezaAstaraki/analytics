USE TestDB;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users)
BEGIN
    INSERT INTO dbo.Users (Name, Email) VALUES
        (N'Alice Johnson', N'alice@example.com'),
        (N'Bob Smith', N'bob@example.com'),
        (N'Charlie Brown', N'charlie@example.com');
END
GO
