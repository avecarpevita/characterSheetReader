use tm

--[1] load the existing master sheet 
	--[https://docs.google.com/spreadsheets/d/1k7nJRc1OglY8B7dkddJlQeOo4hPL7Dq1Cp-ItnEREWI/edit?gid=0#gid=0]
	--YOU MUST CHOP OFF THE 3 HEADER LINES!!!!

drop table if exists #master
create table #master (
	characterId char(5) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,style varchar(25) not null
	,practiceCount int not null
	,gameDetail varchar(4000) not null
	
)
alter table #master add primary key clustered(realName,characterName,style)
bulk insert #master from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260326.tsv' with(datafiletype='char',firstrow=1)

--make sure I see row 4
select top 100 * from #master where realName like 'adam camp%'
--get count and smell
select count(*) from #master--smells right

--[2] load the practices (Feb26 only) to determine adds to the master sheet
	--[https://docs.google.com/spreadsheets/d/1FxgqIz7hJurOsCmJZxlErhGXhJyjURI_vAPQmOTZikM/edit?gid=1242376946#gid=1242376946]
	--export as .tsv
	--edit in notepad and add a CRLF
	
drop table if exists #newPractices
create table #newPractices (
	[timestamp] datetime not null
	,email varchar(255) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,game varchar(255) not null
	,style varchar(255) not null
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
alter table #newPractices add primary key clustered(game,style,realName,practicewhen)
bulk insert #newPractices from 'C:\characterSheetReader\fightingStyles\practicesSnapshot20260326.tsv' with(datafiletype='char',firstrow=2)--9
--smell test
#newPractices--10 count looks good

--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!

--[3]--note the max cutoff from #practicesToDate for future use
select * from #newPractices order by [timestamp] desc--2026-03-24 20:01:08.000

--[4]--delete previous practices, and practices that did not complete oocRules
select distinct oocRules from #newPractices--everybody is gucci


--[5]--explode #newPractices
drop table if exists #newPracticesExploded
;with cte as (
select game,style,participant01 as participant	from #newPractices
union select game,style,participant02 as participant	from #newPractices
union select game,style,participant03 as participant	from #newPractices
union select game,style,participant04 as participant	from #newPractices
union select game,style,participant05 as participant	from #newPractices
union select game,style,participant06 as participant	from #newPractices
union select game,style,participant07 as participant	from #newPractices
union select game,style,participant08 as participant	from #newPractices
union select game,style,participant09 as participant	from #newPractices
union select game,style,participant10 as participant	from #newPractices
union select game,style,participant11 as participant	from #newPractices
union select game,style,participant12 as participant	from #newPractices
union select game,style,participant13 as participant	from #newPractices
union select game,style,participant14 as participant	from #newPractices
union select game,style,participant15 as participant	from #newPractices
union select game,style,participant16 as participant	from #newPractices
union select game,style,participant17 as participant	from #newPractices
union select game,style,participant18 as participant	from #newPractices
union select game,style,participant19 as participant	from #newPractices
union select game,style,participant20 as participant	from #newPractices
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
update #newPracticesExploded set characterId='8VGDD' where nameInfoRaw='Desmond Jollicouer- Samuel Lock'
update #newPracticesExploded set characterId='7AQDN' where nameInfoRaw='Strikarn Orson - Brian Williams'
update #newPracticesExploded set characterId='859ND' where nameInfoRaw='Luminintous - Devin McCarthy'
update #newPracticesExploded set characterId='8GGRM' where nameInfoRaw='Nalain Calae - Rose Kochanek'

--[5]--explode #master
drop table if exists #masterExploded
select m.*
	,ltrim(rtrim(x.[value])) as game
	into #masterExploded
	from #master m
		cross apply string_split(m.gameDetail,',') x
create unique clustered index x on #masterExploded(game,style,characterId)

--[6]--combine #newPracticesExploded and #masterExploded
drop table if exists #revisedMasterExploded
select characterId,game,style 
	into #revisedMasterExploded
	from #newPracticesExploded
union select characterId,game,style from #masterExploded
create unique clustered index x on #revisedMasterExploded(game,style,characterId)

--[7]--rollup into #newMaster
drop table if exists #newMaster
select r.characterId	
	,min(c.playerName) realName
	,min(c.characterName) characterName
	,r.style
	,count(*) practiceCount
	,string_agg(game,', ') gameDetail
	into #newMaster
	from #revisedMasterExploded r
		left join rawCpData c on c.characterId=r.characterId
	group by r.characterId,r.style
	order by 2,4

--check for tests and prereqs
--SOS first

--select * from #newMaster where realName like 'oliv%'
update #newMaster set practiceCount=3, gameDetail='January 2026, December 2025, February 2026' where characterId='7DJ4V'

select * from #newMaster where practiceCount>=3 and style like '%suff%' order by 2--8
R. Lore - School of Suffering
			Armored Forearms
			Armored Shins

select * from #newMaster n where practiceCount>=3 and style like '%suff%' 
	and not exists (select null from rawSkills s where s.characterId=n.characterId and s.rawSkill like '%suff%')--0
select * from #newMaster n where practiceCount>=3 and style like '%suff%' 
	and not exists (select null from rawSkills s where s.characterId=n.characterId and s.rawSkill like '%Forearm%')--0
select * from #newMaster n where practiceCount>=3 and style like '%suff%' 
	and not exists (select null from rawSkills s where s.characterId=n.characterId and s.rawSkill like '%Shin%')--0

select * from #newMaster n join rawSkills s on s.characterId=n.characterId 
	where practiceCount>=3 and style like '%suff%' 
		and (s.rawskill like '%suff%'
		or s.rawskill like '%Forearm%'
		or s.rawskill like '%Shin%')
	order by n.characterId,rawSkill

--final list
select distinct n.characterId
	,convert(varchar(35),n.realName) realName
	,convert(varchar(35),n.characterName) characterName
	,(select string_agg(game,', ') from #revisedMasterExploded re where re.characterId=n.characterId and re.style=n.style)
	from #newMaster n join rawSkills s on s.characterId=n.characterId 
	where practiceCount>=3 and style like '%suff%' 
		and (s.rawskill like '%suff%'
		or s.rawskill like '%Forearm%'
		or s.rawskill like '%Shin%')
	order by 1


select * from #newMaster where practiceCount>=3 and style like '%swan%' order by 2--16
R. Lore - Swanwall
			Armored Training: Light
			Oversized Weapon Use
			Armorsmithing: Apprentice or Tailoring: Apprentice
			Fortify Armor
			Field Repair x1

select distinct n.characterId
	,convert(varchar(35),n.realName) realName
	,convert(varchar(35),n.characterName) characterName
	,rawskill
	from #newMaster n join rawSkills s on s.characterId=n.characterId 
	where practiceCount>=3 and style like '%swan%' 
		and (s.rawskill like '%Swan%w%'
		or s.rawskill like '%Armor%Train%'
		or s.rawskill like '%oversiz%' or s.rawskill like '%weapon%master%'
		or s.rawskill like '%armorsmith%' or s.rawskill like '%tailor%'
		or s.rawskill like '%Fortify%' or s.rawskill like '%Field Repair%'
		)
	order by 1,4

	/*
79DBG	Trevor West	Brollen Whitstone		--missing oversized
8JGRZ	Jake Steinmetz	Darow				--missing field repair tree

8E4XE	Nicholas Marko	The Persevering Hope -- missing the lore, but it is there now
8M4WB	Andrew Cunado	Keeper of Hearth's Embers--also got the lore last minute
8PPQX	Nick Cronin	Kitter, The Withering Thorn--field repair added last minute
8W6NZ	Eric Brittain	Urgur Agmundr--another last minute lore
8XA6A	Kathleen Rios	Gya--Armored Training was misspelled
*/

select distinct n.characterId
	,convert(varchar(35),n.realName) realName
	,convert(varchar(35),n.characterName) characterName
--	,rawskill
	from #newMaster n join rawSkills s on s.characterId=n.characterId 
	where practiceCount>=3 and style like '%swan%' 
		and (s.rawskill like '%Swan%w%'
		or s.rawskill like '%Armor%Train%'
		or s.rawskill like '%oversiz%' or s.rawskill like '%weapon%master%'
		or s.rawskill like '%armorsmith%' or s.rawskill like '%tailor%'
		or s.rawskill like '%Fortify%' or s.rawskill like '%Field Repair%'
		)
	order by 1

	/*

characterId realName                            characterName
----------- ----------------------------------- -----------------------------------
76QD5       James McCloskey                     Jaerial Daxsharial
7AQDN       Brian Williams                      Strikarn Northwode Orson
7GZAN       Lily Thiemens                       Sahar Daxsharia
7KGBD       Cormac Sheehy                       Rhain
7QMZA       Jonny Martinez                      Seeker by Light and Shadow
859ND       Devin McCarthy                      Luminitous
8E4XE       Nicholas Marko                      The Persevering Hope
8M4WB       Andrew Cunado                       Keeper of Hearth's Embers
8PPQX       Nick Cronin                         Kitter, The Withering Thorn
8W6NZ       Eric Brittain                       Urgur Agmundr
8XA6A       Kathleen Rios                       Gya
8XZRD       Dean Jackman                        Mazarel Noctara
8YARE       Adriana Beals                       Anileia Tigaris
8YQPE       Corin Edwards                       Sóls'tur



*/

--also check against tickets
select distinct n.characterId
	,convert(varchar(35),n.realName) realName
	,convert(varchar(35),n.characterName) characterName
	,(select string_agg(game,', ') from #revisedMasterExploded re where re.characterId=n.characterId and re.style=n.style)
	,(select top 1 ticketType from tickets t where eventName='Event 90 April 2026' and t.playerName=n.realName)
	from #newMaster n join rawSkills s on s.characterId=n.characterId 
	

	where practiceCount>=3 and style like '%suff%' 
		and (s.rawskill like '%suff%'
		or s.rawskill like '%Forearm%'
		or s.rawskill like '%Shin%')
	order by 1

7K4WB	Christopher Rainey-Felley	Maxwell	December 2025, February 2026, January 2026	Full Event: NPC Saturday 10pm-2am--npc shift is during the test




select distinct n.characterId
	,convert(varchar(35),n.realName) realName
	,convert(varchar(35),n.characterName) characterName
,(select top 1 ticketType from tickets t where eventName='Event 90 April 2026' and t.playerName=n.realName)
	from #newMaster n join rawSkills s on s.characterId=n.characterId 
	where practiceCount>=3 and style like '%swan%' 
		and (s.rawskill like '%Swan%w%'
		or s.rawskill like '%Armor%Train%'
		or s.rawskill like '%oversiz%' or s.rawskill like '%weapon%master%'
		or s.rawskill like '%armorsmith%' or s.rawskill like '%tailor%'
		or s.rawskill like '%Fortify%' or s.rawskill like '%Field Repair%'
		)
	order by 1
	--looks good