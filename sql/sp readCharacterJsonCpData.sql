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
exec readCharacterJsonForCpData @characterJsonPath='C:\characterSheets20260507\json\Oak Lane (DeLunaria).json', @show=1


exec readCharacterJsonForCpData @characterJsonPath='c:/characterSheets20260507/json/Or Taylor (Vox MaCairn) - Pregen Conversion.json', @show=1

exec readCharacterJsonForCpData @characterJsonPath='C:\characterSheets20260507\json\Olivia Lizardo (Odile) [STAFF].json', @show=1



select * from rawCPDAta order by playerName
select * from rawEvents

select * from rawEvents

--2026.01.21--added characterId, email, culture, religion, bloodline(race), hp, mana, ip
--2026.05.07--added characterId to rawEvents

*/
begin
set nocount on

--declare @characterJsonPath nvarchar(max)='C:\characterSheets20260507\json\Olivia Lizardo (Odile) [STAFF].json', @show bit=1
declare @characterJson nvarchar(max)
drop table if exists #characterJson
create table #characterJson (bulkColumn nvarchar(max))
declare @sql nvarchar(max)
set @sql=N'insert into #characterJson SELECT BulkColumn
    FROM OPENROWSET(BULK '''+@characterJsonPath+''', SINGLE_CLOB) as j;'
if @show=1 print @sql
exec(@sql)


--select * from #characterJson
--declare @characterJson nvarchar(max)
select @characterJson = bulkColumn from #characterJson

drop table if exists #characterSheet
SELECT characterSheet.*
into #characterSheet
FROM OPENJSON(@characterJson)
WITH (
    playerName NVARCHAR(100)
    ,characterName NVARCHAR(100)
	,corruption nvarchar(100)
	--2026.01.21--added characterId, email, culture, religion, bloodline(race), hp, mana, ip
	,characterId nvarchar(100)
	,email nvarchar(100)
	,bloodline nvarchar(100)
	,culture nvarchar(100)
	,religion nvarchar(100)
	,health nvarchar(100)
	,mana nvarchar(100)
	,[ip] nvarchar(100)
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
--added characterId, email, culture, religion, bloodline(race), hp, mana, ip
declare @characterId varchar(100), @email nvarchar(100), @culture nvarchar(100), @religion nvarchar(100), @bloodline nvarchar(100), @hp int, @mana int, @ip int

select @playerName=playerName,@characterName=characterName,@corruption=corruption 	
	,@characterId=characterId,@email=email,@culture=culture, @religion=religion, @bloodline=bloodline, @hp=health, @mana=mana, @ip=ip
	from #characterSheet c
select @spentCP=spentCP from #characterPoints

if nullif(@characterId,'') is null 
	select @characterId=dbo.tempCharacterId(@playerName,@characterName)

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

insert into rawCpData (characterName,playerName,spentCp,corruption
	,characterId,email,culture,religion,bloodline,hp,mana,[ip])
	select @characterName,@playerName,@spentCP,isnull(@corruption,0)
		--added characterId, email, culture, religion, bloodline(race), hp, mana, ip
		,isnull(@characterId,''),isnull(@email,''),isnull(@culture,''),isnull(@religion,''),isnull(@bloodline,'')
		,isnull(@hp,0),isnull(@mana,0),isnull(@ip,0)
		where not exists (select null from rawCPData r where r.characterId=@characterId)
		and not exists (select null from rawCPData r where r.playerName=@playerName and r.characterName=@characterName)
		and isnull(@characterName,'')<>'' and isnull(@playerName,'')<>''

insert into rawEvents (characterName,playerName,eventName,eventDate,characterId)
	select @characterName,@playerName,eventName,max(eventDate),isnull(@characterId,'')
		from #events e
			where not exists (select null from rawEvents r where r.characterId=@characterId
				and r.eventName=e.eventName
				)
				and not exists (select null from rawEvents r where r.playerName=@playerName and r.characterName=@characterName
				and r.eventName=e.eventName
				)
				and isnull(@characterName,'')<>'' and isnull(@playerName,'')<>''
				group by eventName

if @show=1 select * from rawCpData
if @show=1 select * from rawEvents

end