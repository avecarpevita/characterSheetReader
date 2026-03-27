use tm

--select * from sys.schemas--postDec25

--[1] determine the r. lores I'm looking for
drop table if exists #rLores
create table #rLores (lore varchar(255) not null primary key clustered
	,cleanLore varchar(255) null
	)
insert into #rLores 
select distinct rawSkill,dbo.cleanRawLore(rawSkill) from rawSkills
	where rawSkill like  '%lore%aeth%'
		or rawSkill like '%lore%hydro%'
		or rawSkill like '%lore%litho%'
		or rawSkill like '%lore%lucen%'
		or rawSkill like '%lore%pyro%'
		or rawSkill like '%lore%teneb%'
		or rawSkill like '%lore%moun%'
		or rawSkill like '%lore%six d%'
		or rawSkill like '%lore%swanw%'
		or rawSkill like '%lore%assass%'
		or rawSkill like '%lore%suffer%'
		or rawSkill like '%lore%blood so%'
		or rawSkill like '%lore%catacom%' 
		or rawSkill like '%lore%magic%the%' 
		or rawSkill like '%lore%ruins of p%' 
		or rawSkill like '%lore%souls%' 
		or rawSkill like '%lore%thinni%' 
		or rawSkill like '%lore%treatis%' 
		or rawSkill like '%lore%world%tree%faith%' 


--select * from #rLores order by 1--inspected, they are all there, but what a mess
update #rlores set cleanLore=replace(cleanLore,'R Lore','R. Lore')
update #rlores set cleanLore=replace(cleanLore,'R.Lore','R. Lore')
update #rlores set cleanLore=replace(cleanLore,'Lore','R. Lore') where cleanLore like 'Lore:%'
select distinct cleanLore from #rLores--19 is correct

--update C:\characterSheetReader\sql\fn cleanRawEventName.sql


--determine delta between this build and last build
drop table if exists #thisBuildEvent
;with cte as (select * from rawEvents where eventName like '%event 89%')
	,cte2 as (select *,dbo.cleanRawEventName(e.eventName,e.eventDate) cleanEventName from cte e)
	select c.* into #thisBuildEvent 
		from cte2 c
		join rawCPData cp on cp.characterId=c.characterId
		where cleanEventName='Event 89 February 2026'--659

drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterId=e.characterId
		join #rLores r on r.lore=s.rawSkill
--394

drop table if exists #lastBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,c.characterId
	into #lastBuild 
	from postJan26.rawSkills s 
		join postJan26.rawCPdata c on c.characterId=s.characterId
		join #rLores r on r.lore=s.rawSkill
--578

