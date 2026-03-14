use tm

--ALL OF THIS FUNCTIONALITY IS NOW IN sp buildAnchorPointSheet

/*

drop table if exists #earned
select playerName
	--rollup event/timeslot commitments
	,STRING_AGG(eventName+' '+timeSlot+'('+convert(varchar,pointChange)+')', ', ') earningEvents
	into #earned
	from anchorChangeLog where eventType='c'
	group by playerName



	--select * from anchorChangeLog
drop table if exists #spent--select * from #spent
select playerName
	--rollup event/timeslot commitments
	,STRING_AGG(eventName+' '+spendReason, ', ') spendEvents
	,STRING_AGG(eventName, ', ') spendEventsScrubbed
	into #spent
	from anchorChangeLog a 
		where eventType='S'
	group by playerName

drop table if exists #points
select playerName
	,sum(pointChange) pointsRemaining 
	,STRING_AGG(eventName+': '+notes, ', ') notes
	,min(characterId) characterId
	into #points from anchorChangeLog group by PlayerName

drop table if exists #allPlayers
select p.playerName
	,isnull(e.earningEvents,'') earningEvents
	,isnull(s.spendEvents,'') spendEvents
	,isnull(s.spendEventsScrubbed,'') spendEventsScrubbed
	,p.pointsRemaining
	,isnull(p.notes,'') notes
	,characterId
	into #allPlayers
	from #points p
		left join #earned e on e.playerName=p.playerName
		left join #spent s on s.playerName=p.playerName
		
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



select a.*,r.email
	,(select eventName from #deduped e where e.playerName=r.playerName) eventName
	,(select top 1 eventName+' '+ticketType from tickets t where t.playerName=r.playerName order by eventDate desc)
	from #allPlayers a 
		left join rawCpData r on r.characterId=a.characterId
		where pointsRemaining<0
		order by playerName

/*

crfelley@gmail.com
heradewan@gmail.com
mtlancaster54@gmail.com
green.left.eye@gmail.com
awarenyx@gmail.com

My records show that you are in the negative on anchor points. 
I've just posted the opportunities for the April event here.
https://discord.com/channels/168929364271038464/747663220143292507/1482018373989826602
The tracking form is here:
https://docs.google.com/spreadsheets/d/1VXufjsrcyVLM6Oyhq22-CifnUq2dm6AXEPO-V8h9QCc/edit?usp=sharing

If there's an error, please let me know.

*/