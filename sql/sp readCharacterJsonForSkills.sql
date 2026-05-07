use tm
go
create or alter proc readCharacterJsonForSkills(@characterJsonPath nvarchar(max), @show bit=0)
as
/*

--2026.05.07--added characterId to rawSkills

select * from rawSkills with(nolock)
truncate table rawSkills
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

exec readCharacterJsonForSkills @characterJsonPath='C:\characterSheets20250916\json\Fei Leung (Anziel).json', @show=1
exec readCharacterJsonForSkills @characterJsonPath='c:/characterSheets20250916/json/Kelsey Daily (Odette) (Advocate).json', @show=1
exec readCharacterJsonForSkills @characterJsonPath='C:\characterSheets20260507\json\Olivia Lizardo (Odile) [STAFF].json', @show=1

exec readCharacterJsonForSkills @characterJsonPath='c:/characterSheets20260507/json/Or Taylor (Vox MaCairn) - Pregen Conversion.json', @show=1


select * from rawSkills where playerName like 'Or T%'
*/
begin
set nocount on

--declare @characterJsonPath nvarchar(max)='C:\characterSheets20260507\json\Oak Lane (DeLunaria).json', @show bit=1
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
	,characterId nvarchar(100)
	,[events] nvarchar(max) '$.events' as JSON
	,[skills] nvarchar(max) '$.skills' as JSON
) AS characterSheet;

declare @skills nvarchar(max)=(select skills from #characterSheet)
declare @playerName nvarchar(100), @characterName nvarchar(100), @characterid nvarchar(100)
select @playerName=playerName,@characterName=characterName,@characterid=characterId from #characterSheet
--select @skills

drop table if exists #skills
;with cte as (
select skills.*
	from OPENJSON(@skills)
with (
	rawSkillName nvarchar(100)
	,rawCPCost nvarchar(100)
	) as skills
)
select * into #skills from cte 

if nullif(@characterId,'') is null 
	select @characterId=dbo.tempCharacterId(@playerName,@characterName)

	--rawSkills where rawSkill like 'Disarm%'

insert into rawSkills (rawSkill,characterName,playerName,rawCpSpent,characterId)
	select rawSkillName,@characterName,@playerName,max(rawCpCost),isnull(@characterId,'')
		from #skills l 
		where not exists (select null from rawSkills r where r.rawSkill=l.rawSkillName
			and r.characterId=@characterId)
			and not exists (select null from rawSkills r where r.rawSkill=l.rawSkillName
			and r.playerName=@playerName
			and r.characterName=@characterName
			)
			and isnull(rawSkillName,'')<>''
			and isnull(@characterName,'')<>'' and isnull(@playerName,'')<>''
			group by rawSkillName

if @show=1 select * from rawSkills


end