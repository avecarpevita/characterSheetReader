use tm

--select * from sys.schemas--postDec25

--[1] determine the r. lores I'm looking for
drop table if exists #rLores
create table #rLores (lore varchar(255) not null primary key clustered)
insert into #rLores 
select distinct rawSkill from rawSkills
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


select * from #rLores order by 1--inspected, they are all there, but what a mess

--update C:\characterSheetReader\sql\fn cleanRawEventName.sql


--determine delta between this build and last build
drop table if exists #thisBuildEvent
;with cte as (select * from rawEvents where eventName like '%event 88%')
	,cte2 as (select *,dbo.cleanRawEventName(e.eventName,e.eventDate) cleanEventName from cte e)
	select c.*,cp.characterId into #thisBuildEvent from cte2 c
		join rawCPData cp on cp.playerName=c.playerName and cp.characterName=c.characterName
		where cleanEventName='Event 88 January 2026'--682

drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterName=e.characterName and s.playerName=e.playerName
		join #rLores r on r.lore=s.rawSkill
--421

drop table if exists #lastBuild
select distinct s.characterName,s.playerName,s.rawSkill 
	into #lastBuild 
	from postDec25.rawSkills s 
		join #rLores r on r.lore=s.rawSkill
--537

--this query shows the difference (so far in load)
drop table if exists #work
select *
	into #work
	from #thisBuild t
	where not exists (select null from #lastBuild l where l.playerName=t.playerName and l.characterName=t.characterName and l.rawSkill=t.rawSkill)
	order by 2
	--49

select convert(varchar(50),playerName) playerName,convert(varchar(50),rawSkill) rawSkill
	,convert(varchar(50),(select string_agg(spendReason, ', ') from anchorChangeLog a where w.playerName=a.playerName and a.eventType='S' and a.eventName='Event 88 January 2026')) spendReasons
	from #work w
	order by playerName

/*
playerName                                         rawSkill                                           spendReasons
-------------------------------------------------- -------------------------------------------------- --------------------------------------------------
Aisling Gorgon                                     R. Lore: Assassin's Arts                           The Assassin's Arts
Alejandro Gonzalez                                 R. Lore: Pyromancy                                 Pyromancy
Alex Nicholson                                     R. Lore: The Assassin's Arts                       NULL						--teacher
Brady Heaton                                       R. Lore: Assassin's Arts                           The Assassin's Arts
Brian Kibler                                       R. Lore: Ruins of Port Frey                        NULL						--staff
Cassidy Collis                                     R. Lore: Catacombs                                 NULL--??
Cassidy Collis                                     R. Lore: Lucenturgy                                NULL	--select * from anchorChangeLog where playerName='Cassidy Collis'--1 point in Jan
Cassidy Collis                                     R. Lore: Treatise Methodologies                    NULL
Chris Montgomery                                   R. Lore: Aethermancy                               NULL--staff
Christopher Glenn Gilstrap                         R. Lore: Lithoturgy                                NULL	--select * from anchorChangeLog where playerName like '%gilstrap%'--nothing
Dean Jackman                                       R. Lore: Swanwall                                  NULL	--select * from anchorChangeLog where playerName like '%Jackman%'--nothing
Dominic Criscitiello                               R. Lore: Swanwall                                  Swanwall
Ember Doherty                                      R. Lore: Assassin's Arts                           The Assassin's Arts
Gillian Morris                                     R. Lore: Swanwall                                  Swanwall, Treatise Methodologies
Gillian Morris                                     R. Lore: Treatise Methodologies                    Swanwall, Treatise Methodologies
Hans Kreiswirth                                    R. Lore: The Assassin's Arts                       NULL--staff
Hera Dewan                                         R. Lore: Treatise Methodologies                    NULL --nada
Ivy Hazel                                          R. Lore: Assassin's Arts                           The School of Suffering, The Assassin's Arts
Ivy Hazel                                          R. Lore: School of Suffering                       The School of Suffering, The Assassin's Arts
Jack Thielman                                      R. Lore: treatise Methodologies                    Treatise Methodologies
Jade Peng                                          R. Lore: Treatise Methodologies                    NULL	--select * from anchorChangeLog where playerName like '%Peng%'--nothing
James McCloskey                                    R. Lore: Swanwall                                  Treatise Methodologies
James McCloskey                                    R. Lore: Treatise Methodologies                    Treatise Methodologies
James O'Neil                                       R. Lore: Assassin's Arts*                          NULL
Jerrod Hayes                                       R. Lore: School of Suffering                       The School of Suffering
John Charles Schmerker                             R. Lore: Swanwall                                  Swanwall
Justen Speratos                                    R. Lore: Ruins of Port Frey                        NULL
Justin Chan                                        R. Lore: Mountain Meets the Sky                    NULL
Kayla VanderStoel                                  R. Lore: Treatise Methodologies                    Treatise Methodologies
Keigin Tosh                                        R. Lore: Mountain Meets Sky                        Mountain Meets the Sky
Lily Thiemens                                      R. Lore: Swanwall                                  Treatise Methodologies
Lily Thiemens                                      R. Lore: Treatise Methodologies                    Treatise Methodologies
Maria Puig                                         R. Lore: Ruins of Port Frey                        Treatise Methodologies, Ruins of Port Frey
Maria Puig                                         R. Lore: Treatise Methodologies                    Treatise Methodologies, Ruins of Port Frey
Matthew Salus                                      R. Lore: Lithoturgy                                Lithoturgy
Matthew Salus                                      R. Lore: Mountain Meets Sky                        Lithoturgy
Michael Butler                                     R. Lore: Mountain Meets the Sky                    Mountain Meets the Sky
Nathanael Goodrich                                 R. Lore: Lucenturgy                                Lucenturgy
Nicholas Lippert                                   R. Lore: Treatise Methodologies                    NULL
Nick Williams                                      R. Lore: Six Dragons                               Six Dragons
Nicole Hunsicker (Nyx)                             R. Lore: Lithoturgy                                NULL
Noelle Volkmann                                    R.Lore: Tenebrimancy                               NULL
Pavana Somisetty                                   R. Lore: Treatise Methodologies                    Treatise Methodologies
PJ Williams                                        R. Lore: The Assassin's Arts                       NULL
Reuben Bresler                                     R. Lore: Aethermancy                               Aetherturgy
Ryan Leonard                                       R. Lore: Aethermancy                               Aetherturgy
Scooter Harper                                     R. Lore: Hydrology                                 NULL
Shaun Wada                                         R. Lore: School of Suffering                       The School of Suffering
Taylor Harrs                                       R. Lore: School of Suffering                       NULL

(49 rows affected)

*/

--manually identify and delete staff
delete #work where playerName in ('Brian Kibler','Chris Montgomery','Hans Kreiswirth','Nicholas Lippert','Scooter Harper','PJ Williams')--5

--manually identify and delete npc trained
delete #work where playerName='Alex Nicholson' and rawSkill='R. Lore: The Assassin''s Arts'
delete #work where playerName='Christopher Glenn Gilstrap' and rawSkill='R. Lore: Lithoturgy'--clove andilet and grant (both decimals) got lithoturgy


--order by 1
drop table if exists #work2
;with cte as (select distinct spendReason from anchorchangeLog where eventType='S')
select * 
	into #work2
	from #work w
		left join cte c on w.rawSkill like '%'+c.spendReason+'%'
update #work2 set spendReason=case when rawSkill like '%Assassin%' then 'The Assassin''s Arts'
	when rawSkill like '%Catacombs%' then 'Catacombs'
	when rawSkill like '%Suffering%' then 'The School of Suffering'
	when rawSkill like '%Mountain%' then 'Mountain Meets the Sky'
	when rawSkill like '%Tenebrimancy%' then 'Tenebrimancy'
	when rawSkill like '%Aethermancy%' then 'Aethermancy'
	when rawSkill like '%Lucent%' then 'Lucenturgy'
	else null end
	where spendReason is null

select * from #work2 w
	where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=w.spendReason)--these have to get merged in

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,spendReason,pointChange,sourceFile,characterId)
	select playerName,null email,getdate() as timestamp,'S' eventType,'Event 88 January 2026' eventName, spendReason,-1 pointChange,'merged 20260218' sourceFile, characterId
		from #work2 w
		where not exists (select null from anchorChangeLog a where a.playerName=w.playerName and a.eventType='S' and a.spendReason=w.spendReason)--15

