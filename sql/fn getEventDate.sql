use tm
go
create or alter function getEventDate (@rawEventName nvarchar(100),@rawEventDate date)
returns date
as
begin
declare @retval date=null


--declare @rawEventName nvarchar(100)='Event 87 December 2025',@rawEventDate date=null
declare @eventName nvarchar(100)=dbo.cleanRawEventName(@rawEventName,@rawEventDate)

if @eventName not like 'Event%' goto eoj
set @eventName=replace(@eventName,'Event ','')

set @eventName=ltrim(rtrim(substring(@eventName,patindex('% %',@eventName),100)))

set @eventName=ltrim(rtrim(replace(@eventName,' ',' 1 ')))--Should not be something like 'December 1 2025'

declare @try varchar(20)=try_cast(@eventName as date) 
	
	set @retVal=@try

--select dbo.getEventDate('Event 87 December 2025',null)
--select dbo.cleanRawEventName('Event 87 December 2025',null)
	

eoj:
return @retval
end
/*

cleanRawLore

*/