--this query shows the difference (so far in load)
drop table if exists #work
select *
	into #work
	from #thisBuild t
	where not exists (select null from #lastBuild l where l.characterId=t.characterId and l.cleanLore=t.cleanLore)
	order by 2
	--33

--exclude character that did NOT attend last-last event (i.e. Jan26)
select * from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 88%')
--smelled this, and looks right
delete w from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 88%')--4

--smell test 5
select characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	--,convert(varchar(50),(select string_agg(spendReason, ', ') from anchorChangeLog a where w.playerName=a.playerName and a.eventType='S' and a.eventName='Event 88 January 2026')) spendReasons
	from #work w
	order by newid()
--8GAX9	David Williams	R. Lore: Hydrology --this isn't lining up
--postJan26.rawSkills where characterId='8GAX9' and rawSkill like '%hy%'--he didn't have it
--postDec25.rawSkills where characterId='8GAX9' and rawSkill like '%hy%'--he didn't have it

select characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	from #work w
	order by playerName



/*
characterId playerName                                         cleanLore                                          spendReasons
----------- -------------------------------------------------- -------------------------------------------------- --------------------------------------------------
7YBNR       Aaron Roth                                         R. Lore: Aethermancy                               NULL
8YARE       Adriana Beals                                      R. Lore: Swanwall                                  NULL
7BKVK       Alexandria Wolf                                    R. Lore: Aethermancy                               NULL
7DZ9B       Ash Luna                                           R. Lore: Six Dragons                               NULL
7AQDN       Brian Williams                                     R. Lore: Mountain Meets the Sky                    NULL
7AQDN       Brian Williams                                     R. Lore: Swanwall                                  NULL
8A6NQ       Caleb Medchill                                     R. Lore: Six Dragons                               NULL
86RD6       Cameron Chado                                      R. Lore: Assassin's Arts                           NULL
7K4PR       Casper Torres                                      R. Lore: Lithoturgy                                NULL
8GD9J       Chris Montgomery                                   R. Lore: School of Suffering                       NULL
8GGZM       Colt Hallam                                        R. Lore: Ruins of Port Frey                        NULL
8GAX9       David Williams                                     R. Lore: Hydrology                                 Hydrology
8GAPM       Dylan Johnson                                      R. Lore: World Tree Faith                          NULL
7YZJ6       Emile Brammer                                      R. Lore: Treatise Methodologies                    NULL
84DVJ       Gil Ramirez                                        R. Lore: Ruins of Port Frey                        NULL
7WNPB       Hayley Ruttenberg                                  R. Lore: World Tree Faith                          NULL
8BVAZ       Jackie Salow-Wiley                                 R. Lore: Mountain Meets the Sky                    NULL
76QD5       James McCloskey                                    R. Lore: Lucenturgy                                Treatise Methodologies
8VMRP       Jenn Hynum                                         R. Lore: Aethermancy                               NULL
8DMRY       Jennifer Klasing                                   R. Lore: Pyromancy                                 NULL
7RK5Y       Jeremy Fariss                                      R. Lore: Blood Sommelier                           NULL
7RK5Y       Jeremy Fariss                                      R. Lore: Hydrology                                 NULL
7E9GR       Josh Sandoval                                      R. Lore: Pyromancy                                 NULL
8PQVW       Katt Jean                                          R. Lore: Six Dragons                               NULL
8EJA6       Leah Rosenbaum                                     R. Lore: Lucenturgy                                NULL
7ZZAQ       Matthew Erickson                                   R. Lore: Pyromancy                                 NULL
8QYG9       Melissa Melendez                                   R. Lore: Six Dragons                               NULL
8QYG9       Melissa Melendez                                   R. Lore: Tenebrimancy                              NULL
8QDXY       Nicholas Lippert                                   R. Lore: Treatise Methodologies                    NULL
8QDXY       Nicholas Lippert                                   R. Lore: Tenebrimancy                              NULL
7W65D       Nick Kinzel                                        R. Lore: Pyromancy                                 NULL
8BZ4R       Nicole Hunsicker (Nyx)                             R. Lore: School of Suffering                       Lithoturgy
8BZ99       Nicole Hunsicker (Nyx)                             R. Lore: World Tree Faith                          Lithoturgy
8QD4Y       Olivia Lizardo                                     R. Lore: Treatise Methodologies                    NULL
7EQQY       Reuben Bresler                                     R. Lore: Ruins of Port Frey                        Aetherturgy, Aethermancy
8GGRM       Rose Kochanek                                      R. Lore: Ruins of Port Frey                        NULL
8JG5P       Roxanna White                                      R. Lore: Lithoturgy                                NULL
8W6AZ       Sebastian della Gatta                              R. Lore: Hydrology                                 NULL
8W6AZ       Sebastian della Gatta                              R. Lore: Lucenturgy                                NULL
8W6AZ       Sebastian della Gatta                              R. Lore: Six Dragons                               NULL
8K4R9       Shoshi Kinzel                                      R. Lore: Blood Sommelier                           NULL
8K4R9       Shoshi Kinzel                                      R. Lore: Hydrology                                 NULL
7V6ME       Steven Calise                                      R. Lore: Blood Sommelier                           NULL

*/

--manually identify and delete staff
delete #work where playerName in ('Brian Kibler','Chris Montgomery','Hans Kreiswirth','Nicholas Lippert','Scooter Harper','PJ Williams','Olivia Lizardo','Jeremy Fariss','Caleb Medchill','Gil Ramirez')--5

--manually identify and delete npc trained
delete #work where playerName in ('Hayley Ruttenberg','Nicole Hunsicker (Nyx)', 'Dylan Johnson') and cleanLore='R. Lore: World Tree Faith'
delete #work where playerName in ('Casper Torres','Roxanna White') and rawSkill='R. Lore: Lithoturgy'--clove andilet and grant (both decimals) got lithoturgy



drop table if exists #spendReasons
select distinct spendReason into #spendReasons from anchorchangeLog where eventType='S'
select * from #work w where not exists (select null from #spendReasons s where replace(w.cleanLore,'R. Lore: ','')=s.spendReason)
--R. Lore: Blood Sommelier only, which will get inserted as a first timer now

--check for already entered
select playerName,null email,getdate() as timestamp,'S' eventType,'Event 89 February 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	--,-1 pointChange,'merged 20260325' sourceFile
	, characterId
		from #work w
		where exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))
--David Williams	NULL	2026-03-25 06:51:45.880	S	Event 89 February 2026	Hydrology	-1	merged 20260325	8GAX9
select * from anchorChangeLog where playerName='David Williams'--Event 88 January 2026 Hydrology -- I thought so, just his paperwork was later for going into feb26




insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,spendReason,pointChange,sourceFile,characterId)
	select playerName,null email,getdate() as timestamp,'S' eventType,'Event 89 February 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	,-1 pointChange,'merged 20260325' sourceFile, characterId
		from #work w
		where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--20


exec buildAnchorPointSheet

--more negatives than I expected

select * from anchorChangeLog where playerName in ('Reuben Bresler','Jenn Hynum','Rose Kochanek') order by 2
delete anchorChangeLog where id=1285
select * from anchorChangeLog where playerName like '%hynum%'--Aethermancy picked up in Feb26
