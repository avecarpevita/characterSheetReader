use tm
go
create or alter function firstWord ( @instring varchar(255))
returns varchar(255)
begin
declare @retval varchar(255), @space_index int
set @instring=ltrim(rtrim(@instring))
set @space_index = patindex('% %',@instring)

if isnull(@space_index,0)=0 
	set @retval=@instring
else
	set @retval=left(@instring,@space_index-1)



return @retval 
end

--select dbo.firstWord(' taco sales')