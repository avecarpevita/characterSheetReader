use tm
go
create or alter proc buildAnchorPointSheet
as
/*
builds the updated sheet from tbl anchorChangeLog
I then use that to full replace my detailed sheet
that will also be a DUMP of anchorChangeLog -- which I can modifiy and re-import to restate anchorChangeLog
*/
begin
set nocount on

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
	into #points from anchorChangeLog group by PlayerName

--dump current rollups for printing
--sheet is here https://docs.google.com/spreadsheets/d/1Mx0VpTE4YvObCOEV7enUb0DZof-AkbekaFARlq6kXWI
select p.playerName
	,isnull(e.earningEvents,'') earningEvents
	,isnull(s.spendEvents,'') spendEvents
	,isnull(s.spendEventsScrubbed,'') spendEventsScrubbed
	,p.pointsRemaining
	,isnull(p.notes,'') notes
	from #points p
		left join #earned e on e.playerName=p.playerName
		left join #spent s on s.playerName=p.playerName
order by p.playerName 

--dump the log to store in the 2nd tab for backup
select * from anchorChangeLog order by 1

--third gives me the negatives with emails


select p.playerName
	,isnull(e.earningEvents,'') earningEvents
	,isnull(s.spendEvents,'') spendEvents
	,isnull(s.spendEventsScrubbed,'') spendEventsScrubbed
	,p.pointsRemaining
	,(select top 1 email from rawCPData r where r.playerName=p.playerName) email
	from #points p
		left join #earned e on e.playerName=p.playerName
		left join #spent s on s.playerName=p.playerName
		where p.pointsRemaining<0
order by p.pointsRemaining


end