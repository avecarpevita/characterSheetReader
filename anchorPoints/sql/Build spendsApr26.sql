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
--only include people who PLAYED in last event
--you WILL need to update the function C:\characterSheetReader\sql\fn cleanRawEventName.sql
drop table if exists #thisBuildEvent
;with cte as (select * from rawEvents where eventName like '%event 90%')
	,cte2 as (select *,dbo.cleanRawEventName(e.eventName,e.eventDate) cleanEventName from cte e)
	select c.* into #thisBuildEvent 
		from cte2 c
		join rawCPData cp on cp.characterId=c.characterId
		where cleanEventName='Event 90 April 2026'--659

		--#thisBuild where characterId='/'
drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterId=e.characterId
		join #rLores r on r.lore=s.rawSkill
--390

drop table if exists #lastBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,c.characterId
	into #lastBuild 
	from postFeb26.rawSkills s 
		join postFeb26.rawCPdata c on c.characterId=s.characterId
		join #rLores r on r.lore=s.rawSkill
--611

--this query shows the difference (so far in load)
drop table if exists #work
select *
	into #work
	from #thisBuild t
	where not exists (select null from #lastBuild l where l.characterId=t.characterId and l.cleanLore=t.cleanLore)
	order by 2
	--31

--exclude character that did NOT attend last-last event (i.e. Jan26)
select * from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 89%')
--smelled this, and looks right
delete w from #work w
	where not exists (select null from rawEvents e where e.characterName=w.characterName and e.playerName=w.playerName and eventName like '%event 89%')--0

--smell test 5
select characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	--,convert(varchar(50),(select string_agg(spendReason, ', ') from anchorChangeLog a where w.playerName=a.playerName and a.eventType='S' and a.eventName='Event 88 January 2026')) spendReasons
	from #work w
	order by newid()


select * from rawCPData where playerName='Ashley Jones'--characterId is "\    " somehow

characterId playerName                                         cleanLore
----------- -------------------------------------------------- --------------------------------------------------
8E4XE       Nicholas Marko                                     R. Lore: Swanwall					--edit was March 30, so checks out?		
	select top 100 * from anchorChangeLog where characterId='8E4XE'--no spend for Swanwall
7KAQM       Adrianna Miller                                    R. Lore: Lithoturgy					--edit was March 24, so checks out
	select top 100 * from anchorChangeLog where characterId='7KAQM'--no spend for Lithoturgy
8Z45M       Natasha Hayes                                      R. Lore: Aethermancy					--edit was March 24, so checks out
	select top 100 * from anchorChangeLog where characterId='8Z45M'--no spend for Aethermancy
	select top 100 * from anchorChangeLog where playerName='Natasha Hayes'
8ARW6       Alyse Sherrick                                     R. Lore: World Tree Faith			--edit was April 18, so checks out
	select top 100 * from anchorChangeLog where characterId='8ARW6'--no spend for World Tree Faith
8RYYE       Joshua Warner                                      R. Lore: Mountain Meets the Sky		--edit was March 24, so checks out
		select top 100 * from anchorChangeLog where characterId='8RYYE '--no spend for MMTS
8V9XX       Hunter Terry                                       R. Lore: Treatise Methodologies		--edit was May 6, so checks out
		select top 100 * from anchorChangeLog where characterId='8V9XX '--no spend for treatise

select top 100 * from anchorChangeLog where playerName='Ashley Jones'--

select characterId,convert(varchar(50),playerName) playerName,convert(varchar(50),cleanLore) cleanLore
	from #work w
	order by playerName

	
\    	Ashley Jones	R. Lore: Blood Sommelier		--remove these, they don't check out, I think she predates
\    	Ashley Jones	R. Lore: Souls
\    	Ashley Jones	R. Lore: Tenebrimancy

de



/*characterId playerName                                         cleanLore
----------- -------------------------------------------------- --------------------------------------------------
7KAQM       Adrianna Miller                                    R. Lore: Lithoturgy
7946G       Akash Canjels                                      R. Lore: Aethermancy
7946G       Akash Canjels                                      R. Lore: School of Suffering
8ARW6       Alyse Sherrick                                     R. Lore: World Tree Faith
7RZEV       Andrew Buczacki                                    R. Lore: Lithoturgy
8M4WB       Andrew Cunado                                      R. Lore: Swanwall
8M9NJ       Andrew Frejek                                      R. Lore: Tenebrimancy
\           Ashley Jones                                       R. Lore: Blood Sommelier
\           Ashley Jones                                       R. Lore: Souls
\           Ashley Jones                                       R. Lore: Tenebrimancy
7JJ4W       Caleb Sapa                                         R. Lore: World Tree Faith
7VQ5Y       David Dandridge                                    R. Lore: Lithoturgy
8W6NZ       Eric Brittain                                      R. Lore: Swanwall
8V9XX       Hunter Terry                                       R. Lore: Treatise Methodologies
T0245       James Medina                                       R. Lore: Treatise Methodologies
8AQ6N       Jason Baxter                                       R. Lore: Lithoturgy
8AQ6N       Jason Baxter                                       R. Lore: World Tree Faith
8RV95       John Charles Schmerker                             R. Lore: Mountain Meets the Sky
74XGQ       John Queenan                                       R. Lore: Tenebrimancy
8RYYE       Joshua Warner                                      R. Lore: Mountain Meets the Sky
8EJA6       Leah Rosenbaum                                     R. Lore: Treatise Methodologies
7KG4D       Malia Mislan                                       R. Lore: Blood Sommelier
7BKME       Marc Perel                                         R. Lore: Ruins of Port Frey
8QYG9       Melissa Melendez                                   R. Lore: Pyromancy
8B9P9       Michael Butler                                     R. Lore: Lithoturgy
8Z45M       Natasha Hayes                                      R. Lore: Aethermancy
8Z45M       Natasha Hayes                                      R. Lore: Ruins of Port Frey
8E4XE       Nicholas Marko                                     R. Lore: Swanwall
7YQAE       Rowan Norenberg                                    R. Lore: Treatise Methodologies
79DBG       Trevor West                                        R. Lore: Swanwall
74D6R       Zachary Davis                                      R. Lore: Swanwall

*/

--manually identify and delete staff
delete #work where playerName in ('Brian Kibler','Chris Montgomery','Hans Kreiswirth','Nicholas Lippert','Scooter Harper','PJ Williams','Olivia Lizardo','Jeremy Fariss','Caleb Medchill','Gil Ramirez'
,'Zachary Davis','Marc Perel','David Dandridge')--3
--manually identify and delete npc trained
delete #work where playerName in ('Ashley Jones') and rawSkill in ('R. Lore: Blood Sommelier','R. Lore: Souls','R. Lore: Tenebrimancy')--3


