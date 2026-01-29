use tm

--get characters played in the last 3 events
drop table if exists #work
;with cte_charactersLast3Games as (
select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,dbo.cleanRawEventName(e.eventName,e.eventDate) eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	,(select count(*) from rawEvents ri where c.playerName=ri.playerName and c.characterName=ri.characterName and ri.eventName like '%event%') numEvents
	,culture,religion,bloodline,[ip]
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		)
select * 
	into #work from cte_charactersLast3Games
		where eventName is not null
update w
	set w.eventDate=dbo.getEventDate(eventName,rawEventDate)
	from #work w

delete #work where eventDate<'2020.01.01'

select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work group by eventName order by min(eventDate) desc

eventName                                                                                            playerCount characterCount
---------------------------------------------------------------------------------------------------- ----------- --------------
Event 87 December 2025                                                                               592         716
Event 86 September 2025                                                                              469         561
Event 85 August 2025                                                                                 490         589
Event 84 April 2025                                                                                  656         775
Event 83 March 2025                                                                                  637         755
Event 82 February 2025                                                                               624         734
Event 81 December 2024                                                                               588         686
Event 80 November 2024                                                                               574         666
Event 79 September 2024                                                                              564         655
Event 78 August 2024                                                                                 552         647
Event 77 July 2024                                                                                   501         591
Event 76 April 2024                                                                                  484         568
Event 75 March 2024                                                                                  484         568
Event 74 February 2024                                                                               530         617

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
create unique clustered index cp on #deduped(playerName) --unique to players

--retain only last 3 games (Sep25, Dec25, Jan26)
delete #deduped where eventDate<'2025.09.01'

select eventName,count(*) 
	from #deduped
	group by eventName


select top 10 dbo.cleanRawCulture(culture,bloodline) culture
	,count(*) numberOfMainCharacters
	from #deduped group by dbo.cleanRawCulture(culture,bloodline) order by 2 desc

select top 10 dbo.cleanRawReligion(religion) culture
	,count(*) numberOfMainCharacters
	from #deduped group by dbo.cleanRawReligion(religion) order by 2 desc

--median/avg CP
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spentCP) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--114
select avg(spentCp*1.0) from #deduped--114, 135.452141

--bands
declare @total float=(select count(*) from #deduped)
select cpGrouping,count(*) numberOfMainCharacters
	,convert(varchar,convert(numeric(4,1),count(*)/@total*100))+'%' percentageOfPlayers
	from #deduped 
		group by cpGrouping order by 1

/*
```
eventName               playerCount characterCount
----------------------- ----------- --------------
Event 85 August 2025    505         608
Event 86 September 2025 476         569
Event 87 December 2025  604         731

"active" players -- played in the last 3 games, only counting "main" characters
cpGrouping       numberOfMainCharacters avgCorruption
---------------- ---------------------- ---------------------------------------
[1] under 150 CP 493                    1.306288
[2] 150-300 CP   253                    1.944664
[3] 301-450 CP   38                     1.578947
[4] 451-600 CP   10                     1.900000

median CP = 114, average CP = 135
```
*/



