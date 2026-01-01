use tm

--get characters played in the last 3 events
drop table if exists #work
;with cte_charactersLast3Games as (select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,case --when eventName like '%event 84%' then 'Event 84 April 2025'
	when eventName like '%event 85%' then 'Event 85 August 2025'
	when eventName like '%event 86%' then 'Event 86 September 2025' 
	when eventName like '%event 87%' then 'Event 87 December 2025' 
	--when try_cast(e.eventDate as date) between '2025.04.01' and '2025.04.30' then 'Event 84 April 2025'
	when try_cast(e.eventDate as date) between '2025.08.01' and '2025.08.31' then 'Event 85 August 2025'
	when try_cast(e.eventDate as date) between '2025.09.01' and '2025.09.30' then 'Event 85 September 2025'
	when try_cast(e.eventDate as date) between '2025.12.01' and '2025.12.31' then 'Event 87 December 2025'
		end eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		where eventName like '%event%'
			and (try_cast(e.eventDate as date) between '2025.04.01' and '2026.01.01'
			or eventName like '%event 8[4567]%')
		)
select * 
	into #work from cte_charactersLast3Games
		where eventName is not null


select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work group by eventName order by 1



--dedupe to latest event
drop table if exists #deduped
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case 
		when spentCP between 1 and 149 then '[1] under 150 CP'
		when spentCp between 150 and 300 then '[2] 150-300 CP'
		when spentCp between 301 and 450 then '[3] 301-450 CP'
		when spentCp between 451 and 600 then '[4] 451-600 CP'
		when spentCp>=601 then '[5] 601+ CP' end as cpGrouping

		into #deduped from cte where rn=1
--dedupe to player
;with cte as (select *,row_number() over(partition by playerName order by spentCP desc) rn2 from #deduped) delete cte where rn2>1
create unique clustered index cp on #deduped(playerName) --unique to players

--median/avg CP
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spentCP) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--114
select avg(spentCp*1.0) from #deduped--114, 135.452141

--corruption
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY corruption) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--median corruption is 1
select avg(corruption*1.0) from #deduped--avg is 1.5


--bands
select cpGrouping,count(*) numberOfMainCharacters
	,avg(corruption*1.0) avgCorruption
	--,min(corruption) minCorruption,max(corruption) maxCorruption
	from #deduped group by cpGrouping order by 1

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

--parries
;with cte as (select rawSkill,rawCpSpent,characterName
	from rawSkills r
		where exists (select null from #work w where w.characterName=r.characterName)
			and rawSkill like '%parr%' and rawSkill not like '%guar%'
			)
	,cte2 as (select *,try_cast(rawCpSpent as int)/4 numberOfParries from cte)
	--select * from cte2
	select numberOfParries,count(*) numberOfMainCharacters
		from cte2
		group by numberOfParries
		order by 1 desc

select * from rawSkills where rawSkill like '%parr%23%'

--willpower
;with cte as (select rawSkill,rawCpSpent,characterName
	from rawSkills r
		where exists (select null from #work w where w.characterName=r.characterName)
			and rawSkill like '%willpower%' and rawSkill not like '%guar%'
			)
	,cte2 as (select *,try_cast(rawCpSpent as int)/6 numberOfParries from cte)
	--select * from cte2
	select numberOfParries as numberOfWillpowers,count(*) numberOfMainCharacters
		from cte2
		group by numberOfParries
		order by 1 desc

--mana
;with cte_legacy as (select rawSkill,rawCpSpent,characterName
	from rawSkills r
		where exists (select null from #work w where w.characterName=r.characterName)
			and rawSkill like '%mana%' and rawSkill like '%legacy%'
			and try_cast(rawCpSpent as int)>0
			)
	,cte_focus as (select rawSkill,rawCpSpent,characterName
	from rawSkills r
		where exists (select null from #work w where w.characterName=r.characterName)
			and rawSkill like '%mana%' and rawSkill not like '%legacy%'
			and try_cast(rawCpSpent as int)>0
			)
	,cte2 as (select *,try_cast(rawCpSpent as int)*2 as totalMana from cte_legacy	
		union select *,try_cast(rawCpSpent as int) as totalMana from cte_focus)s
	,cte_sum as (select characterName,sum(totalMana) totalMana from cte2 group by characterName)
		--select * from cte_sum where characterName like '%Gae%'
		select totalMana,count(*) numberOfMainCharacters 
			from cte_sum group by totalMana order by 1 desc


			
select * from 	rawEvents		 where characterName in (			select characterName from rawSkills where rawSkill like '%tower%') order by eventDate desc

rawSkills where rawSkill like '%cloak%'
rawSkills where rawSkill like '%lett%'
				