use tm
go
create or alter procedure applyNotes (@file varchar(255), @eventName varchar(255))
as 
/*


exec applyNotes @file='c:\anchorpoints\notesDec25.tsv', @eventName='Event 87 December 2025'

anchorChangeLog where eventType='N'

*/
begin
set nocount on

--declare @file varchar(255)='c:\anchorpoints\notesDec25.tsv'
declare @sql varchar(max)
drop table if exists #notesRaw
create table #notesRaw (
	playerName varchar(255) not null primary key clustered
	,notes varchar(255)
	)
set @sql='bulk insert #notesRaw from '''+@file+''' with(datafiletype=''char'')'
print @sql; exec(@sql)
--select * from  #notesRaw where playername like '%chris%'
--select * from  #notesRaw where playername like '%soph%'




--insert only new information
--select * from #signups
--select * from anchorChangeLog
delete anchorChangeLog where sourcefile=@file
insert into anchorChangeLog (playerName,timestamp,eventType,eventName,pointchange, notes,sourcefile)
	select playerName,getdate(),'N' eventType, @eventName, 0 pointchange, notes,@file 
		from #notesRaw s
		where len(notes)>0 and playerName<>'playerName'
		




return 0

error:
raiserror('error',16,16)
return 1

end