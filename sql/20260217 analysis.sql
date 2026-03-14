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

#work where eventDate is null
#work where eventName is null

select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work 
	where eventName>='Event 86 September 2025'
	group by eventName order by min(eventDate) desc

		

---------------------------------------------------------------------------------------------------- ----------- --------------
Event 88 January 2026                                                                                581         679
Event 87 December 2025                                                                               609         737
Event 85 August 2025                                                                                 491         590
Event 86 September 2025                                                                              475         567
Event 84 April 2025                                                                                  656         777
Event 83 March 2025                                                                                  638         757
Event 82 February 2025                                                                               624         736
Event 80 November 2024                                                                               572         664
Event 81 December 2024                                                                               588         687
Event 79 September 2024                                                                              560         652
Event 78 August 2024                                                                                 549         644
Event 76 April 2024                                                                                  484         568
Event 75 March 2024                                                                                  483         568
Event 73 December 2023                                                                               535         616
Event 72 October 2023                                                                                608         693
Event 71 September 2023                                                                              519         598
Event 77 July 2024                                                                                   494         584
Event 74 February 2024                                                                               529         617
Event 65 December 2022                                                                               445         517
Event 64 November 2022                                                                               488         557
Event 63 September 2022                                                                              450         504
Event 62 August 2022                                                                                 428         488
Event 70 August 2023                                                                                 525         606
Event 69 July 2023                                                                                   553         643
Event 68 April 2023                                                                                  541         628
Event 60 April 2022                                                                                  441         495
Event 67 March 2023                                                                                  496         577
Event 66 February 2023                                                                               410         478
Event 59 March 2022                                                                                  431         481
Event 56 November 2021                                                                               415         457
Event 57 December 2021                                                                               409         460
Event 61 July 2022                                                                                   388         437
Event 58 February 2022                                                                               421         470
Event 55 September 2021                                                                              366         399

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
delete #deduped where eventName<'Event 86 September 2025'

select eventName,count(*) 
	from #deduped
	group by eventName
	order by 1 desc

select top 300 dbo.cleanRawCulture(culture,bloodline) culture
	,count(*) [# active main characters]
	from #deduped group by dbo.cleanRawCulture(culture,bloodline) order by 2 desc

select top 20 dbo.cleanRawReligion(religion) religion
	,count(*) [# active main characters]
	from #deduped group by dbo.cleanRawReligion(religion) order by 2 desc

select top 20 dbo.cleanRawReligion(religion) religion
	,count(*) [# active main characters]
	from #deduped where cpGrouping in ('[tier 1] 0-2 games')
	group by dbo.cleanRawReligion(religion) order by 2 desc

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
		
/*
select * from #deduped where spentCp>=300
#deduped where playerName like '%oliv%'
#deduped where playerName like '%liza%'

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


