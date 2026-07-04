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
		or rawSkill like '%lore%sky%'
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

--determine delta between this build and last build
--only include people who PLAYED in last event
--you WILL need to update the function C:\characterSheetReader\sql\fn cleanRawEventName.sql
drop table if exists #thisBuildEvent
;with cte as (select * from rawEvents where eventName like '%event 91%')
	,cte2 as (select *,dbo.cleanRawEventName(e.eventName,e.eventDate) cleanEventName from cte e)
	select c.* into #thisBuildEvent 
		from cte2 c
		join rawCPData cp on cp.characterId=c.characterId
		where cleanEventName='Event 91 May 2026'--631 smells right

		--#thisBuild where characterId='/'
drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterId=e.characterId
		join #rLores r on r.lore=s.rawSkill
--447

drop table if exists #lastBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,c.characterId
	into #lastBuild 
	from postApr26.rawSkills s 
		join postApr26.rawCPdata c on c.characterId=s.characterId
		join #rLores r on r.lore=s.rawSkill
--641

--this query shows the difference (so far in load)
drop table if exists #work
select *
	into #work
	from #thisBuild t
	where not exists (select null from #lastBuild l where l.characterId=t.characterId and l.cleanLore=t.cleanLore)
	order by 2
	--38 smells right

--exclude character that did NOT attend last-last event (i.e. Jan26)
select * from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 90%')
--smelled this, and looks right
delete w from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 90%')--0

--smell test 5
select top 5 characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	--,convert(varchar(50),(select string_agg(spendReason, ', ') from anchorChangeLog a where w.playerName=a.playerName and a.eventType='S' and a.eventName='Event 88 January 2026')) spendReasons
	from #work w
	order by newid()

characterId playerName                                         cleanLore
----------- -------------------------------------------------- --------------------------------------------------
7PJ5G       Madeleine Mason                                    R. Lore: Ruins of Port Frey			--Jason added  6.15
8AR46       Ryan Leonard                                       R. Lore: Tenebrimancy				--katie added 6/29
8GD9J       Chris Montgomery                                   R. Lore: Lucenturgy					--Jason added  5.28
8MG4R       Pavana Somisetty                                   R. Lore: Lucenturgy					--mistake, Pavana had the load error in Apr
7ARG6       Catherine Crain                                    R. Lore: Lucenturgy					--jason added 6.16


select * from anchorChangeLog where characterId='8MG4R'--
select top 100 * from postApr26.rawSkills where characterId='8MG4R'
select top 100 * from postFeb26.rawSkills where characterId='8MG4R'

select * from anchorChangeLog where characterId='7ARG6'--
select top 100 * from postApr26.rawSkills where characterId='7ARG6'


delete w from #work w
	where exists (select null from postFeb26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)
delete w from #work w
	where exists (select null from postJan26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)

select * from #work

--manually identify and delete staff
delete #work where playerName in ('Brian Kibler','Chris Montgomery','Hans Kreiswirth','Nicholas Lippert','Scooter Harper','PJ Williams','Olivia Lizardo','Jeremy Fariss','Caleb Medchill','Gil Ramirez'
,'Zachary Davis','Marc Perel','David Dandridge','Tim Regan','Clint Worley')--3
--manually identify and delete npc trained
delete #work where playerName in ('Ashley Jones') and rawSkill in ('R. Lore: Blood Sommelier','R. Lore: Souls','R. Lore: Tenebrimancy')--3


--make sure spendReason is clean
drop table if exists #spendReasons
select distinct spendReason into #spendReasons from anchorchangeLog where eventType='S'
select * from #work w where not exists (select null from #spendReasons s where replace(w.cleanLore,'R. Lore: ','')=s.spendReason)
select * from anchorChangeLog where spendReason like '%soul%' or spendReason like '%thin%'--new spends on these


--check for already entered
select playerName,null email,getdate() as timestamp,'S' eventType,'Event 89 February 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	--,-1 pointChange,'merged 20260325' sourceFile
	, characterId
		from #work w
		where exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--0





insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,spendReason,pointChange,sourceFile,characterId)
	select playerName,null email,getdate() as timestamp,'S' eventType,'Event 91 May 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	,-1 pointChange,'merged 20260703' sourceFile, characterId
		from #work w
		where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--28


exec buildAnchorPointSheet--probably has to run in another window with 

--more negatives than I expected

select * from anchorChangeLog where playerName in ('Reuben Bresler','Jenn Hynum','Rose Kochanek') order by 2
delete anchorChangeLog where id=1285
select * from anchorChangeLog where playerName like '%hynum%'--Aethermancy picked up in Feb26
