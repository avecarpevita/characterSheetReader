use tm

--how clean is the load--compare postMay26 to postApr26
select count(*) from rawCpData--4751
	where characterId is null--0
select count(*) from postApr26.rawCpData--4989
	where characterId is null

select *,dbo.getEventDate(eventName,eventDate) as cleanEventdate into #e from postApr26.rawEvents

select cleanEventdate,count(*)  from postApr26.rawCpData a join #e e on e.characterId=a.characterId and e.cleanEventdate is not null
	where not exists (select null from rawCPData n where n.characterId=a.characterId)
	group by cleanEventDate order by 1 desc
	--167 from april did not load

update c
	set c.characterId=a.characterId
	from rawCPData c
		join postApr26.rawCpData a on a.playerName=c.playerName and a.characterName=c.characterName
			where c.characterId like 'T%' and a.characterId not like 'T%'

update c
	set c.characterId=a.characterId
	from rawCPData c
		join postFeb26.rawCpData a on a.playerName=c.playerName and a.characterName=c.characterName
			where c.characterId like 'T%' and a.characterId not like 'T%'

update c
	set c.characterId=a.characterId
	from rawCPData c
		join postJan26.rawCpData a on a.playerName=c.playerName and a.characterName=c.characterName
			where c.characterId like 'T%' and a.characterId not like 'T%'

select distinct 'C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-s'+rtrim(left(a.playerName,patindex('% %',a.playername)))+'" "-e'
	+rtrim(left(a.playerName,patindex('% %',a.playername)))+'"'
	,* 
	from postApr26.rawCpData a join #e e on e.characterId=a.characterId and e.cleanEventdate is not null 
	where not exists (select null from rawCPData n where n.characterId=a.characterId)
	and e.cleanEventdate in ('2026.04.01','2026.02.01','2026.01.01')
	order by 1

select distinct 'C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-s'+rtrim(left(a.playerName,patindex('% %',a.playername)))+'" "-e'
	+rtrim(left(a.playerName,patindex('% %',a.playername)))+'"'
	,* 
	from postJan26.rawCpData a join #e e on e.characterId=a.characterId and e.cleanEventdate is not null 
	where not exists (select null from rawCPData n where n.characterId=a.characterId)
	and e.cleanEventdate in ('2026.04.01','2026.02.01','2026.01.01')
	order by 1

select distinct 'C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-s'+rtrim(left(a.playerName,patindex('% %',a.playername)))+'" "-e'
	+rtrim(left(a.playerName,patindex('% %',a.playername)))+'"'
	,* 
	from postFeb26.rawCpData a join #e e on e.characterId=a.characterId and e.cleanEventdate is not null 
	where not exists (select null from rawCPData n where n.characterId=a.characterId)
	and e.cleanEventdate in ('2026.04.01','2026.02.01','2026.01.01')
	order by 1

	


--get characters played in the last 3 events
drop table if exists #work
;with cte_charactersLast3Games as (
select c.playerName,c.characterName,c.characterId
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,dbo.cleanRawEventName(e.eventName,e.eventDate) eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	,(select count(*) from rawEvents ri where c.playerName=ri.playerName and c.characterName=ri.characterName and ri.eventName like '%event%') numEvents
	,culture,religion,bloodline,[ip]
	,email
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		)
select * 
	into #work from cte_charactersLast3Games
		where eventName is not null
drop table if exists #x
select distinct rawEventName,rawEventDate,eventName,eventDate into #x from #work e
create unique clustered index rr on #x(rawEventName,rawEventDate)
drop table if exists #x2
update #x
	set eventDate=dbo.getEventDate(eventName,try_cast(e.rawEventDate as date))
	from #x e
update w
	set w.eventDate=x.eventDate
	from #work w join #x x on x.rawEventName=w.rawEventName and x.rawEventDate=x.rawEventDate

select eventName,count(*) from #work group by eventName order by 1 desc--where is 89?

#work where eventDate is null
#work where eventName is null

select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work 
	where eventName>='Event 86 September 2025'
	group by eventName order by min(eventDate) desc

		
--dedupe to latest event
drop table if exists #deduped
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case 
		when spentCP between 1 and 149 and numEvents<3 then '[tier 1] 0-2 games'
		when spentCP between 1 and 149 then '[tier 2] 3+ games, under 150 CP'
		when spentCp between 150 and 300 then '[tier 3] 150-300 CP'
		when spentCp between 301 and 450 then '[tier 4] 301-450 CP'
		when spentCp between 451 and 600 then '[tier 5] 451-600 CP'
		when spentCp>=601 then '[tier 6] 601+ CP' end as cpGrouping

		into #deduped from cte where rn=1
--dedupe to player
;with cte as (select *,row_number() over(partition by playerName order by spentCP desc) rn2 from #deduped) delete cte where rn2>1
;with cte as (select *,row_number() over(partition by email order by spentCP desc) rn2 from #deduped where email like '%_@%.___') delete cte where rn2>1
create unique clustered index cp on #deduped(playerName) --unique to players
select * from #deduped where email not like '%_@%.___'



--retain only last 3 games (Sep25, Dec25, Jan26)
delete #deduped where eventName<'Event 89 February 2026'

select * from #deduped where spentCp>='300' order by eventDate
select * from #deduped where spentCp>='300' order by spentCp desc

select * from #deduped d  where spentCp>='300' 
	and not exists (select null from anchorChangeLog a where a.characterId=d.characterId)
	order by spentCp desc

select eventName,count(*) 
	from #deduped
	group by eventName
	order by 1 desc

select convert(varchar(30),dbo.cleanRawCulture(culture,bloodline)) culture
	,count(*) [# active main characters]
	from #deduped group by dbo.cleanRawCulture(culture,bloodline) order by 2 desc

select dbo.cleanRawReligion(religion) religion
	,count(*) [# active main characters]
	from #deduped group by dbo.cleanRawReligion(religion) order by 2 desc



--median/avg CP
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spentCP) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--114
select avg(spentCp*1.0) from #deduped--120, 139.200517

--bands
declare @total float=(select count(*) from #deduped)
select cpGrouping,count(*) [# active main characters]
	,convert(varchar,convert(numeric(4,1),count(*)/@total*100))+'%' percentageOfPlayers
	from #deduped where cpGrouping is not null
		group by cpGrouping order by 1

select count(*) from #deduped where spentCp>=451 order by spentCp desc
#deduped where spentCp>=451 order by spentCp desc
	
declare @total float=(select count(*) from #deduped)
select cpGrouping,count(*) [# active main characters]
	,convert(varchar,convert(numeric(4,1),count(*)/@total*100))+'%' percentageOfPlayers
	from #deduped where cpGrouping is not null and eventName='Event 89 February 2026'
		group by cpGrouping order by 1
	

select * from #deduped order by spentCp desc

Scott Ross			Bonk
Jordan Hassay		Vibes
Kai Norman			Vibes
Chris Montgomery	Lore Nerd
Stephen McArthur	Bonk
Loryanna Michalek	Vibes
Brian Brown			Vibes
Kyle Duong			Vibes
Richard Choi		Vibes
Jeremy Fariss		Bonk