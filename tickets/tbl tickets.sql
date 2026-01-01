--C:\characterSheetReader\tickets\tbl tickets.sql
use tm

--select top 100 * from sys.tables order by create_date desc--rawCpData
--select * from eventsWithDates order by 2 desc

drop table if exists tickets
create table tickets (eventName nvarchar(255) not null
	,eventDate date not null
	,rawPlayerName nvarchar(255)
	,playerName nvarchar(255)
	,ticketType nvarchar(255)
	,insertDate datetime not null default getdate()
	)


drop table if exists #allRawTickets
create table #allRawTickets (
	id int identity(1,1) not null primary key clustered
	,eventName nvarchar(255) not null
	,eventDate date not null
	,fn nvarchar(255), ln nvarchar(255), ticketType nvarchar(255), rawPlayerName nvarchar(255)
	,matchedPlayerName nvarchar(255)
	)

--select top 100 * from eventsWithDates order by 2 desc
--insert into eventsWithDates select 'Event 87 December 2025','2025.12.01'

drop table if exists #bi
create table #bi (fn nvarchar(255), ln nvarchar(255), ticketType nvarchar(255), rawPlayerName nvarchar(255))
bulk insert #bi from 'C:\characterSheetReader\tickets\mar25.tsv' with(datafiletype='char')
insert into #allRawTickets (eventName,eventDate,fn,ln,ticketType,rawPlayerName)
	select eventName,eventDate,fn,ln,ticketType,rawPlayerName from #bi b
		join eventsWithDates e on e.eventName='Event 83 March 2025'
truncate table #bi
bulk insert #bi from 'C:\characterSheetReader\tickets\apr25.tsv' with(datafiletype='char')
insert into #allRawTickets (eventName,eventDate,fn,ln,ticketType,rawPlayerName)
	select eventName,eventDate,fn,ln,ticketType,rawPlayerName from #bi b
		join eventsWithDates e on e.eventName='Event 84 April 2025'
truncate table #bi
bulk insert #bi from 'C:\characterSheetReader\tickets\aug25.tsv' with(datafiletype='char')
insert into #allRawTickets (eventName,eventDate,fn,ln,ticketType,rawPlayerName)
	select eventName,eventDate,fn,ln,ticketType,rawPlayerName from #bi b
		join eventsWithDates e on e.eventName='Event 85 August 2025'
truncate table #bi
bulk insert #bi from 'C:\characterSheetReader\tickets\sep25.tsv' with(datafiletype='char')
insert into #allRawTickets (eventName,eventDate,fn,ln,ticketType,rawPlayerName)
	select eventName,eventDate,fn,ln,ticketType,rawPlayerName from #bi b
		join eventsWithDates e on e.eventName='Event 86 September 2025'
truncate table #bi
bulk insert #bi from 'C:\characterSheetReader\tickets\dec25.tsv' with(datafiletype='char')
insert into #allRawTickets (eventName,eventDate,fn,ln,ticketType,rawPlayerName)
	select eventName,eventDate,fn,ln,ticketType,rawPlayerName from #bi b
		join eventsWithDates e on e.eventName='Event 87 December 2025'


--select distinct rawPlayerName from #allRawTickets b where not exists (select null from rawCpData c where c.playerName=b.rawPlayerName)--216 that don't match sheets exactly
update a
	set a.matchedPlayerName=r.playerName
	from #allRawTickets a join rawCpData r on r.playerName=a.rawPlayerName
		where ticketType not like '%FAMILY%'
--select distinct rawPlayerName from #allRawTickets b where matchedPlayerName is null and ticketType not like '%FAMILY%'
--attempt to match via splitting the name
drop table if exists #namesFromSheets
;with cte as (select distinct ltrim(rtrim(playerName)) playerName from rawCPData)
	select playerName
		,case when playerName like '% %' then left(playerName,patindex('% %',playerName)-1) else playerName end fn
		,case when playerName like '% %' then substring(playerName,patindex('% %',playerName)+1,255) else '' end ln
		into #namesFromSheets
		from cte


update a
	set a.matchedPlayerName=n.playerName
	from #allRawTickets a join #namesFromSheets n on n.fn=a.fn and n.ln=a.ln
	where a.matchedPlayerName is null and ticketType not like '%FAMILY%'
--then loop down through to first initial
declare @len int=5
while @len>2
	begin
	update a
		set a.matchedPlayerName=n.playerName
		from #allRawTickets a join #namesFromSheets n on left(n.fn,@len)=left(a.fn,@len) and n.ln=a.ln
		where a.matchedPlayerName is null  and ticketType not like '%FAMILY%'
	set @len=@len-1
	end

--select distinct rawPlayerName from #allRawTickets b where matchedPlayerName is null and ticketType not like '%FAMILY%'--70

insert into tickets (eventName,eventDate,rawPlayerName,playerName,ticketType)
	select eventName,eventDate,rawPlayerName,isnull(matchedPlayerName,rawPlayerName),ticketType from #allRawTickets
		where ticketType<>'Ticket type'


select * from tickets where eventName='Event 87 December 2025'--526--looks good for dec25
	