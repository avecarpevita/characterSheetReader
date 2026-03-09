use tm

--select distinct tickettype from tickets where eventName='Event 86 September 2025' order by 1

declare @eventName nvarchar(255)='Event 87 December 2025'

select a.* 
	,t.ticketType
	,(select string_agg(ticketType,' ') allTickets from tickets ti where ti.playerName=a.PlayerName and ti.eventName=@eventName) allTickets
	from anchorChangeLog a 
	left join tickets t on a.playerName=t.playerName
		and a.eventName=@eventName
		and t.eventName=@eventName --changing this later
		and t.ticketType like '%full%'
	where (t.eventName is null		--they didn't get a full ticket
		--they have a full ticket that conflicts
		or (a.timeSlot='FriPM' and t.ticketType in ('Full Event: NPC Friday 10pm-2am','Full Event: NPC Friday 8pm-12am'))						
		or (a.timeSlot='SatAM' and t.ticketType in ('Full Event: NPC Saturday 8am-12pm'))						
		or (a.timeSlot='SatPM' and t.ticketType in ('Full Event: NPC Saturday 6pm-10pm','Full Event: NPC Saturday 8am-12pm','Full Event: NPC Saturday 10pm-2am'))						
		
		)

--basically have to manually spot this and update tbl anchorChangeLog accordingly
--Eleanor Wexler
update c	
	set notes='did not pre-reg'
	from anchorChangeLog c where eventName='Event 87 December 2025' and eventType='C' and playerName in ('Eleanor Wexler','Morgan Smith')
update c	
	set notes='committed for FriPM extra npc, ticket shift is the same -- Full Event: NPC Friday 10pm-2am'
	from anchorChangeLog c where eventName='Event 87 December 2025' and eventType='C' and playerName in ('Jose Favela')