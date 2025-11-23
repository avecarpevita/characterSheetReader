use tm
go
create or alter proc readCharacterJsonForLores(@characterJsonPath nvarchar(max), @show bit=0)
as
/*
select * from rawLores with(nolock)
truncate table rawLores
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

exec readCharacterJsonForLores @characterJsonPath='C:\characterSheets20250916\json\Fei Leung (Anziel).json', @show=1
exec readCharacterJsonForLores @characterJsonPath='c:/characterSheets20250916/json/Kelsey Daily (Odette) (Advocate).json', @show=1


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
	,[events] nvarchar(max) '$.events' as JSON
	,[skills] nvarchar(max) '$.skills' as JSON
) AS characterSheet;

declare @skills nvarchar(max)=(select skills from #characterSheet)
declare @playerName nvarchar(100), @characterName nvarchar(100)
select @playerName=playerName,@characterName=characterName from #characterSheet
--select @skills

drop table if exists #lores
;with cte as (
select skills.*
	from OPENJSON(@skills)
with (
	rawSkillName nvarchar(100)
	,rawCPCost nvarchar(100)
	) as skills
)
select * into #lores from cte where rawSkillName like '%lore%'

insert into rawLores (rawLore,characterName,playerName)
	select distinct rawSkillName,@characterName,@playerName from #lores l 
		where not exists (select null from rawLores r where r.rawLore=l.rawSkillName
			and r.characterName=@characterName
			and r.playerName=@playerName
			)


if @show=1 select * from rawLores


end