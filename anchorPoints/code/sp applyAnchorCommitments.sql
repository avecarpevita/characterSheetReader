use tm
go
create or alter procedure applyAnchorCommitments (@file varchar(255), @eventName varchar(255), @doublePointSlots varchar(30)=null, @triplePointSlots varchar(30)=null)
as 
/*
ingests a .tsv file, straight from the anchor signups
applies that to tbl anchorChangeLog

--truncate table anchorChangeLog
exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsDec25.tsv', @eventName='Event 87 December 2025',@doublePointSlots='SatAM'

select * into anchorChangeLog_bak20260106 from anchorChangeLog

exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsJan26.tsv', @eventName='Event 88 January 2026',@doublePointSlots='SatAF|SatPM'

exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsApr26.tsv', @eventName='Event 90 April 2026',@doublePointSlots=null, @triplePointSlots=''

delete anchorChangeLog where sourcefile='c:\characterSheetReader\anchorpoints\data\signupsJan26.tsv'
select * from anchorChangeLog--77
select * from anchorChangeLog where playerName like '%justen%'
select * from anchorChangeLog where playerName like '%maus%'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange)
	select 'Sophia Boyd','shboyd20@gmail.com','11/11/2025 9:34:25','c','Mar25','SatAM',1
11/11/2025 9:34:25	shboyd20@gmail.com	Sophia Boyd	playing The Kid in March 2025	Yes	Yes	School of Suffering	I like combat, but I'm not a strong fighter and/or I don't know the rules that well.

exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsFeb26.tsv', @eventName='Event 89 February 2026',@doublePointSlots='',@triplePointSlots='|SatPMCarnival'

*/
begin
set nocount on

--declare @file varchar(255)='c:\characterSheetReader\anchorpoints\data\signupsApr26.tsv'
declare @sql varchar(max)
drop table if exists #signupsRaw
create table #signupsRaw (
	timestamp varchar(255)
	,email nvarchar(255)
	,playerName nvarchar(255)
	,timeSlots varchar(1000)
	,check1 varchar(100)
	,check2 varchar(100)
	,plan1 varchar(255)
	,combat1 varchar(255)
	)
if @file not in ('c:\characterSheetReader\anchorpoints\data\signupsJan26.tsv','c:\characterSheetReader\anchorpoints\data\signupsDec25.tsv')
	begin
	
	alter table #signupsRaw drop column timeslots
	alter table #signupsRaw drop column check1
	alter table #signupsRaw drop column check2
	alter table #signupsRaw drop column plan1
	alter table #signupsRaw drop column combat1
	alter table #signupsRaw add characterId nvarchar(100)
	alter table #signupsRaw add timeslots nvarchar(1000)
	end


set @sql='bulk insert #signupsRaw from '''+@file+''' with(datafiletype=''char'',firstrow=2) '
print @sql; exec(@sql)
--select * from  #signupsRaw where playername like '%mari%'
--select * from  #signupsRaw where playername like '%soph%'

--declare @doublePointSlots varchar(255)=null
drop table if exists #doublePointSlots
select x.value as timeSlot
	into #doublePointSlots
	from STRING_SPLIT(@doublePointSlots, '|') x
	where len(x.value)>1

--declare @triplePointSlots  varchar(255)='FriPM3'
drop table if exists #triplePointSlots
select x.value as timeSlot
	into #triplePointSlots
	from STRING_SPLIT(@triplePointSlots, '|') x
	where len(x.value)>1


drop table if exists #signups--#signups where playerName like '%maus%'
;with cte as (select try_cast(timestamp as datetime) timestamp 
	,email,playerName
	,characterId
	,timeSlots
	,case when timeSlots like '%Friday Night%triple%' then '|FriPM3' else '' end
	+case when timeSlots like '%Friday Night%game on%Thom%' then '|FriPMa' else '' end
	+case when timeSlots like '%Friday Night%11%' then '|FriPMb' else '' end
	+case when timeSlots like '%Saturday%Carnival%' then '|SatPMCarnival' else '' end
	+case when timeSlots like '%Saturday Night%' and timeslots not like '%carnival%' then '|SatPM' else '' end
	--+case when timeSlots like '%Friday Night%' then '|FriPM' else '' end
	+case when timeSlots like '%Saturday Morning%' then '|SatAM' else '' end 
	+case when timeSlots like '%Saturday Afternoon%' then '|SatAF' else '' end 
	+case when timeSlots like '%Manual%' or timeSlots like '%Special%' or timeSlots like '%kid%' then '|Manual' else '' end timeSlotsPiped
	from #signupsRaw r 
		where try_cast(timestamp as datetime) is not null 
		)
		select c.* 
			,x.value as timeSlot
			,case when t.timeSlot is not null then 3
				when d.timeSlot is not null then 2 
				else 1 end pointChange
			,left(x.value,6) timeslot6
			into #signups
			from cte c
			cross apply STRING_SPLIT(timeSlotsPiped, '|') x
			left join #doublePointSlots d on d.timeSlot=x.value
			left join #triplePointSlots t on t.timeSlot=x.value
			where len(x.value)>0
--select playerName from #signups group by playername having count(*)>1
--select * from #signups where playerName in (select playerName from #signups group by playername having count(*)>1) order by playerName
create unique clustered index c on #signups(playerName,timeslot6)
--#signups where playerName like '%Adriana Griot%'

--build #names from existing data
drop table if exists #names
;with cte as (select * 
	,row_number() over(partition by playerName order by [timeStamp] desc) rn
	from anchorChangeLog where eventType='C')
select distinct email,playerName into #names
	from cte where rn=1
;with cte as (select *,row_number() over(partition by email order by playername) rn from #names) delete cte where rn>1
create unique clustered index e on #names(email);	if @@ERROR<>0 goto error -- must be unique to names--#names where playerName='awarenyx@gmail.com'
create unique index p on #names(playerName); if @@ERROR<>0 goto error -- must be unique to names

--select * from #names order by 1

update s
	set s.playerName=n.playerName
	from #signups s join #names n on n.email=s.email
	--joshuawarner333@gmail.com	Joshua Warner	8RYYE -- should not have signed up, but I'm gonna kick him out for lack of a full pre-reg ticket
--select * from #signups s where not exists (select null from rawCpData r where r.characterId=s.characterId)

if exists (select null from #signups s where not exists (select null from rawCpData r where r.characterId=s.characterId))
	begin
	raiserror('CHARACTER ID EXISTS THAT IS NOT IN SHEETS YET',16,16)
	goto error
	end

--stomp on the playerName with what is in the character database
update s
	set s.playerName=r.playerName
	from #signups s join rawCpData r on r.characterId=s.characterId


--insert only new information
--select * from #signups
--select * from anchorChangeLog
--alter table anchorChangelog alter column characterId char(5) not null
--alter table anchorChangeLog alter column timeSlot varchar(20)

delete anchorChangeLog where sourcefile=@file
insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId)
	select playerName,email,timestamp,'C' eventType, @eventName eventName, timeSlot, pointChange,@file,characterId
		from #signups s
		where not exists (select null from anchorChangeLog a where a.timeStamp=s.timestamp and a.playerName=s.playerName)

		--#signups order by len(timeSlot) desc

return 0

error:
raiserror('error',16,16)
return 1

end