select * from anchorchangeLog where spendReason like '%suff%'
update a
	set spendReason='School of Suffering'
	from anchorChangeLog a where  spendReason like '%suff%'

drop table if exists #spendReasons
select distinct spendReason into #spendReasons from anchorchangeLog where eventType='S'
select * from #work w where not exists (select null from #spendReasons s where replace(w.cleanLore,'R. Lore: ','')=s.spendReason)
--R. Lore: World Tree Faith is new

--check for already entered
select playerName,null email,getdate() as timestamp,'S' eventType,'Event 89 February 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	--,-1 pointChange,'merged 20260325' sourceFile
	, characterId
		from #work w
		where exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))
--David Williams	NULL	2026-03-25 06:51:45.880	S	Event 89 February 2026	Hydrology	-1	merged 20260325	8GAX9
select * from anchorChangeLog where playerName='Andrew Cunado' and spendReason='Swanwall'
select * from anchorChangeLog where playerName='Eric Brittain' and spendReason='Swanwall'

delete #work where playerName in ('Andrew Cunado','Eric Brittain') and cleanLore like '%Swanwall%'






insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,spendReason,pointChange,sourceFile,characterId)
	select playerName,null email,getdate() as timestamp,'S' eventType,'Event 90 April 2026' eventName
	, replace(w.cleanLore,'R. Lore: ','') spendReason
	,-1 pointChange,'merged 20260507' sourceFile, characterId
		from #work w
		where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=replace(w.cleanLore,'R. Lore: ',''))--20


exec buildAnchorPointSheet

--more negatives than I expected

select * from anchorChangeLog where playerName in ('Reuben Bresler','Jenn Hynum','Rose Kochanek') order by 2
delete anchorChangeLog where id=1285
select * from anchorChangeLog where playerName like '%hynum%'--Aethermancy picked up in Feb26
