use tm
go
create or alter function matchFromStartCount (@string1 nvarchar(100), @string2 nvarchar(100))
returns int
as
/*
print dbo.matchFromStartCount('taco','greg') 
print dbo.matchFromStartCount('taco','tacx') 
*/
begin
declare @retval int=0
while (left(@string1,@retval+1)=left(@string2,@retval+1) and @retval<=10)
	set @retval+=1


eoj:
return @retval
end