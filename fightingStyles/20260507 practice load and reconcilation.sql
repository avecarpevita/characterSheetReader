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
bulk insert #master from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260507.tsv' with(datafiletype='char',firstrow=4)

--make sure I see row 4
select top 100 * from #master where realName like 'adam camp%'
--get count and smell
select count(*) from #master--258 smells right

--[2] load the practices (ALL) to determine adds to the master sheet
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
bulk insert #newPractices from 'C:\characterSheetReader\fightingStyles\practicesSnapshot20260507.tsv' with(datafiletype='char',firstrow=2)--9

--select * from #newPractices where game<>'April 2026' order by 1

--delete any that are NOT for last game (April 2026)
--FOR JULY AND BEYOND, make this a datestamp cutoff (ie. the high date after the last process!)
--FOR JULY AND BEYOND, make this a datestamp cutoff (ie. the high date after the last process!)
--FOR JULY AND BEYOND, make this a datestamp cutoff (ie. the high date after the last process!)
--FOR JULY AND BEYOND, make this a datestamp cutoff (ie. the high date after the last process!)
--FOR JULY AND BEYOND, make this a datestamp cutoff (ie. the high date after the last process!)
delete #newPractices where game<>'April 2026'
	and timestamp<>'2026-03-26 18:46:45.000'
--smell test
#newPractices order by 1--10 count looks good

--manual fix
update n
	set n.participant14='8ZVN4    Kenji Zhu-Lung- Mike Morales    '
	from #newPractices n where timestamp='2026-05-06 20:56:56.000'

--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!
--EYEBALL THEM HERE FOR LESS THAN 10!!!

--[3]--note the max cutoff from #practicesToDate for future use
select * from #newPractices order by [timestamp] desc--2026-05-06 20:56:56.000

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
update #newPracticesExploded set characterId='8E4XE' where nameInfoRaw='- The Persevering Hope - Nicholas Marles'
update #newPracticesExploded set characterId='8KGEM' where nameInfoRaw='- Tanek Swanf - Jason Jahromi'
update #newPracticesExploded set characterId='7J5ZW' where nameInfoRaw='- Zar''gest - Michel Wong'
update #newPracticesExploded set characterId='86DEJ' where nameInfoRaw='- Ko''Vally - Robert Valdez'
update #newPracticesExploded set characterId='8KGEM' where nameInfoRaw='- Tanek Swavf - Jason Jahromi'
update #newPracticesExploded set characterId='85QYA' where nameInfoRaw='Katalyna Valentyyna - Ash Casanova'
update #newPracticesExploded set characterId='8MG4R' where nameInfoRaw='Laekmir Kottr - Pavana Somisetty'

update #newPracticesExploded set characterId='7XXEV' where nameInfoRaw='- Tanek Swanf - Jason Jahromi'
update #newPracticesExploded set characterId='7XXEV' where nameInfoRaw='- Tanek Swavf - Jason Jahromi'
update #newPracticesExploded set characterId='8MG4R' where nameInfoRaw='Laekmir Kottr - Pavana Somisetty'

update #newPracticesExploded set characterId='8MG4R' where nameInfoRaw='Laekmir Kottr - Pavana Somisetty'
update #newPracticesExploded set characterId='7DZ9B' where nameInfoRaw='/ Syrendra / Ash Luna'
update #newPracticesExploded set characterId='8M9NJ' where nameInfoRaw='/ Skullmaggot / Andrew Frejek'
update #newPracticesExploded set characterId='8QY6J' where nameInfoRaw='/ Cassius Fynch / Jackson Korsgaard'

select * from rawCPData where characterId in ('8KGEM','8MG4R')
select * from rawCPData where playerName like '%Pavana%'--
select * from rawCPData where playerName like '%Jahromi%'--
select * from postFeb26.rawCPData where playerName like '%Pavana%'--
select * from postFeb26.rawCPData where playerName like '%Jahromi%'--


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
create unique clustered index x on #masterExploded(game,style,characterId)
--#masterExploded where realName is null

--[6]--combine #newPracticesExploded and #masterExploded
drop table if exists #revisedMasterExploded
select characterId,game,style 
	into #revisedMasterExploded
	from #newPracticesExploded
union select characterId,game,style from #masterExploded
create unique clustered index x on #revisedMasterExploded(game,style,characterId)
--#revisedMasterExploded where realName is null

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

