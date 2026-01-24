use tm


drop table if exists #work
;with cte as (select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	,(select count(*) from rawEvents ri where c.playerName=ri.playerName and c.characterName=ri.characterName and ri.eventName like '%event%') numEvents
	,culture,religion,bloodline,[ip]
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		where eventName like '%event%'
			and (try_cast(e.eventDate as date) between '2024.12.01' and '2026.12.31'
			or eventName like '%event [78][0123456789]%')
		)
select * 
	,tm.dbo.cleanRawEventName(rawEventName,rawEventDate) eventName
	into #work from cte
delete #work where eventName is null

--dedupe to player and event
;with cte as (select *,row_number() over(partition by playerName,eventName order by spentCp desc) rn from #work) delete cte where rn>1

drop table if exists #eventIndex
;with cte as (select distinct eventName from #work)
	select eventName,row_number() over(order by eventName) eventIndex
	into #eventIndex
	from cte
create unique clustered index e on #eventIndex(eventName)

select eventName
	,count(*) playerCount
	,(select count(*) from #work where 
	from #work
	group by eventName
	order by 1


	--we cannot resolve "1st game" yet, because cleanRawEventName needs to go back to the start of time, right?