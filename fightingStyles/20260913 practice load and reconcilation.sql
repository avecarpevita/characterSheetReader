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
bulk insert #master from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260913.tsv' with(datafiletype='char',firstrow=4)

--make sure I see row 4
select top 100 * from #master where realName like 'adam camp%'
--get count and smell
select count(*) from #master--319 is correct
select * from #master order by realName

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
	,participant21 varchar(1000) not null
	,participant22 varchar(1000) not null
	,participant23 varchar(1000) not null
	,participant24 varchar(1000) not null
	,participant25 varchar(1000) not null
	,participant26 varchar(1000) not null
	,participant27 varchar(1000) not null
	,participant28 varchar(1000) not null
	,participant29 varchar(1000) not null
	,participant30 varchar(1000) not null
	)
alter table #newPractices add primary key clustered(game,style,realName,practicewhen)
bulk insert #newPractices from 'C:\characterSheetReader\fightingStyles\practicesSnapshot20260913.tsv' with(datafiletype='char',firstrow=2)--9

select * from #newPractices order by try_cast(timestamp as datetime) desc--48 is correct
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
select * from #newPractices order by [timestamp] desc--2026-08-25 21:13:16.000

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
union select game,style,participant21 as participant	from #newPractices
union select game,style,participant22 as participant	from #newPractices
union select game,style,participant23 as participant	from #newPractices
union select game,style,participant24 as participant	from #newPractices
union select game,style,participant25 as participant	from #newPractices
union select game,style,participant26 as participant	from #newPractices
union select game,style,participant27 as participant	from #newPractices
union select game,style,participant28 as participant	from #newPractices
union select game,style,participant29 as participant	from #newPractices
union select game,style,participant30 as participant	from #newPractices
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
update #newPracticesExploded set characterId='8XNXE' where nameInfoRaw='Deacon Ariadne- William Conti'

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
		left join postMay26.rawCPData r on r.characterId=n.characterId
		where n.playerName is null

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
--Six Dragons
select * from #newMaster where practiceCount>=3 and style like '%Six Dragon%' order by 2--38 for now

/*
R. Lore - Six Dragons
			Two-Weapon Fighting
			Oversized Weapon Use or Weapon Master

journeyman
At least 20 cp from the General Combat Skills section.
*/

