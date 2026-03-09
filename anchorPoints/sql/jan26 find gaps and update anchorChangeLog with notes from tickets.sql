use tm

drop table if exists #activeCharacters
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
	into #activeCharacters from cte_charactersLast3Games
		where eventName is not null
update #activeCharacters set playerName=ltrim(rtrim(playerName)), characterName=ltrim(rtrim(characterName))
;with cte as (select *,row_number() over(partition by playerName order by eventdate desc) rn from #activeCharacters) delete cte where rn>1
create unique clustered index pc on #activeCharacters(playerName)


--fix names as much as possible
declare @eventName nvarchar(255)='Event 88 January 2026'
drop table if exists #tickets
select * 
	,playerName as playerNameFromSheets
	into #tickets from tickets where eventName=@eventName
select * 
	,playerName as playerNameFromSheets
	into #anchorChangeLog
	from anchorChangeLog a where a.eventType='C' and a.eventName=@eventName

drop table if exists #playerNames
select playerName,playerNameFromSheets into #playerNames from #tickets	
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

select * from #work order by totalDistance desc

update t	
	set t.playerNameFromSheets=w.playerNameSheets
	from #tickets t join #work w on t.playerName=w.playerName
update t	
	set t.playerNameFromSheets=w.playerNameSheets
	from #anchorChangeLog t join #work w on t.playerName=w.playerName







--find those that did not full prereg
select a.* 
	,(select string_agg(ticketType,' ') allTickets from #tickets ti where ti.playerName=a.PlayerName ) allTickets
	,(select string_agg(ticketType,' ') allTickets from #tickets ti where ti.playerNameFromSheets=a.playerNameFromSheets ) allTickets2
	from #anchorChangeLog a 
		where not exists (select null from #tickets t where t.ticketType like '%full%' and t.playerName=a.playerName)
		and not exists (select null from #tickets t where t.ticketType like '%full%' and t.playerNameFromSheets=a.playerNameFromSheets)

Greywhisker				select top 100 * from #tickets where playerName like '%geof%'
Kandoryn				select top 100 * from #tickets where playerName like '%hayes%'
Nicole Hunsicker		select top 100 * from #tickets where playerName like '%huns%'
Melissa Melendez		select top 100 * from tickets where playerName like '%melendez%'--don't see it
Michel Wong				select top 100 * from tickets where playerName like '%wong%'--don't see it
Najva Sol				select top 100 * from tickets where playerName like '%sol%'--don't see it

declare @eventName nvarchar(255)='Event 88 January 2026'
update c	
	set notes='did not pre-reg'
	from 
	--declare @eventName nvarchar(255)='Event 88 January 2026'; select top 100 * from
	anchorChangeLog c where eventName=@eventName and eventType='C' and playerName in ('Melissa Melendez','Najva Sol','Michel Wong')

declare @eventName nvarchar(255)='Event 88 January 2026'
select a.* 
	,t.ticketType
	,t.eventName ticketEventName
	,(select string_agg(ticketType,' ') allTickets from tickets ti where ti.playerName=a.PlayerName and ti.eventName=@eventName) allTickets
	from anchorChangeLog a 
	left join tickets t on a.playerName=t.playerName
		where a.eventName=@eventName
		and t.eventName=@eventName 
		and t.ticketType like '%full%' and a.eventType='C'
	and (t.eventName is null		--they didn't get a full ticket
		--they have a full ticket that conflicts
		or (a.timeSlot='FriPM' and t.ticketType in ('Full Event: NPC Friday 10pm-2am','Full Event: NPC Friday 8pm-12am'))						
		or (a.timeSlot='SatAM' and t.ticketType in ('Full Event: NPC Saturday 8am-12pm'))						
		or (a.timeSlot='SatAF' and t.ticketType in ('Full Event: NPC Saturday 12pm- 4pm'))						
		or (a.timeSlot='SatPM' and t.ticketType in ('Full Event: NPC Saturday 6pm-10pm','Full Event: NPC Saturday 8am-12pm','Full Event: NPC Saturday 4pm- 8pm'))						
		
		)

declare @eventName nvarchar(255)='Event 88 January 2026'
update c	
	set notes='committed for '+timeslot+' extra npc, ticket shift overlaps -- '+(select string_agg(ticketType,' ') allTickets from tickets ti where ti.playerName=c.PlayerName and ti.eventName=@eventName) 
	--declare @eventName nvarchar(255)='Event 88 January 2026'; select top 100 * 
	from anchorChangeLog c where eventName=@eventName and eventType='C' and playerName in ('Jose Favela','Zach Stark')