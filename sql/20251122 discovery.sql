--select * from sys.tables

DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

SELECT book.*
FROM OPENJSON(@json)
WITH (
    playerName NVARCHAR(100)
    ,characterName NVARCHAR(100)
	,[events] nvarchar(max) '$.events' as JSON
	,[skills] nvarchar(max) '$.skills' as JSON
) AS book;

