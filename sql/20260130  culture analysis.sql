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

select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work group by eventName order by min(eventDate) desc

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
--dedupe to player
;with cte as (select *,row_number() over(partition by playerName order by spentCP desc) rn2 from #deduped) delete cte where rn2>1
create unique clustered index cp on #deduped(playerName) --unique to players

declare @activeMainCharacters int=(select count(*) from #deduped)
select cpGrouping,count(*),avg(spentCp) from #deduped group by cpGrouping order by 1
select avg(spentCp) from #deduped--140

select top 200 culture
	,count(*) [Active Main Characters] 
	,sum(case when firstEventDate>='2025.09.01' then 1 else 0 end) joinedInLast3Games
	,sum(case when firstEventDate between '2024.12.01' and '2025.08.31' then 1 else 0 end) joinedInLast4to8Games
	,sum(case when firstEventDate<'2020.04.01' then 1 else 0 end) joinedBeforeMists
	,case when culture='Cultural Effendal' then 'Kaelin/Delfestrae/Rae''e''len/Ranes'
	when culture='Amalgamation' then 'combination of Vein/Hastings/ex-Amalgamation nations, still in Mists, no post mists lore doc'
	when culture in ('Trahazi','Vicaul') then 'culture still in the Mists, no post mists lore doc'
	when culture in ('Mandala','Ad Decimum','Gael') then 'culture no longer in rulebook, no post mists lore doc'
	else '' end [comments/notes]
	from #deduped 
		group by culture 
		--having count(*)>=10
		order by 2 desc
		--order by sum(case when firstEventDate>='2024.12.01' then 1.0 else 0 end)/count(*) desc


		select * from #deduped where culture='ko''aat'
		select distinct playerName,characterName,firstEventDate from #work where culture='ko''aat' order by firstEventDate 
		select distinct playerName,characterName,firstEventDate,rawCulture from #work where rawCulture like '%ko''aat%' or rawCulture like '%coatl%' order by firstEventDate 

		#work where playerName like '%hans%'

		#work where playername like '%bill%'

		select * from #deduped where firstEventDate<'2020.04.01' and culture='vicaul'
select * from #deduped where firstEventDate>='2024.12.01' and culture='Mandala'

select fi

culture                                 activeMainCharacters
--------------------------------------- --------------------
Cole                                    75
Castle Thorn                            73
Cultural Effendal                       71
Cestral                                 48
Trahazi                                 48			--missing a lore doc
Paradox: Dawn and Dusk                  44
Redemption                              42
Dace                                    42
Mandala                                 38			--missing a lore doc, never getting one
The Celestine Empire                    38
The Nadine Empire                       38
Amalgamation                            33			--both missing lore docs
Saek                                    30
Ad Decimum                              29			--missing lore doc, never getting one
Newborn Dream - no culture              19
Vicaul                                  18			--missing lore doc
Bastion                                 16
Dhakaar                                 14			--missing new lore doc, right?
Drir                                    13			--missing lore doc
Gael                                    11			--missing lore doc


select * from #deduped  where culture='Trahazi' order by spentCp desc


select rawCulture,count(*) from #deduped where culture='Amalgamation' group by rawCulture order by 2 desc


--can I determine the cultures that are attriting
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

select * from #work where characterName='Ghislain de Concord' order by eventdate desc
rawEvents where characterName='Ghislain de Concord' order by eventdate desc
rawEvents where eventName like '%Event 86%'


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

--look at now (feb2026)
--compared to the state of players by culture in feb2024

drop table if exists #x
select *
	,convert(int,0) active2025
	,convert(int,0) active2024
	,convert(int,0) active2023
	into #x
	from #deduped
create unique clustered index p on #x(playerName)

select characterName,playerName,year(eventdate) eventDateYear,count(*) eventsPlayed
	into #rollup
	from #work
	group by characterName,playerName,year(eventdate)

update x
	set active2025=1
	from #x x join #rollup re on re.characterName=x.characterName and re.playerName=x.playerName
		where eventDateYear=2025 
update x
	set active2024=1
	from #x x join #rollup re on re.characterName=x.characterName and re.playerName=x.playerName
		where eventDateYear=2024
update x
	set active2023=1
	from #x x join #rollup re on re.characterName=x.characterName and re.playerName=x.playerName
		where eventDateYear=2023

select count(*) from #x

select culture
	,sum(active2023) active2023
	,sum(active2024) active2024
	,sum(active2025) active2025
	,sum(active2025)-sum(active2023) cultureChange2Year
	,case when sum(active2023)>0 then (sum(active2025)-sum(active2023))/sum(active2023*1.0) else 0 end cultureChange2YearPerc
	,sum(active2025)-sum(active2024) cultureChange1Year
	,case when sum(active2024)>0 then (sum(active2025)-sum(active2024))/sum(active2024*1.0) else 0 end cultureChange1YearPerc
	
	from #x where len(culture)>3 
	group by culture 
	having count(*)>5
	order by count(*) desc



select * from #x where active2023=1 and active2025=0 and culture='Bastion' order by spentCp desc
select * from #x where active2023=1 and active2025=0 and culture='amalgamation' order by spentCp desc