--onetime
--delete anchorChangeLog where playerName='Jose Favela'--delete those
--delete anchorChangeLog where playerName='PJ Williams'

exec buildAnchorPointSheet

--select * from anchorChangeLog where characterId is null
--select * from anchorChangeLog where playerName like '%cassidy%'
declare @file varchar(255)='c:\anchorpoints\signupsFeb26.tsv'
declare @sql varchar(max)
drop table if exists #signupsRaw
create table #signupsRaw (
	timestamp varchar(255)
	,email nvarchar(255)
	,playerName nvarchar(255)
	,timeSlots varchar(1000)
	,check1 varchar(100)
	,check2 varchar(100)
	,plan1 varchar(255)
	,combat1 varchar(255)
	)
if @file not in ('c:\anchorpoints\signupsJan26.tsv','c:\anchorpoints\signupsDec25.tsv')
	begin
	
	alter table #signupsRaw drop column timeslots
	alter table #signupsRaw drop column check1
	alter table #signupsRaw drop column check2
	alter table #signupsRaw drop column plan1
	alter table #signupsRaw drop column combat1
	alter table #signupsRaw add characterId nvarchar(100)
	alter table #signupsRaw add timeslots nvarchar(1000)
	end


set @sql='bulk insert #signupsRaw from '''+@file+''' with(datafiletype=''char'',firstrow=2) '
print @sql; exec(@sql)

select top 100 * from #signupsRaw where playerName like '%cass%'
select top 100 * from anchorChangeLog where playerName like '%cass%'

select top 100 * from #signupsRaw where playerName like '%chris%'
select top 100 * from anchorChangeLog where playerName like '%chris%'

select top 100 * from #signupsRaw where playerName like '%hera%'
select top 100 * from anchorChangeLog where playerName like '%hera%'

select top 100 * from #signupsRaw where playerName like '%peng%'
select top 100 * from anchorChangeLog where playerName like '%peng%'

select top 100 * from #signupsRaw where playerName like '%james%'
select top 100 * from anchorChangeLog where playerName like '%james%'

select top 100 * from #signupsRaw where playerName like '%riley%'
select top 100 * from anchorChangeLog where playerName like '%riley%'

select top 100 * from #signupsRaw where playerName like '%tarb%'
select top 100 * from anchorChangeLog where playerName like '%tarb%'

select top 100 * from #signupsRaw where playerName like '%Philli%'
select top 100 * from anchorChangeLog where playerName like '%Philli%'
select top 100 * from #signupsRaw where playerName like '%Lancaste%'
select top 100 * from anchorChangeLog where playerName like '%Lancaste%'

select top 100 * from #signupsRaw where playerName like '%elche%'
select top 100 * from anchorChangeLog where playerName like '%elche%'

select top 100 * from #signupsRaw where playerName like '%Hunsic%'
select top 100 * from anchorChangeLog where playerName like '%Hunsic%'


select top 100 * from #signupsRaw where playerName like '%Volk%'
select top 100 * from anchorChangeLog where playerName like '%Volk%'