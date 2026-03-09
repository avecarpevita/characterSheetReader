use tm

drop table if exists #masterOld
create table #masterOld (
	realName varchar(255) not null
	,characterName varchar(255) not null
	,style varchar(25) not null
	,practiceCount int not null
	,gameDetail varchar(4000) not null
	,rankEarned varchar(255) null
)
alter table #masterOld add primary key clustered(realName,characterName,style)
bulk insert #masterOld from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260219.tsv' with(datafiletype='char',firstrow=4)--this is the backup if I need it

drop table if exists #master
select *,convert(char(5),null) characterId into #master from #masterOld
alter table #master add primary key clustered(realName,characterName,style)

drop table if exists #realNameMatches
drop table if exists #realNameMatchesWork
;with cte as (
select distinct p.realName,p.characterName
	,dbo.clr_LevenshteinDistance(left(p.realName,13),left(a.playerName,13)) realNameDistance
	,dbo.clr_LevenshteinDistance(left(p.characterName,13),left(a.characterName,13)) characterNameDistance
	,a.playerName playerNameFromSheets
	,a.characterId
	from #master p join rawCPData a on 1=1		
	)
,cte2 as (select *
	,square(characterNameDistance)+square(realNameDistance) totalDistance 
	from cte)
,cte3 as (select *,row_number() over(partition by realName 
	order by realNameDistance asc,totalDistance asc) rn from cte2)
select * into #realNameMatchesWork from cte3--646932
select * into #realNameMatches from #realNameMatchesWork where rn=1--137
create unique clustered index pp on #realNameMatches(realName)

--[9b]--inspect the worst matches to build pre-treats and then run again
select realName,playerNameFromSheets,realNameDistance,totalDistance from #realNameMatches order by realNameDistance desc--SNAP, it is already good, except on 1

update m	
	set m.realName=r.playerNameFromSheets
	from #master m join #realNameMatches r on r.realName=m.realName
	where m.realName<>r.playerNameFromSheets--1

--[9d]--use that to get characters/ids
update #master set realName='Nicholas Prouty',characterName='Shadrek Dario'
	where characterName='Shadrek Dario'
update #master set characterName='Salomon “Slip” Jasset' where realName='Gil Ramirez' and characterNAme like 'Salom%'
update #master set characterName='Sóls''tur',gameDetail='December 2025,August 2025' where realName='Corin Edwards' and characterNAme like 'Sóls''tur'
delete #master where realName='Corin Edwards'  and characterName='S+¦ls''tur'
drop table if exists #charNameMatches
drop table if exists #charNameMatchesWork
;with cte as (select p.realName,p.characterName
	,dbo.clr_LevenshteinDistance(left(p.characterName,13),left(a.characterName,13)) characterNameDistance
	,a.characterName characterNameFromSheets
	,a.characterId
	from #master p join rawCPData a on a.playerName=p.realName)
	,cte2 as (select *
		,row_number() over(partition by realName,characterName order by characterNameDistance) rn
		from cte)
select * into #charNameMatchesWork from cte2
select * into #charNameMatches from #charNameMatchesWork where rn=1

--[9e]--inspect for problems
select * from #charNameMatches order by characterNameDistance desc--good to go

update m
	set m.characterId=c.characterId
		,m.characterName=c.characterNameFromSheets
	from #master m join #charNameMatches c on c.realName=m.realName and c.characterName=m.characterName
	--156

select * from #master where characterId is null--0

--explode master
drop table if exists #explodedMaster
select characterId,realName,characterName,style
	,ltrim(rtrim(x.value)) as [game]
	into #explodedMaster
	from #master m cross apply string_split(gameDetail,',') x
create unique clustered index x on #explodedMaster(characterId,style,game)

--merge in Jan26
;with cte as (	select distinct characterIdMatched,participantRealNameMatched,participantCharacterNameMatched,style,game
		from practicesToDateDetail_bak_20260210)--select characterIdMatched,realName,characterName,style,game from practicesToDateDetail_bak_20260210 where characterIdMatched='7VJX4'
insert into #explodedMaster
	select * from cte
	--165
--collapse back down
drop table if exists #newMaster
select characterId,realName,characterName,style
	,count(*) [practice Count]
	,string_agg(game,', ') as gameDetail
	into #newMaster
	from #explodedMaster
	group by characterId,realName,characterName,style
create unique clustered index c on #newMaster(characterId,style)--done

select * from #newMaster order by 2,3

--now vet for 6Dragons
select * from #newMaster where style='Six Dragons' order by [practice Count] desc

#newMaster where realName like '%jerrod%'

select * from #newMaster where style='Six Dragons' and [practice count]>=3
pre-reqs are
			R. Lore - Six Dragons
			Two-Weapon Fighting
			Oversized Weapon Use or Weapon Master





drop table if exists #missing_pre_req
select * 
	into #missing_pre_req
	from #newMaster n where style='Six Dragons' and [practice count]>=3  --select * from rawSkills where playerName='Jerrod Hayes' and characterName='Kandórŷn Pellintië'
	and not exists (select null from rawSkills s 
		join rawCPData c on c.playerName=s.playerName and c.characterName=s.characterName
		and c.characterId=n.characterId 
		and (rawSkill like '%six dragons%' or rawSkill like '%6 Dragons%'))--3 confirmed from sheets
union
select * from #newMaster n where style='Six Dragons' and [practice count]>=3
	and not exists (select null from rawSkills s 
		join rawCPData c on c.playerName=s.playerName and c.characterName=s.characterName
		and c.characterId=n.characterId 
		and (rawSkill like '%two%weapon%' ))--2 confirmed from sheets
union
select * from #newMaster n where style='Six Dragons' and [practice count]>=3
		and not exists (select null from rawSkills s 
		join rawCPData c on c.playerName=s.playerName and c.characterName=s.characterName
		and c.characterId=n.characterId 
		and (rawSkill like '%Oversized%' or rawSkill like '%weapon%master%'))--2 confirmed from sheets

delete #missing_pre_req where characterId='84DVJ'

select characterId 
	,convert(varchar(35),characterName) characterName
	,convert(varchar(35),realName) realName
	,(select top 1 email from rawCpData r where r.characterId=n.characterId)
	from  #newMaster n where style='Six Dragons' and [practice count]>=3
	and not exists (select null from #missing_pre_req m where m.characterId=n.characterId)
	order by 3,2


Nicholas Prouty -- curly haired guy, dating the belly dancer
Brady Heaton	-- kinda looks like Dakota Bloom, beefier
Albert Blattler	-- kinda Garrett looking from the 1 photo I have


--2026.02.26
--Jerrod Hayes is asking the day before game
select * from 

select top 100 * from rawCpData where playerName like '%Justin Chan%'