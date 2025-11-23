use tm
go
create or alter proc readCharacterJsonForCpData(@characterJsonPath nvarchar(max), @show bit=0)
as
/*
select * from rawLores with(nolock)
truncate table rawLores
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

exec readCharacterJsonForCpData @characterJsonPath='C:\characterSheets20250916\json\Fei Leung (Anziel).json', @show=1
exec readCharacterJsonForCpData @characterJsonPath='c:/characterSheets20250916/json/Kelsey Daily (Odette) (Advocate).json', @show=1


*/
begin
set nocount on

declare @characterJson nvarchar(max)
drop table if exists #characterJson
create table #characterJson (bulkColumn nvarchar(max))
declare @sql nvarchar(max)
set @sql=N'insert into #characterJson SELECT BulkColumn
    FROM OPENROWSET(BULK '''+@characterJsonPath+''', SINGLE_CLOB) as j;'
if @show=1 print @sql
exec(@sql)
--select * from #characterJson
select @characterJson = bulkColumn from #characterJson

drop table if exists #characterSheet
SELECT characterSheet.*
into #characterSheet
FROM OPENJSON(@characterJson)
WITH (
    playerName NVARCHAR(100)
    ,characterName NVARCHAR(100)
	,corruption nvarchar(100)
	,characterPoints nvarchar(max) '$.characterPoints' as JSON
	,[events] nvarchar(max) '$.events' as JSON
	,[skills] nvarchar(max) '$.skills' as JSON
) AS characterSheet;

declare @characterPoints nvarchar(max)=(select [characterPoints] from #characterSheet)
drop table if exists #characterPoints
select spentCP
	into #characterPoints
		from OPENJSON(@characterPoints)
		with (spentCP nvarchar(100))
		
declare @playerName nvarchar(100), @characterName nvarchar(100), @corruption int, @spentCP int

select @playerName=playerName,@characterName=characterName,@corruption=corruption 	from #characterSheet c
select @spentCP=spentCP from #characterPoints
if @show=1 select * from #characterSheet
if @show=1 select * from #characterPoints


declare @events nvarchar(max)=(select [events] from #characterSheet)
drop table if exists #events
;with cte as (
select [events].*
	from OPENJSON(@events)
with (
	eventName nvarchar(100)
	,eventDate nvarchar(100)
	) as [events]
)
select * into #events from cte 

if @show=1 select * from #events

--merge into tbls rawEvents and rawCPData

insert into rawCpData (characterName,playerName,spentCp,corruption)
	select @characterName,@playerName,@spentCP,isnull(@corruption,0)
		where not exists (select null from rawCPData r where r.characterName=@characterName and r.playerName=@playerName)
		and @characterName is not null and @playerName is not null

insert into rawEvents (characterName,playerName,eventName,eventDate)
	select @characterName,@playerName,eventName,max(eventDate)
		from #events e
			where not exists (select null from rawEvents r where r.characterName=@characterName and r.playerName=@playerName
				and r.eventName=e.eventName
				)
			and @characterName is not null and @playerName is not null
				group by eventName

if @show=1 select * from rawCpData
if @show=1 select * from rawEvents

end