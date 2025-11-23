use tm
go
create or alter proc readCharacterJsonForLores(@characterJson nvarchar(max), @characterName, @show bit=0)
as
/*
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

exec readCharacterJsonForLores @characterJson=@json, @show=1
*/
begin
set nocount on

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

insert into rawLores (rawLore)
	select distinct rawSkillName from #lores l where not exists (select null from rawLores r where r.rawLore=l.rawSkillName)


if @show=1 select * from rawLores

end