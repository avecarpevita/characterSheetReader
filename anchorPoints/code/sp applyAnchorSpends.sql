use tm
go
create or alter procedure applyAnchorSpends (@file varchar(255), @eventName varchar(255))
as 
/*


exec applyAnchorSpends @file='c:\anchorpoints\spendsDec25.tsv', @eventName='Event 87 December 2025'
exec applyAnchorSpends @file='c:\anchorpoints\spendsJan26.tsv', @eventName='Event 88 January 2026'

anchorChangeLog where eventType='S'

*/
begin
set nocount on

--declare @file varchar(255)='c:\anchorpoints\spendsJan26.tsv'
declare @sql varchar(max)
drop table if exists #spendsRaw
create table #spendsRaw (
	playerName varchar(255) not null primary key clustered
	,spendEvents varchar(255)
	,notes varchar(255)
	)
set @sql='bulk insert #spendsRaw from '''+@file+''' with(datafiletype=''char'')'
print @sql; exec(@sql)
--select * from  #spendsRaw where playername like '%chris%'
--select * from  #spendsRaw where spendEvents is not null or notes is not null
/*
select * from anchorChangeLog where playerName='Eleanor Wexler'
update a
	set notes=null
	from anchorChangeLog a where playerName='Morgan Smith' and id=592

select * from anchorChangeLog where playerName='Kandoryn'

update a
	set playerName='Jerrod Hayes'
	from anchorChangeLog a where playerName='Kandoryn' 

update a
	set playerName='Lily Thiemens'
	from anchorChangeLog a where playerName='lily thiemens' 

*/


drop table if exists #spends
;with cte as (select r.*,ltrim(rtrim(x.[value])) as spendEvent
		from #spendsRaw r
			cross apply STRING_SPLIT(spendEvents, ',') x
			where nullif(spendEvents,'') is not null and spendEvents<>'spendEvents'
		)
select *
	,l.loreDescription as spendReason
	into #spends
	from cte s
		left join loreAbbrev l on l.loreAbbrev=s.spendEvent
	
	/*
select * from #spends where loreAbbrev is null
insert into loreAbbrev select 'lith','Lithoturgy'
insert into loreAbbrev select 'hydro','Hydrology'
insert into loreAbbrev select 'lucen','Lucenturgy'
*/

--insert only new information
--select * from #signups
--select * from anchorChangeLog
delete anchorChangeLog where sourcefile=@file
insert into anchorChangeLog (playerName,timestamp,eventType,eventName,spendReason,pointChange,sourcefile)
	select playerName,getdate(),'S' eventType, @eventName eventName, spendReason, -1,@file 
		from #spends s
		




return 0

error:
raiserror('error',16,16)
return 1

end