--[8]--dump this into the master (after backing up the master)
select * from #newMaster order by realName,characterName


update n
	set 
		n.characterName=r.characterName
		,n.realName=r.playerName
	from #newMaster n
		left join postFeb26.rawCPData r on r.characterId=n.characterId
		where n.realName is null


--check for tests and prereqs
--ASSASSIN'S ARTS

--select * from #newMaster where realName like 'oliv%'

select * from #newMaster where practiceCount>=3 and style like '%ass%' order by 2--11, smells right

/*
R. Lore - The Assassin's Arts
Short Weapons, Thrown Weapons and Bow and Arrow
	or Effendal Weapon Mastery in lieu of these three skills
			Stealth Attack
			Disguise or Glamour
*/

drop table if exists #check
select n.characterId
	,convert(char(35),n.realName) realName
	,convert(char(35),n.characterName) characterName
	,string_agg(case when rawSkill like '%lore%assass%' then rawSkill 
		when rawSkill like '%thrown%' then rawSkill
		when rawSkill like '%short%' then rawSkill
		when rawSkill like '%bow%' then rawSkill
		when rawSkill like '%weapon mast%' then rawSkill
		when rawSkill like '%Stealth%' then rawSkill
		when rawSkill like '%Disguise%' then rawSkill
		when rawSkill like '%Glamour%' then rawSkill
		end,' | ') skills
	into #check
	from #newMaster n 
	join rawSkills r on r.characterId=n.characterId
	where n.practiceCount>=3 and n.style like '%ass%' 
	group by n.characterId,n.realName,n.characterName
	order by 3

select * from #check
	where skills not like '%lore%ass%'
	or (skills not like '%Disguise%' and skills not like '%Glamour%')
	or (skills not like '%Stealth%' )
	or (skills not like '%thrown%' and skills not like '%weapon mast%')
	or (skills not like '%short%' and skills not like '%weapon mast%')
	or (skills not like '%bow%' and skills not like '%weapon mast%')

/*
characterId realName                            characterName                       skills
----------- ----------------------------------- ----------------------------------- ---------------------------------------------------------------------------------------------------------
7554G       Cass Coomber                        Victory Wildsong                    Bow and Arrow | Disguise | Short Weapons | Stealth Attack | Thrown Weapons								--missing ASS, but it's there, so moving on
7GA99       Brady Heaton                        Virgil Acula                        R. Lore: Assassin's Arts | Stealth | Thrown Weapons														--missing disguise and bow and arrow  (short is bundled), but last edit was 11 am today, gtg)
84DVJ       Gil Ramirez                         Salomon “Slip” Jasset               Bow & Arrow | Detect Disguise | Disguise | R. Lore: Assassin Arts | Stealth Attack | Thrown Weapons		--bundled with two-handed, gtg
8GGRM       Rose Kochanek                       Nalain Calae                        Disguise | R. Lore: Assassin's Arts | Short Weapons														--rose is out, no bow and arrow on google sheet
*/

delete #check where characterId='8GGRM'--1

--list for discord post
select c.characterId,c.realName,c.characterName
	from #check c join rawCPData r on r.characterId=c.characterId

--list for email
select c.characterId,c.realName,c.characterName
	,r.email 
	from #check c join rawCPData r on r.characterId=c.characterId

/*
characterId realName                            characterName                       email
----------- ----------------------------------- ----------------------------------- ----------------------------------------------------------------------------------------------------
8N6NE       Iris Do                             Doctor Amelya                       do.iris0101@gmail.com
8VMJP       Clint Worley                        Jack Martindale                     clint.l.worley@gmail.com
7JG4P       Taylor Harrs                        Jaguar                              taylorharrs@gmail.com
85GKA       Aurum Pallitto                      Junius                              pallittoxz@gmail.com
8K4QA       Kit Wells                           Ke’wyn                              Kitswells@gmail.com
8NJ4K       Sebastian della Gatta               Omentos Ventavius                   seabassdg42@gmail.com
84DY9       James O'Neil                        Rembrandt van Tweebloemen           adrain.case.ic@gmail.com
84DVJ       Gil Ramirez                         Salomon “Slip” Jasset               GilTheVlogsmith@gmail.com
7554G       Cass Coomber                        Victory Wildsong                    cassandracoomber@gmail.com
7GA99       Brady Heaton                        Virgil Acula                        thelastknighterrant@gmail.com
