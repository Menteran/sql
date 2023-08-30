CREATE PROCEDURE GenerateCreateTableScript
    @tableName NVARCHAR(128)
AS
BEGIN
    -- Check if the table exists
    IF NOT EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = @tableName
    )
    BEGIN
        PRINT 'Table ' + @tableName + ' does not exist.';
        RETURN;
    END;

    -- Query to generate the SQL script for creating the table
    DECLARE @createTableSQL NVARCHAR(MAX);

    SET @createTableSQL = 'CREATE TABLE ' + QUOTENAME(@tableName) + ' (' + CHAR(13) + CHAR(10);

    DECLARE @columnList NVARCHAR(MAX);

    SELECT @columnList = COALESCE(@columnList + ',' + CHAR(13) + CHAR(10), '') + 
                        '    ' + QUOTENAME(COLUMN_NAME) + ' ' + DATA_TYPE +
                        CASE 
                            WHEN DATA_TYPE IN ('varchar', 'char', 'nvarchar', 'nchar') THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(10)) + ')'
                            WHEN DATA_TYPE IN ('decimal', 'numeric') THEN '(' + CAST(NUMERIC_PRECISION AS NVARCHAR(10)) + ',' + CAST(NUMERIC_SCALE AS NVARCHAR(10)) + ')'
                            ELSE ''
                        END
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @tableName
    ORDER BY ORDINAL_POSITION;

    SET @createTableSQL = @createTableSQL + @columnList + CHAR(13) + CHAR(10) + ');';

    -- Output the SQL script for creating the table
    PRINT @createTableSQL;
END;