drop table if exists #check
select n.characterId
	,convert(char(35),n.realName) realName
	,convert(char(35),n.characterName) characterName
	,string_agg(case when rawSkill like '%Six%Dragon%' or rawSkill like '%6%Dragon%' then rawSkill 
		when rawSkill like '%Two%Weapon%Fighting%' then rawSkill
		when rawSkill like '%weapon mast%' then rawSkill
		when rawSkill like '%Oversized%' then rawSkill
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
	where n.practiceCount>=3 and n.style like '%six dragon%'
	group by n.characterId,n.realName,n.characterName
	order by 3

select * from #check
	where (skills not like '%Six%Dragon%' and skills not like '%6%Dragon%')
	or (skills not like '%Two%Weapon%Fighting%')
	or (skills not like '%weapon mast%' and skills not like '%Oversized%')

/*
characterId				realName							characterName						skills
75PDV					Jackson Bird                       	Kolten Aldrick                     	R. Lore: Six Dragons | Two-Weapon Fighting		missing oversized
7J5ZW					Michel Wong                        	Zar'gest                           	R. Lore: Six Dragons | Two-Weapon Fighting		missing oversized
7WJD4					Thomas Cassera                     	Xannik                             	Two-Weapon Fighting								missing a bunch
7WZXK					Michael Cline                      	Klepto                             	R. Lore: Six Dragons | Two-Weapon Fighting		missing oversized
8NQDP					Forrester Sherrick                 	Gappo                              	Two-Weapon Fighting								missing lore
8YJ9B					Steve Calise                       	AZ'Ralqul                          	Two-weapon Fighting								missing lore
8Z45M					Natasha Hayes                      	Saelinn Mordighan                  	R. Lore: Six Dragons							missing two-weapon fighting
8ZZ6P					Ramsay Potts                       	Jacques Slate                      	Two-Weapon Fighting								missing lore
*/
delete #check where(skills not like '%Six%Dragon%' and skills not like '%6%Dragon%')
	or (skills not like '%Two%Weapon%Fighting%')
	or (skills not like '%weapon mast%' and skills not like '%Oversized%')



drop table if exists #check2
select c.characterId,c.realName,c.characterName
	,string_agg(r.rawSkill,'|') rawSkills
	,sum(try_cast(rawCPSpent as int)) cpSpent
	into #check2
	from #check c join #newMaster n on c.characterId=n.characterId
		join rawSkills r on r.characterId=c.characterId
	where n.practiceCount>=6 and n.style like '%six dragon%'
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
7GA99	Brady Heaton                       	Virgil Acula                       	Parry x1|Stun|Toughness x2									13
8BVRW	Russell Willoughby                 	Sylver Sequoia                     	Dodge x0|Great Strike|Parry x1|Toughness x2|Willpower x1	19
8K49R	Justen Speratos                    	Azymondias Zysyss                  	Dodge x0|Parry x0|Toughness x4|Willpower x0					12

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

	/*
characterId realName                            characterName                       rankQualified email
----------- ----------------------------------- ----------------------------------- ------------- ----------------------------------------------------------------------------------------------------
8EDVE       Collin Babcock                      Audax                               Apprentice    pelordonotwant@gmail.com
8K49R       Justen Speratos                     Azymondias Zysyss                   Apprentice    justensperatos@gmail.com
89W6P       Nick Williams                       Casútor                             Apprentice    nick@swingnick.com
74DWK       Lux Icarian                         Chimera                             Apprentice    Lux.Icarian@gmail.com
8VMJP       Clint Worley                        Jack Martindale                     Apprentice    clint.l.worley@gmail.com
7BKK6       TJ Reyes                            Jin Yumiya                          Apprentice    treyes86@gmail.com
8QYQX       Micah Lamdin                        Kheldarin                           Apprentice    mlamdin@gmail.com
8EQJJ       Alexander Webber                    Krowe                               Apprentice    alexanderswebber@gmail.com
8QYG9       Melissa Melendez                    Major Zelmira Caranthand Velyrone N Apprentice    mthomas21522@gmail.com
7EDYM       Josh Bisquera                       Nimbus Tear                         Apprentice    joshbisquera12@gmail.com
8QJ4E       Adam Campbell-Kruger                Roland d'Argent                     Apprentice    adamcampbellkruger@gmail.com
8EQG9       Nicholas Prouty                     Shadrek Dario                       Apprentice    1nicopico@gmail.com
8BVRW       Russell Willoughby                  Sylver Sequoia                      Apprentice    rwilloughby77@gmail.com
7XZXK       Daniel West                         Val McAllister                      Apprentice    daniel.west739@gmail.com
7GA99       Brady Heaton                        Virgil Acula                        Apprentice    thelastknighterrant@gmail.com
8QY6J       Jackson Korsgaard                   Cassius Fynch                       Journeyman    jacksonkorsgaard@gmail.com
8J6WX       Stephen McArthur                    Cecil                               Journeyman    scm2117@gmail.com
8AQKN       Max Pflueger                        Darius Dravik                       Journeyman    mpflueger@gmail.com
7PPDX       Albert Blattler                     Gwillion Silduine, the Cross-Eyed T Journeyman    ablattle1@gmail.com
76GGG       Jonathan Young                      Jarin'ael Aethyn                    Journeyman    jonathanyoungmusic@gmail.com
8GZXE       Jerrod Hayes                        Kandóryn Pellintië                  Journeyman    zolomgaming@gmail.com
8W6AZ       Sebastian della Gatta               Kavu                                Journeyman    seb@mostlymustard.com
8ZVN4       Mike Morales                        Kenji Zhu-Lung                      Journeyman    kenji_247@hotmail.com
74KVG       Brian Kibler                        Khar'tan                            Journeyman    bmkibler@gmail.com
84DVJ       Gil Ramirez                         Salomon “Slip” Jasset               Journeyman    GilTheVlogsmith@gmail.com
8M9NJ       Andrew Frejek                       Skull Maggot                        Journeyman    andrewtfrejek@gmail.com
7DZ9B       Ash Luna                            Syrendra Northwode                  Journeyman    wulfriick@gmail.com
8KA6D       Dylan Yanke                         Victor Frost                        Journeyman    yankedylan@gmail.com
8A6NQ       Caleb Medchill                      Zeffladin Keareth                   Journeyman    caleb.medchill@gmail.com
*/

;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select rankQualified,count(*) from cte group by rankQualified order by 1

rankQualified 
------------- -----------
Apprentice    16
Journeyman    14
--print 20 of each


--SWANWALL
/*
--apprentice
R. Lore - Swanwall
			Armored Training: Light
			Oversized Weapon Use
			Armorsmithing: Apprentice or Tailoring: Apprentice
			Fortify Armor
			Field Repair x1
--journeyman
	At least 20 cp in skills in uses of Field Repair or skills from the General 
*/

drop table if exists #check
select n.characterId
	,convert(char(35),n.realName) realName
	,convert(char(35),n.characterName) characterName
	,string_agg(case when rawSkill like '%Swan%w%' then rawSkill 
		when rawSkill like '%Arm%Train%' then rawSkill
		when rawSkill like '%oversiz%' or rawskill like '%weapon%master%' then rawSkill
		when rawSkill like '%armorsmith%' or rawskill like '%tailor%' then rawSkill
		when rawSkill like  '%Fortify%' or rawskill like '%Field Repair%' then rawSkill
		
		end,' | ') skills
	into #check
	from #newMaster n 
	join rawSkills r on r.characterId=n.characterId
	where n.practiceCount>=3 and n.style like '%swan%' 
	group by n.characterId,n.realName,n.characterName
	order by 3


select * from #check where (skills not like '%Swan%w%' )
delete from #check where (skills not like '%Swan%w%' )--5

select * from #check where (skills not like '%Armo%r%Train%' )
	or (skills not like '%oversiz%' and skills not like '%weapon%master%')
	or (skills not like '%armorsmith%' and skills not like '%tailor%')
	or (skills not like '%armorsmith%' and skills not like '%Field Repair%')--0



drop table if exists #check2
select c.characterId,c.realName,c.characterName
	,string_agg(r.rawSkill,'|') rawSkills
	,sum(try_cast(rawCPSpent as int)) cpSpent
	into #check2
	from #check c join #newMaster n on c.characterId=n.characterId
		join rawSkills r on r.characterId=c.characterId
	where n.practiceCount>=6 and n.style like '%swan%'
		and (r.rawSkill like '%toughness%' 
							 or r.rawSkill like '%dodge%' 
							 or r.rawSkill like '%willpower%' 
							 or r.rawSkill like '%parry%' 
							 or r.rawSkill like '%guardian%' 
							 or r.rawSkill like '%stamina train%' 
							 or r.rawSkill like '%great stamina%'
							 or r.rawSkill like '%great strike%' 
							 or r.rawSkill like '%tactical lunge%' 
							 or r.rawSkill like '%stun%'  
							 or r.rawSkill like '%field%repair%')
	group by c.characterId,c.realName,c.characterName

select * from #check2 where cpSpent<20
/*
8M4WB	Andrew Cunado                      	Keeper of Hearth's Embers          	Field Repair|Toughness x2									8
8W6NZ	Eric Brittain                      	Urgur Agmundr                      	Dodge x0|Field Repair|Parry x1|Toughness x0|Willpower x1	12
*/

delete #check2 where cpSpent<20--



;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select c.* 
	,r.email
	from cte c join rawCpData r on r.characterId=c.characterId
	order by rankQualified,characterName


/*
characterId realName                            characterName                       rankQualified email
----------- ----------------------------------- ----------------------------------- ------------- ----------------------------------------------------------------------------------------------------
8YARE       Adriana Beals                       Anileia Tigaris                     Apprentice    katrice349@gmail.com
8RV95       John Charles Schmerker              Aveus Mac Dris                      Apprentice    Johncharles.schmerker@gmail.com
8M4WB       Andrew Cunado                       Keeper of Hearth's Embers           Apprentice    acunado26@gmail.com
7VJX4       Jeffrey Adams                       Lucada                              Apprentice    jeffreyadams815@gmail.com
8XZRD       Dean Jackman                        Mazarel Noctara                     Apprentice    thedrjackman@gmail.com
7AQDN       Brian Williams                      Strikarn Northwode Orson            Apprentice    70brianwilliams@gmail.com
8W6NZ       Eric Brittain                       Urgur Agmundr                       Apprentice    EricBrittain@gmail.com
74D6R       Zachary Davis                       Vicena Gosi Calae                   Apprentice    zac3141@gmail.com
79DBG       Trevor West                         Brollen Whitstone                   Journeyman    twest4015@gmail.com
8XA6A       Kathleen Rios                       Gya                                 Journeyman    dtonks1127@gmail.com
76QD5       James McCloskey                     Jaerial Daxsharial                  Journeyman    jamesmcclosk@gmail.com
8PPQX       Nick Cronin                         Kitter, The Withering Thorn         Journeyman    nickcronin11@gmail.com
859ND       Devin McCarthy                      Luminitous                          Journeyman    devinbravado@gmail.com
7KGBD       Cormac Sheehy                       Rhain                               Journeyman    cormacsheehy0@gmail.com
7GZAN       Lily Thiemens                       Sahar Daxsharia                     Journeyman    lily.thiemens@gmail.com
7QMZA       Jonny Martinez                      Seeker by Light and Shadow          Journeyman    jonnymartinez3344@gmail.com
8YQPE       Corin Edwards                       Sóls'tur                            Journeyman    edwardscorin@gmail.com
8E4XE       Nicholas Marko                      The Persevering Hope                Journeyman    nicholasmarko@icloud.com
*/

;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select rankQualified,count(*) from cte group by rankQualified order by 1

rankQualified 
------------- -----------
Apprentice    8
Journeyman    10

--10 of each?


---SUFFERING


drop table if exists #check
select n.characterId
	,convert(char(35),n.realName) realName
	,convert(char(35),n.characterName) characterName
	,string_agg(case when rawSkill like '%suffer%'  then rawSkill 
		when rawSkill like '%Forearm%' then rawSkill
		when rawSkill like '%Shin%' then rawSkill
		
		end,' | ') skills
	into #check
	from #newMaster n 
	join rawSkills r on r.characterId=n.characterId
	where n.practiceCount>=3 and n.style like '%suffer%' 
	group by n.characterId,n.realName,n.characterName
	order by 3


select * from #check where (skills not like '%suffer%' )--0
delete from #check where (skills not like '%suffer%' )--0

select * from #check where (skills not like '%Forearm%' )
	or (skills not like '%Shin%')--0

/*
At least 20 cp in skills from the School of Suffering, General Combat Skills, or The Assassin's Arts sections. The initial 6 CP for Armored Forearms and 9 CP for Armored Shins are not counted towards this total.
*/

drop table if exists #check2
select c.characterId,c.realName,c.characterName
	,string_agg(r.rawSkill,'|') rawSkills
	,sum(try_cast(rawCPSpent as int)) cpSpent
	into #check2
	from #check c join #newMaster n on c.characterId=n.characterId
		join rawSkills r on r.characterId=c.characterId
	where n.practiceCount>=6 and n.style like '%suffer%'
		and (r.rawSkill like '%slow%bleed%' 
							 or r.rawSkill like '%medi%still%' 
							 or r.rawSkill like '%slow%death%' 
							 or r.rawSkill like '%tort%resist%' 
							 or r.rawSkill like '%tort%immu%' 
							 or r.rawSkill like '%toughness%' 
							 or r.rawSkill like '%dodge%' 
							 or r.rawSkill like '%willpower%' 
							 or r.rawSkill like '%parry%' 
							 or r.rawSkill like '%guardian%' 
							 or r.rawSkill like '%stamina train%' 
							 or r.rawSkill like '%great stamina%'
							 or r.rawSkill like '%great strike%' 
							 or r.rawSkill like '%tactical lunge%' 
							 or r.rawSkill like '%stun%'
							 
							 or r.rawSkill like '%stealth%' 
							 or r.rawSkill like '%10%damage%'
							 or r.rawSkill like '%stud%kill%' 
							 or r.rawSkill like '%twist%kni%' 
							 or r.rawSkill like '%shin%kick%'
							 or r.rawSkill like '%hidd%weap%'
							 or r.rawSkill like '%leap%'
							 or r.rawSkill like '%death%vault%'
							 or r.rawSkill like '%rope%use%')

	group by c.characterId,c.realName,c.characterName


select * from #check2 where cpSpent<20
/*
7GA99	Brady Heaton                       	Virgil Acula                       	Leap|Parry x1|Rope Use|Stun|Toughness x2	18
7K4WB	Christopher Rainey-Felley          	Maxwell                            	Torture Resistance|Toughness x1				6
*/

delete #check2 where cpSpent<20--




;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select c.* 
	,r.email
	from cte c join rawCpData r on r.characterId=c.characterId
	order by rankQualified,characterName

/*
characterId realName                            characterName                       rankQualified email
----------- ----------------------------------- ----------------------------------- ------------- ----------------------------------------------------------------------------------------------------
7DJ4V       Olivia Gobert-Hicks                 Alira / Dawn's Radiance             Apprentice    livi.lunacy@gmail.com
8AQKN       Max Pflueger                        Darius Dravik                       Apprentice    mpflueger@gmail.com
8XNXE       William Conti                       Deacon Ariadne                      Apprentice    Contiw8@gmail.com
8N6NE       Iris Do                             Doctor Amelya                       Apprentice    do.iris0101@gmail.com
85GKA       Aurum Pallitto                      Junius                              Apprentice    pallittoxz@gmail.com
8GZXE       Jerrod Hayes                        Kandóryn Pellintië                  Apprentice    zolomgaming@gmail.com
7K4WB       Christopher Rainey-Felley           Maxwell                             Apprentice    crfelley@gmail.com
8WN9G       Trevor Ryan                         Quincy Dessick Demir                Apprentice    trexnryan896@gmail.com
7EQ5W       Jordan Irby                         Rai’byn Beleron                     Apprentice    my_creative_mind@yahoo.com
8X5DM       AJ Lepe                             Reniion Gauldir                     Apprentice    B100dw01f307@gmail.com
84DVJ       Gil Ramirez                         Salomon “Slip” Jasset               Apprentice    GilTheVlogsmith@gmail.com
8RZMV       Phillip Stachelski                  Tathlan Abyth                       Apprentice    phillipstachelski@gmail.com
7GA99       Brady Heaton                        Virgil Acula                        Apprentice    thelastknighterrant@gmail.com
86GKW       Ismael Alvarez                      Ikram Malverde                      Journeyman    ismaelfdoalvarez@gmail.com
8VMJP       Clint Worley                        Jack Martindale                     Journeyman    clint.l.worley@gmail.com
8MG4R       Pavana Somisetty                    Laekmir Kottr                       Journeyman    p.somisetty@gmail.com
*/


;with cte as (
select characterId,realName,characterName,'Journeyman' rankQualified from #check2
union
select characterId,realName,characterName,'Apprentice' rankQualified from #check c where not exists (select null from #check2 c2 where c2.characterId=c.characterId)
)
select rankQualified,count(*) from cte group by rankQualified order by 1

rankQualified 
------------- -----------
Apprentice    13
Journeyman    3

--don't need to print much at all