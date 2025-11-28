use tm
go
create or alter function getEventName (@rawEventName nvarchar(100), @rawEventDate nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)=null

--select  top 100 *,dbo.getEventName(r.eventName,r.eventDate) from rawEvents r where eventName like '%event%' and dbo.getEventName(r.eventName,r.eventDate) is null--only 5 exceptions, which are not recoverable

if @rawEventName not like '%event%' goto eoj
set @rawEventname=ltrim(rtrim(@rawEventname))
set @rawEventname=case when @rawEventname like 'Event [0-9]' then @rawEventname
	when @rawEventname like 'Event [0-9] %' then left(@rawEventname,7)
	when @rawEventname like 'Event [0-9][0-9]' then @rawEventname
	when @rawEventname like 'Event [0-9][0-9][ /:(N]%' then left(@rawEventname,8)
	else @rawEventname end

declare @eventDate date=(select dbo.getEventDate(@rawEventName,@rawEventDate))

select @retVal=eventName from eventsWithDates e where e.eventName like @rawEventname+'%'
if @retval is null select @retVal=eventName from eventsWithDates e where year(@eventDate)=year(e.eventDate) and month(@eventDate)=month(e.eventDate)




	
	

eoj:
return @retval
end
/*

cleanRawLore

*/