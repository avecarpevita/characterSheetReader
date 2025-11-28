use tm
go
create or alter function getEventDate (@rawEventName nvarchar(100), @rawEventDate nvarchar(100))
returns date
as
begin
declare @retval date=null

--select  top 100 *,dbo.getEventDate(r.eventName,r.eventDate) from rawEvents r where eventName like '%event%' and dbo.getEventDate(r.eventName,r.eventDate) is null
--ultimately, I want to resolve to this 'Event 84 April 2025'
declare @rawDateWork nvarchar(100)
set @rawEventDate=ltrim(rtrim(@rawEventDate))
set @rawEventName=ltrim(rtrim(@rawEventName))

--don't even bother with lines without event
if @rawEventName not like '%event%' goto eoj
set @retval=try_cast(@rawEventDate as date)
if @retval is null and @rawEventDate like '[1-9][-/]%20[0-9][0-9]%' set @retVal=try_cast('0'+left(@rawEventDate,1)+'/01/'+right(@rawEventDate,4) as date)
if @retval is null and @rawEventDate like '1[0-2][-/]%20[0-9][0-9]%' set @retVal=try_cast(left(@rawEventDate,2)+'/01/'+right(@rawEventDate,4) as date)
if @retval is null and @rawEventDate like '0[0-9][-/]%20[0-9][0-9]%' set @retVal=try_cast(left(@rawEventDate,2)+'/01/'+right(@rawEventDate,4) as date)
	
	

eoj:
return @retval
end
/*

cleanRawLore

*/