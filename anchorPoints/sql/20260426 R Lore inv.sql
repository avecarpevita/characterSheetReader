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
	select c.* 
		,cp.email
		into #thisBuildEvent 
		from cte2 c
		join rawCPData cp on cp.characterId=c.characterId
		where cleanEventName='Event 89 February 2026'--659

drop table if exists #thisBuild
select distinct s.characterName,s.playerName,s.rawSkill,r.cleanLore,e.characterId
	into #thisBuild 
	from rawSkills s join #thisBuildEvent e on s.characterId=e.characterId
		join #rLores r on r.lore=s.rawSkill
--394

create unique clustered index c on #thisBuild(characterId,cleanLore)

select * from #thisBuild

select distinct playername from #thisBuild--227 players out of 527