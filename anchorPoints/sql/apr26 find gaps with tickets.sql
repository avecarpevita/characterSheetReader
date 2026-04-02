use tm

drop table if exists #activeCharacters
;with cte_charactersLast3Games as (select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,e.eventDate as rawEventDate
	,convert(varchar(100),null) eventName
	,try_cast(e.eventDate as date) eventDate
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		where eventName like '%event%'
			and (try_cast(e.eventDate as date) between '2025.09.01' and '2026.02.01'
			or eventName like '%event 8[56789]%')
		)
select * 
	into #activeCharacters from cte_charactersLast3Games
update #activeCharacters set playerName=ltrim(rtrim(playerName)), characterName=ltrim(rtrim(characterName))
	,eventName=dbo.cleanRawEventName(rawEventName,rawEventDate)
update #activeCharacters set eventDate=dbo.getEventDate(eventName,rawEventDate)
;with cte as (select *,row_number() over(partition by playerName order by eventdate desc) rn from #activeCharacters) delete cte where rn>1
create unique clustered index pc on #activeCharacters(playerName)

--#activeCharacters where eventDate is null

--fix names as much as possible
declare @eventName nvarchar(255)='Event 90 April 2026'
drop table if exists #tickets
select * 
	,playerName as playerNameSheets
	into #tickets from tickets where eventName=@eventName
drop table if exists #anchorChangeLog
select * 
	,playerName as playerNameFromSheets
	into #anchorChangeLog
	from anchorChangeLog a where a.eventType='C' and a.eventName=@eventName

drop table if exists #playerNames
select playerName,playerNameSheets into #playerNames from #tickets	
	union select playerName,playerNameFromSheets from #anchorChangeLog
create unique clustered index p on #playerNames(playerName)

drop table if exists #work
;with cte as (
select p.playerName,a.playerName playerNameSheets
	,dbo.clr_LevenshteinDistance(left(p.playerName,13),left(a.playerName,13)) playerNameDistance
	from #playerNames p join #activeCharacters a on 1=1
	)
,cte2 as (select *
	,square(playerNameDistance) totalDistance 
	,dbo.matchFromStartCount(playerName,playerNameSheets) playerNameMatchCount
	from cte)
,cte3 as (select *,row_number() over(partition by playerName
	order by playerNameDistance asc,playerNameMatchCount desc) rn from cte2)
select * into #work from cte3 where rn=1
create unique clustered index pp on #work(playerName,playerNameSheets )--#work where  participantRealNameRaw='Gil Ramirez' order by totalDistance


select * from #work order by totalDistance desc--huge mess


update t	
	set t.playerNameSheets=w.playerNameSheets
	from #tickets t join #work w on t.playerName=w.playerName
	where playerNameDistance<=1
update t	
	set t.playerNameFromSheets=w.playerNameSheets
	from #anchorChangeLog t join #work w on t.playerName=w.playerName
		where playerNameDistance<=1






--find those that did not full prereg
select a.* 
	,(select string_agg(ticketType,' ') allTickets from #tickets ti where ti.playerName=a.PlayerName ) allTickets
	,(select string_agg(ticketType,' ') allTickets from #tickets ti where ti.playerNameSheets=a.playerNameFromSheets ) allTickets2
	from #anchorChangeLog a 
		where not exists (select null from #tickets t where t.ticketType like '%full%' and t.playerName=a.playerName)
		and not exists (select null from #tickets t where t.ticketType like '%full%' and t.playerNameSheets=a.playerNameFromSheets)

Ashley Ferrum		select * from tickets where eventName='Event 90 April 2026' and (playerName like '%ash%' or playerName like '%ferr%')		--not there, but advo, giving benefit of the doubt
Caleb Medchill		--n/a, staff
Gwyn				select * from tickets where eventName='Event 90 April 2026' and (playerName like '%Gwyn%') -- Gwyn Schantz, gtg, full event
Jeremiah Rick		select * from tickets where eventName='Event 90 April 2026' and (playerName like '%Rick%' or playerName like '%jer%')		--not there, same
