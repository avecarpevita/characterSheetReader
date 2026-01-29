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
		)
select * 
	,tm.dbo.cleanRawEventName(rawEventName,rawEventDate) eventName
	,cast(null as int) eventNum
	into #work from cte
delete #work where eventName is null

--dedupe to player and event
;with cte as (select *,row_number() over(partition by playerName,eventName order by spentCp desc) rn from #work) delete cte where rn>1
update w
	set eventNum=try_cast(left(replace(eventName,'Event ','')
		,patindex('% %',replace(eventName,'Event ',''))) as int)
	from #work w
delete #work where eventNum is null 

--get first game for each player
select playerName,min(eventNum) from #work group by playerName order by 2

--then get retention -- how many games played after first game
drop table if exists #retentionBase
;with cte_firstgame as (select playerName,min(eventNum) firstEventNum
	,max(eventNum) lastEventNum
	,count(eventNum) totalGamesPlayed
	from #work group by playerName)
	select * 
		,(select count(*) from #work w where w.playerName=c.playerName and w.eventNum>c.firstEventNum) gamesPlayedAfterFirst
		into #retentionBase
		from cte_firstgame c
		order by 2

drop table if exists #eventIndex
select distinct eventNum,eventName 
	into #eventIndex
	from #work order by 1

;with cte as (
	select (select eventName from #eventIndex where eventNum=firstEventNum) eventName
	,(select right(eventName,4) from #eventIndex where eventNum=firstEventNum) eventYear
	,count(*) totalPlayersFirstEvent
	,sum(case when totalGamesPlayed>=3 then 1 else 0 end) retention3Games
	,sum(case when totalGamesPlayed>=3 then 1.0 else 0 end)/count(*) retentionRate3Games
	,sum(case when totalGamesPlayed>=12 then 1.0 else 0 end)/count(*) retentionRate12Games
	from #retentionBase 
		--where firstEventNum<=85
	group by firstEventNum
	--order by firstEventNum desc
	)
select eventYear,avg(retentionRate3Games) avg_retentionRate3Games
	,avg(retentionRate12Games) avg_retentionRate12Games
	,sum(totalPlayersFirstEvent) totalPlayersFirstEvent
	from cte group by eventYear order by 1 desc

--basically, any new player stays to become a "vet" 25%+ of the time, and stays for 3 games 50%