use tm

--[1] load the existing master sheet 
	--[https://docs.google.com/spreadsheets/d/1njXWX81Tvc4YsSLDsVtHZkKV1wjcTMsPLe4IZMLkw-w/edit?gid=0#gid=0]


drop table if exists #master
create table #master (
	characterId char(5) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,tradition varchar(25) not null
	,practiceCount int not null
	,gameDetail varchar(4000) not null
	
)
alter table #master add primary key clustered(realName,characterName,tradition)
bulk insert #master from 'C:\characterSheetReader\magicalTraditions\masterSnapshot20260507.tsv' with(datafiletype='char',firstrow=4)

--make sure I see row 4
select top 100 * from #master where realName like 'Aaron Roth%'
--get count and smell
select count(*) from #master--44 smells right

--[2] load the practices (ALL) to determine adds to the master sheet 
	--use this [https://docs.google.com/spreadsheets/d/1VrPEhGWid-K_pD2tMcqOJnFN2PKk1nHdkBA2W0TrKA8/edit?gid=1679728161#gid=1679728161]
	--export as .tsv
	--edit in notepad and add a CRLF
	
drop table if exists #newPractices
create table #newPractices (
	[timestamp] datetime not null
	,email varchar(255) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,game varchar(255) not null
	,tradition varchar(255) not null
	,practiceWhen varchar(255) not null
	,oocRules varchar(4000) not null
	,participant01 varchar(1000) not null
	,participant02 varchar(1000) not null
	,participant03 varchar(1000) not null
	,participant04 varchar(1000) not null
	,participant05 varchar(1000) not null
	,participant06 varchar(1000) not null
	,participant07 varchar(1000) not null
	,participant08 varchar(1000) not null
	,participant09 varchar(1000) not null
	,participant10 varchar(1000) not null
	,participant11 varchar(1000) not null
	,participant12 varchar(1000) not null
	,participant13 varchar(1000) not null
	,participant14 varchar(1000) not null
	,participant15 varchar(1000) not null
	,participant16 varchar(1000) not null
	,participant17 varchar(1000) not null
	,participant18 varchar(1000) not null
	,participant19 varchar(1000) not null
	,participant20 varchar(1000) not null
	)
alter table #newPractices add primary key clustered(game,tradition,realName,practicewhen)
bulk insert #newPractices from 'C:\characterSheetReader\magicalTraditions\practicesSnapshot20260507.tsv' with(datafiletype='char',firstrow=4)--7

--delete any that are NOT for last game (April 2026)
--NEXT TIME, I need to do better, and get in the 3/27 practice
delete #newPractices where game<>'April 2026'
--smell test
#newPractices order by 1--4 count looks good

--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!

--[3]--note the max cutoff from #practicesToDate for future use
select * from #newPractices order by [timestamp] desc--2026-04-23 08:53:12.000

--[4]--delete previous practices, and practices that did not complete oocRules
select distinct oocRules from #newPractices--there's a practice not in compliance

select * from #newPractices where oocRules='Concentration (pg. 338), Parry, Dodge, Willpower and Resist (pg. 335)'--Ryan confirmed they didn't do the thing.
delete #newPractices where oocRules='Concentration (pg. 338), Parry, Dodge, Willpower and Resist (pg. 335)'--Ryan confirmed they didn't do the thing.




--[5]--explode #newPractices
drop table if exists #newPracticesExploded
;with cte as (
select game,tradition,participant01 as participant	from #newPractices
union select game,tradition,participant02 as participant	from #newPractices
union select game,tradition,participant03 as participant	from #newPractices
union select game,tradition,participant04 as participant	from #newPractices
union select game,tradition,participant05 as participant	from #newPractices
union select game,tradition,participant06 as participant	from #newPractices
union select game,tradition,participant07 as participant	from #newPractices
union select game,tradition,participant08 as participant	from #newPractices
union select game,tradition,participant09 as participant	from #newPractices
union select game,tradition,participant10 as participant	from #newPractices
union select game,tradition,participant11 as participant	from #newPractices
union select game,tradition,participant12 as participant	from #newPractices
union select game,tradition,participant13 as participant	from #newPractices
union select game,tradition,participant14 as participant	from #newPractices
union select game,tradition,participant15 as participant	from #newPractices
union select game,tradition,participant16 as participant	from #newPractices
union select game,tradition,participant17 as participant	from #newPractices
union select game,tradition,participant18 as participant	from #newPractices
union select game,tradition,participant19 as participant	from #newPractices
union select game,tradition,participant20 as participant	from #newPractices
)
,cte2 as (
	select * from cte where participant<>''
	)
select left(participant,5) characterId
	,substring(participant,6,255) nameInfoRaw
	,convert(varchar(255),null) characterName
	,convert(varchar(255),null) playerName
	,* 
	into #newPracticesExploded
	from cte2
	
update n
	set n.characterId=upper(n.characterId)
		,n.nameInfoRaw=ltrim(rtrim(n.nameInfoRaw))
		,n.characterName=r.characterName
		,n.playerName=r.playerName
	from #newPracticesExploded n
		left join rawCPData r on r.characterId=n.characterId

--fix script
select 'update #newPracticesExploded set characterId=''taco'' where nameInfoRaw='''+nameInfoRaw+''''  from #newPracticesExploded where characterName is null--4
update #newPracticesExploded set characterId='8VNNK',characterName='Cowardice Menagerie',playerName='John Tarbuskovich' where nameInfoRaw='Cowardice - John Tarbuskovich'
update #newPracticesExploded set characterId='8ZMXP',characterName='El',playerName='Ashley Jones'  where nameInfoRaw='El - Ashley Jones'



select * from postFeb26.rawCPData where characterId in ('8ZMXP','8VNNK')
select * from rawCPData where playerName='Ashley Jones'
update r
	set characterId='8ZMXP'
	from rawCPData r where characterName='El' and playerName='Ashley Jones'



update n
	set n.characterId=upper(n.characterId)
		,n.nameInfoRaw=ltrim(rtrim(n.nameInfoRaw))
		,n.characterName=r.characterName
		,n.playerName=r.playerName
	from #newPracticesExploded n
		left join postFeb26.rawCPData r on r.characterId=n.characterId
		where n.playerName is null
		 

--[5]--explode #master
drop table if exists #masterExploded
select m.*
	,ltrim(rtrim(x.[value])) as game
	into #masterExploded
	from #master m
		cross apply string_split(m.gameDetail,',') x
create unique clustered index x on #masterExploded(game,tradition,characterId)

--[6]--combine #newPracticesExploded and #masterExploded
drop table if exists #revisedMasterExploded
select characterId,game,tradition 
	into #revisedMasterExploded
	from #newPracticesExploded
union select characterId,game,tradition from #masterExploded
create unique clustered index x on #revisedMasterExploded(game,tradition,characterId)

--[7]--rollup into #newMaster
drop table if exists #newMaster
select r.characterId	
	,min(c.playerName) realName
	,min(c.characterName) characterName
	,r.tradition
	,count(*) practiceCount
	,string_agg(game,', ') gameDetail
	into #newMaster
	from #revisedMasterExploded r
		left join rawCpData c on c.characterId=r.characterId
	group by r.characterId,r.tradition
	order by 2,4

--[8]--dump this into the master (after backing up the master)
select * from #newMaster order by realName,characterName
--#revisedMasterExploded

