use tm

--[1] load the existing master sheet 
	--[https://docs.google.com/spreadsheets/d/1k7nJRc1OglY8B7dkddJlQeOo4hPL7Dq1Cp-ItnEREWI/edit?gid=0#gid=0]


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
bulk insert #master from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260702.tsv' with(datafiletype='char',firstrow=4)

--make sure I see row 4
select top 100 * from #master where realName like 'adam camp%'
--get count and smell
select count(*) from #master--287 smells right

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
bulk insert #newPractices from 'C:\characterSheetReader\fightingStyles\practicesSnapshot20260702.tsv' with(datafiletype='char',firstrow=2)--9

select * from #newPractices order by try_cast(timestamp as datetime) desc--32 is correct
--select top 100 * from #newPractices where game='May 2026'

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

update #newPracticesExploded set characterId='8MG4R' where nameInfoRaw in ('Laekmir Kottr - Pavana Somisetty','Laekmir Kottr - Pavana Somisetty','Laekmir Kottr - Pavana Somisetty','Laekmir Kottr - Pavana Somisetty')
update #newPracticesExploded set characterId='7DZ9B' where nameInfoRaw='/ Syrendra / Ash Luna'
update #newPracticesExploded set characterId='8M9NJ' where nameInfoRaw='/ Skullmaggot / Andrew Frejek'
update #newPracticesExploded set characterId='8QY6J' where nameInfoRaw='/ Cassius Fynch / Jackson Korsgaard'

update #newPracticesExploded set characterId='859ND' where nameInfoRaw in ('Luminitous GÇô Devin McCarthy','Luminintous - Devin McCarthy')

update #newPracticesExploded set characterId='8VGDD' where nameInfoRaw='Desmond Jollicouer- Samuel Lock'
update #newPracticesExploded set characterId='7AQDN' where nameInfoRaw='Strikarn Orson - Brian Williams'

update #newPracticesExploded set characterId='8GGRM' where nameInfoRaw='Nalain Calae - Rose Kochanek'

update #newPracticesExploded set characterId='7GZAN' where nameInfoRaw='Sahar Daxsharia - Lily Thiemens'

update #newPracticesExploded set characterId='8MG4R' where nameInfoRaw='Laekmir Kottr - Pavana Somisetty'

C:/Users/scott.ross/AppData/Local/Microsoft/WindowsApps/python3.13.exe c:/characterSheetReader/python/tmProcessAllSheets.py "-sPavana" "-ePavana"
select * from rawCPdata where characterId='8MG4R'
select * from postApr26.rawCPdata where characterId='8MG4R'
select * from postFeb26.rawCPdata where characterId='8MG4R'

update n
	set n.characterId=upper(n.characterId)
		,n.nameInfoRaw=ltrim(rtrim(n.nameInfoRaw))
		,n.characterName=r.characterName
		,n.playerName=r.playerName
	from #newPracticesExploded n
		left join rawCPData r on r.characterId=n.characterId
		--rawCPData where characterId='8MG4R'


update n
	set n.characterId=upper(n.characterId)
		,n.nameInfoRaw=ltrim(rtrim(n.nameInfoRaw))
		,n.characterName=r.characterName
		,n.playerName=r.playerName
	from #newPracticesExploded n
		left join postApr26.rawCPData r on r.characterId=n.characterId
		where n.playerName is null

update n
	set n.characterId=upper(n.characterId)
		,n.nameInfoRaw=ltrim(rtrim(n.nameInfoRaw))
		,n.characterName=r.characterName
		,n.playerName=r.playerName
	from #newPracticesExploded n
		left join postFeb26.rawCPData r on r.characterId=n.characterId
		where n.playerName is null

--fix script
select distinct 'update #newPracticesExploded set characterId=''taco'' where nameInfoRaw='''+nameInfoRaw+''''  from #newPracticesExploded where characterName is null--4

		
		 

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
delete #newMaster where realname is null
select * from #newMaster order by realName,characterName





--check for tests and prereqs -- MMTS


--select * from #newMaster where realName like 'oliv%'

select * from #newMaster where practiceCount>=3 and style like '%mountain%' order by 2--39 for now

/*
R. Lore - Mountain Meets the Sky
			Armored Training: Heavy
			One-Handed Weapons
			Shield Use


journeyman
At least 20 cp in skills from the General Combat Skills section
*/

drop table if exists #check
select n.characterId
	,convert(char(35),n.realName) realName
	,convert(char(35),n.characterName) characterName
	,string_agg(case when rawSkill like '%lore%mountain%' or rawSkill like '%lore%sky%' then rawSkill 
		when rawSkill like '%armor%heavy%' then rawSkill
		when rawSkill like '%heavy%armor%' then rawSkill
		when rawSkill like '%one%handed%' then rawSkill
		when rawSkill like '%shield%' then rawSkill
		when rawSkill like '%weapon mast%' then rawSkill
		when rawSkill like '%Oversized%' and try_cast(rawCPSpent as int)=8 then rawSkill+' at 8'
		when rawSkill like '%two%handed%' and try_cast(rawCPSpent as int)=6 then rawSkill+' at 6'
		--when rawSkill like '%toughness%' then rawSkill
		--when rawSkill like '%dodge%' then rawSkill
		--when rawSkill like '%willpower%' then rawSkill
		--when rawSkill like '%parry%' then rawSkill
		--when rawSkill like '%guardian%' then rawSkill
		--when rawSkill like '%stamina train%' then rawSkill
		--when rawSkill like '%great stamina%' then rawSkill
		--when rawSkill like '%great strike%' then rawSkill
		--when rawSkill like '%tactical lunge%' then rawSkill
		--when rawSkill like '%stun%' then rawSkill
		end,' | ') skills
	into #check
	from #newMaster n 
	join rawSkills r on r.characterId=n.characterId
	where n.practiceCount>=3 and n.style like '%mountain%'
	group by n.characterId,n.realName,n.characterName
	order by 3

select * from #check
	where (skills not like '%lore%mount%' and skills not like '%lore%sky%')
	or (skills not like '%armor%' and skills not like '%heavy%')
	or (skills not like '%Shield%')
	or (skills not like '%One%handed%' and skills not like '%Weapon Master%' and skills not like '%Oversized%8%' and skills not like '%two%handed%6%')

7KGVM	Keigin Tosh                        --is totally missing weapon profs
7NPBM	Jason Walker                       --missing short & one-handed

delete #check where (skills not like '%lore%mount%' and skills not like '%lore%sky%')
	or (skills not like '%armor%' and skills not like '%heavy%')
	or (skills not like '%Shield%')
	or (skills not like '%One%handed%' and skills not like '%Weapon Master%' and skills not like '%Oversized%8%' and skills not like '%two%handed%6%')

delete #check where characterId='756Y6'--Ard, permed

drop table if exists #check2
select c.characterId,c.realName,c.characterName
	,string_agg(r.rawSkill,'|') rawSkills
	,sum(try_cast(rawCPSpent as int)) cpSpent
	into #check2
	from #check c join #newMaster n on c.characterId=n.characterId
		join rawSkills r on r.characterId=c.characterId
	where n.practiceCount>=6 and n.style like '%mountain%'
		and (r.rawSkill like '%toughness%' 
							 or r.rawSkill like '%dodge%' 
							 or r.rawSkill like '%willpower%' 
							 or r.rawSkill like '%parry%' 
							 or r.rawSkill like '%guardian%' 
							 or r.rawSkill like '%stamina train%' 
							 or r.rawSkill like '%great stamina%'
							 or r.rawSkill like '%great strike%' 
							 or r.rawSkill like '%tactical lunge%' 
							 or r.rawSkill like '%stun%'  )
	group by c.characterId,c.realName,c.characterName

select * from #check2 where cpSpent<20
delete #check2 where cpSpent<20--just Mont

;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select c.* 
	,r.email
	from cte c join rawCpData r on r.characterId=c.characterId
	order by rankQualified,characterName

characterId realName                            characterName                       rankQualified email
----------- ----------------------------------- ----------------------------------- ------------- ----------------------------------------------------------------------------------------------------
8PDRK       Taylor Harrs                        Apotheosis                          Apprentice    taylorharrs@gmail.com
7VMXN       Matthew Salus                       Atticus Northwode Velyrone          Journeyman    sphader@gmail.com
79ZXN       Zachary Armine-Klein                Augustus Invictus                   Journeyman    waffleswithc4@gmail.com
8RV95       John Charles Schmerker              Aveus Mac Dris                      Apprentice    Johncharles.schmerker@gmail.com
8JJD6       John Vescio                         Baergrym Joybarrel                  Journeyman    johnvescio101@gmail.com
89W6P       Nick Williams                       Casútor                             Apprentice    nick@swingnick.com
8J5GP       Ben Hasenbalg                       Clemency of Dusk                    Apprentice    benhasenbalg114897@gmail.com
8RYYE       Joshua Warner                       Derren Bendriven                    Apprentice    joshuawarner333@gmail.com
8QVWB       Ashton Parks                        Haymond Valance Madok               Journeyman    parksashton23@gmail.com
76QB5       Reiner Perillo                      Kamiryu Kibou                       Apprentice    reiner.perillo@gmail.com
7V66X       Justin Chan                         Khythe                              Apprentice    vaurca@gmail.com
7VJX4       Jeffrey Adams                       Lucada                              Journeyman    jeffreyadams815@gmail.com
859ND       Devin McCarthy                      Luminitous                          Journeyman    devinbravado@gmail.com
8K45A       Gasper Spinosa                      Luxxaerys                           Journeyman    gasperweb@gmail.com
8PQWR       Ana Alvarez                         Luz Villalobos                      Journeyman    aadorisart@gmail.com
8M4EZ       Gil Ramirez                         Martel Whitecloak                   Apprentice    GilTheVlogsmith@gmail.com
8B9P9       Michael Butler                      Mathias                             Apprentice    butlermichael1993@gmail.com
8V6NX       Sam Fleyshman                       Mont                                Apprentice    21samfley@gmail.com
7RZEV       Andrew Buczacki                     Oak                                 Journeyman    abuczacki@gmail.com
7WJRW       Jeff Gerard                         Rai Atsushi                         Apprentice    piratevyse@aol.com
7ZVX4       Michael-Bryan Kelly                 Retitus Tenebris                    Apprentice    crystalforge66502@yahoo.com
8QV4A       Clint Duff                          Richard                             Journeyman    asoyatoe@gmail.com
7A6YN       Jonathan Ying                       Roderick                            Apprentice    jonjonying@gmail.com
7G4EP       Steven Maus                         Sagar Proudeyes                     Apprentice    lazarus.darkeyes@gmail.com
8BVAZ       Jackie Salow-Wiley                  Sarest                              Apprentice    thewileyside@gmail.com
8NPXJ       Carlos Baldeon                      Sayid Ibn Rashid Al Shaitan         Apprentice    cfbaldeon.ysc@gmail.com
7AQDN       Brian Williams                      Strikarn Northwode Orson            Apprentice    70brianwilliams@gmail.com
8RZNQ       Van Franklin                        Thorkell Grimwaldsson               Journeyman    vlf1224@gmail.com
76G4J       Kaitlyn Risser                      Ti-Zhan Payne                       Apprentice    kattrisser@gmail.com
7XZXK       Daniel West                         Val McAllister                      Journeyman    daniel.west739@gmail.com
8A6QN       Sidney Domholdt                     Van Yel Ashke-Calarco               Journeyman    Ldomholdt@gmail.com
7BDKY       Ethan Bell                          Vitus Cassian                       Journeyman    ezb008@gmail.com
8YZN4       Christopher Rice                    Vladmir Von Luthren                 Journeyman    dragoonrune@gmail.com
894A4       Grant Rogers                        Wayland Tarsis                      Journeyman    Grantdennissrogers@gmail.com

;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select rankQualified,count(*) from cte group by rankQualified order by 1

rankQualified 
------------- -----------
Apprentice    18
Journeyman    16

--print 20 of each