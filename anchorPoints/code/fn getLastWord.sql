use tm
go
create or alter function getLastWord(@instring varchar(255))
returns varchar(255)
as
begin

declare @work varchar(255)=ltrim(rtrim(reverse(@instring)))
declare @spaceIndex int=patindex('% %',@work)
if isnull(@spaceIndex,0) is null 
	set @spaceIndex=255

	return nullif(ltrim(rtrim(reverse(left(@work,@spaceIndex)))),'')
end