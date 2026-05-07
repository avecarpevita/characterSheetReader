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

		
delete #work where eventDate<'2026.01.01'

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

drop table if exists #darkRaw 
select rawSkill,count(*) characterCount into #darkRaw from #deduped d
	left join rawSkills s on s.characterId=d.characterId
	where s.rawSkill not like '%lore%' 
		and (s.rawSkill like '%necromancy%' or s.rawSkill like '%summoning%' or s.rawSkill like '%blood mag%' or s.rawSkill like '%dream mag%')
	group by rawSkill order by 2

;with cte as (
select * 
	,case when rawSkill like '%necromancy%' then 'Necromancy'
		when rawSkill like '%summoning%' then 'Summoning'
		when rawSkill like '%Blood Mag%' then 'Blood Magic'
		when rawSkill like '%Dream Mag%' then 'Dream Magic' else null end darkMagic
	,case when rawSkill like '% Master%' then 3
		when rawSkill like '%grandmaster%' then 4
		when rawSkill like '%paragon%' then 5
		when rawSkill like '%app%en%' then 1
		when rawSkill like '%journe%' then 2 else null end ranks

	from #darkRaw
)
	select darkMagic,sum(ranks*characterCount) totalActiveRanks 
		,sum(characterCount) totalActiveCharacters
		from cte group by darkMagic order by 2 desc


--culture