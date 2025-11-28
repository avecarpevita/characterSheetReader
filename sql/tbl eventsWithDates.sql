use tm



drop table if exists #work
select  *,dbo.getEventDate(r.eventName,r.eventDate) cleanEventDate 
	,year(dbo.getEventDate(r.eventName,r.eventDate)) yyyy
	,DateName( month , DateAdd( month , month(dbo.getEventDate(r.eventName,r.eventDate)) , 0 ) - 1 ) monthName
	,DateName( month , DateAdd( month , month(dbo.getEventDate(r.eventName,r.eventDate)) , 0 ) - 1 )+' '+convert(varchar,year(dbo.getEventDate(r.eventName,r.eventDate)) ) eventMonYYYY
	,ltrim(rtrim(eventName)) trimEventName
	,ltrim(rtrim(eventName)) cleanEventName
	into #work
	from rawEvents r where ltrim(rtrim(eventName)) like 'event%'
		and dbo.getEventDate(r.eventName,r.eventDate)>'2011.01.01'


update #work set cleanEventName=case when trimEventName like 'Event [0-9]' then trimEventName
	when trimEventName like 'Event [0-9] %' then left(trimEventName,7)
	when trimEventName like 'Event [0-9][0-9]' then trimEventName
	when trimEventName like 'Event [0-9][0-9][ /:(N]%' then left(trimEventName,8)
	end



drop table if exists #work2
select cleanEventName,eventMonYYYY,count(*) totalCount
	,min(cleanEventDate) minCleanEventDate
	into #work2
	from #work 
	where cleanEventName is not null
	group by cleanEventName,eventMonYYYY order by min(cleanEventDate)



;with cte as (select *,row_number() over(partition by cleanEventName order by totalCount desc,minCleanEventDate) rn from #work2) delete cte where rn>1



drop table if exists eventsWithDates
select cleanEventName+' '+eventMonYYYY eventName
	,minCleanEventDate eventDate

	into eventsWithDates
	from #work2
create unique clustered index e on eventsWithDates(eventName)

select * from eventsWithDates order by 2



