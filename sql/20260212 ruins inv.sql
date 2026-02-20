use tm


drop table if exists #work
;with cte as (
select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,dbo.cleanRawEventName(e.eventName,e.eventDate) eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	,(select count(*) from rawEvents ri where c.playerName=ri.playerName and c.characterName=ri.characterName and ri.eventName like '%event%') numEvents
	,culture rawCulture
	,religion,bloodline,[ip]
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		)
select * 
	,dbo.cleanRawCulture(rawCulture,bloodline) culture
	,convert(date,null) firstEventDate
	,convert(varchar(100), null) firstEventName
	into #work from cte
		where eventName is not null
update w
	set w.eventDate=dbo.getEventDate(eventName,try_cast(rawEventDate as date))
	from #work w
;with cte as (
	select playername,min(eventDate) firstEventDate from #work group by playerName
	)
	update w
		set w.firstEventDate=c.firstEventDate
			,w.firstEventName=(select top 1 eventName from #work i where i.playerName=w.playerName and i.eventDate=c.firstEventDate)
		from #work w join cte c on c.playerName=w.playerName



delete #work where eventDate<dateadd(month,-6,getdate())



--dedupe to latest event
drop table if exists #deduped
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case 
		when spentCP between 1 and 149 and numEvents between 1 and 2 then '[tier 1] 1-2 games'
		when spentCP between 1 and 149 then '[tier 2] 3+ games, under 150 CP'
		when spentCp between 150 and 299 then '[tier 3] 150-299 CP'
		when spentCp between 300 and 449 then '[tier 4] 300-449 CP'
		when spentCp between 450 and 599 then '[tier 5] 450-599 CP'
		when spentCp>=600 then '[tier 6] 600-749 CP' end as cpGrouping

		into #deduped from cte where rn=1

select * from #deduped w
	join rawSkills s on s.characterName=w.characterName and s.playerName=w.playerName and s.rawSkill like '%ruins%' order by culture
	--Alice Tsai
	--Eleanor Wexler
	--Mariam Dittmann