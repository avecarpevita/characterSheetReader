use tm
go
create or ALTER FUNCTION [dbo].[splitName]
(@fullname varchar(255)
RETURNS TABLE
AS
RETURN
select dbo.firstWord
	