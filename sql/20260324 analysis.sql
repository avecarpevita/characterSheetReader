use tm

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
delete #deduped where eventName<'Event 87 December 2025'

select eventName,count(*) 
	from #deduped
	group by eventName
	order by 1 desc

select top 10 convert(varchar(30),dbo.cleanRawCulture(culture,bloodline)) culture
	,count(*) [# active main characters]
	from #deduped group by dbo.cleanRawCulture(culture,bloodline) order by 2 desc

select top 30 dbo.cleanRawReligion(religion) religion
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


select top 100 * from rawSkills s where rawSkill like 'Black%Market%4%' 
select top 100 * from rawSkills s where rawSkill like 'Herbalism%4%' 
select top 100 * from rawSkills s where rawSkill like 'Mining%4%' 
select top 100 * from rawSkills s where rawSkill like 'Woodcutting%4%' 
select top 100 * from rawSkills s where rawSkill like 'Mercantile%4%' 
select top 100 * from rawSkills s where rawSkill like 'Hunting%4%' 
select top 100 * from rawSkills s where rawSkill like 'Academic%4%' 
select top 100 * from rawSkills s where rawSkill like 'Economic%4%' 
select top 100 * from rawSkills s where rawSkill like 'Military%4%' 
select top 100 * from rawSkills s where rawSkill like 'Political%4%' 
select top 100 * from rawSkills s where rawSkill like 'Underworld%4%' 

select top 100 * from #deduped d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Black%Market%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Herbalism%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mining%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Woodcutting%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mercantile%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Hunting%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mining%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Academic%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Economic%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Military%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Political%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Underworld%4%')


drop table if exists #dedupedCharacter
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case 
		when spentCP between 1 and 149 and numEvents<3 then '[tier 1] 0-2 games'
		when spentCP between 1 and 149 then '[tier 2] 3+ games, under 150 CP'
		when spentCp between 150 and 300 then '[tier 3] 150-300 CP'
		when spentCp between 301 and 450 then '[tier 4] 301-450 CP'
		when spentCp between 451 and 600 then '[tier 5] 451-600 CP'
		when spentCp>=601 then '[tier 6] 601+ CP' end as cpGrouping

		into #dedupedCharacter from cte where rn=1
--dedupe to character

--retain only last 3 games (Sep25, Dec25, Jan26)
delete #dedupedCharacter where eventName<'Event 87 December 2025'


select top 100 * from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Black%Market%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Herbalism%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mining%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Woodcutting%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mercantile%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Hunting%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Mining%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Academic%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Economic%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Military%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Political%4%')
	and exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like 'Underworld%4%')


select top 100 * from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') order by 1--43 characters with the lore
select distinct email from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') order by 1--43 characters with the lore

select email from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') group by email having count(*)>1--43 characters with the lore


select top 100 * from #deduped d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') --order by eventName--43 characters with the lore
	and not exists (select null from #dedupedCharacter dc where dc.characterId=d.characterId)
	
select email from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') 
	and not exists (select email from #deduped d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%'))




select top 100 * from #dedupedCharacter d where exists (select null from rawSkills s where s.characterId=d.characterId and s.rawSkill like '%lore%treat%') order by eventDate--43 characters with the lore

select * from #dedupedCharacter where spentCp between 143 and 149--18
select * from #dedupedCharacter where spentCp between 136 and 142--27
select * from #dedupedCharacter where spentCp between 129 and 135--26
select * from #dedupedCharacter where spentCp between 122 and 128--30


select * from #dedupedCharacter where characterName like 'd%n%'
select * from #dedupedCharacter where characterName like 'a%a%' and culture like '%nad%'

Elliot Gutierrez	Daman Fercilaine
Fritz Phillips		Azura Strigindae