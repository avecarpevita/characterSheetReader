use tm


/*
note, I'm comparing builds/snapshots -- so if sheets are late, it PROBABLY still works
*/

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
;with cte as (select * from rawEvents where eventName like '%event 93%')
	,cte2 as (select *,dbo.cleanRawEventName(e.eventName,e.eventDate) cleanEventName from cte e)
	select c.* into #thisBuildEvent 
		from cte2 c
		join rawCPData cp on cp.characterId=c.characterId
		where cleanEventName='Event 93 September 2026'--673 this time -- which smells right from the analysis

		--#thisBuild where characterId='/'
drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterId=e.characterId
		join #rLores r on r.lore=s.rawSkill
--475


drop table if exists #lastBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,c.characterId
	into #lastBuild 
	from postJul26.rawSkills s 
		join postJul26.rawCPdata c on c.characterId=s.characterId
		join #rLores r on r.lore=s.rawSkill
--692

--this query shows the difference (so far in load)
drop table if exists #work
select *
	into #work
	from #thisBuild t
	where not exists (select null from #lastBuild l where l.characterId=t.characterId and l.cleanLore=t.cleanLore)
	order by 2
	--16 smells right

--exclude character that did NOT attend last-last event (i.e. Jul26)
select * from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 92%')--1
--smelled this, and looks right
delete w from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 92%')--1


--manually identify and delete staff
delete #work where playerName in ('Brian Kibler','Chris Montgomery','Hans Kreiswirth','Nicholas Lippert','Scooter Harper','PJ Williams','Olivia Lizardo','Jeremy Fariss','Caleb Medchill','Gil Ramirez'
,'Zachary Davis','Marc Perel','David Dandridge','Tim Regan','Clint Worley','Richard Choi','Travers Capps')--3

--smell test 5
select top 5 characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	--,convert(varchar(50),(select string_agg(spendReason, ', ') from anchorChangeLog a where w.playerName=a.playerName and a.eventType='S' and a.eventName='Event 88 January 2026')) spendReasons
	from #work w
	order by newid()

/*
75Q46	Julius White	R. Lore: School of Suffering		--gtg
7GA99	Brady Heaton	R. Lore: Ruins of Port Frey			--gtg
8KGJM	Zach Stark	R. Lore: Pyromancy						--gtg
8XNXE	William Conti	R. Lore: The Assassin's Arts		--gtg
7BKVK	Alexandria Wolf	R. Lore: Hydrology					--gtg
*/





--select * from anchorChangeLog where characterId='8MG4R'--
--select top 100 * from postMay26.rawSkills where characterId='8MG4R'
--select top 100 * from postFeb26.rawSkills where characterId='8MG4R'

--select * from anchorChangeLog where characterId='7ARG6'--
--select top 100 * from postMay26.rawSkills where characterId='7ARG6'
delete w from #work w
	where exists (select null from postJul26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)--0
delete w from #work w
	where exists (select null from postMay26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)--0
delete w from #work w
	where exists (select null from postApr26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)--0
delete w from #work w
	where exists (select null from postFeb26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)--0
delete w from #work w
	where exists (select null from postJan26.rawSkills r where r.characterId=w.characterId and r.rawSkill=w.rawSkill)--0

select * from #work


--manually identify and delete npc trained
delete #work where playerName in ('Ashley Jones') and rawSkill in ('R. Lore: Blood Sommelier','R. Lore: Souls','R. Lore: Tenebrimancy')--3


--make sure spendReason is clean
drop table if exists #spendReasons
select distinct spendReason into #spendReasons from anchorchangeLog where eventType='S'
select * from #work w where not exists (select null from #spendReasons s where replace(w.cleanLore,'R. Lore: ','')=s.spendReason)
select * from anchorChangeLog where spendReason like '%theory%' --new spends on this


--check for already entered
select playerName,null email,getdate() as timestamp,'S' eventType,'Event 93 September 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	--,-1 pointChange,'merged 20260325' sourceFile
	, characterId
		from #work w
		where exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--0





insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,spendReason,pointChange,sourceFile,characterId)
	select playerName,null email,getdate() as timestamp,'S' eventType,'Event 93 September 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	,-1 pointChange,'manual 20261109' sourceFile, characterId
		from #work w
		where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--12


exec buildAnchorPointSheet--probably has to run in another window with 




select top 100 * from anchorChangeLog where characterId in ('8YJ9B','7V6ME')

delete anchorChangeLog where id=3028
update a	
	set characterId='7V6ME',playerName='Steven Calise'
	from anchorChangeLog a where id=3027
