use tm

drop table if exists #work
;with cte as (
select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,dbo.cleanRawEventName(e.eventName,e.eventDate) eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	,(select count(*) from rawEvents ri where c.playerName=ri.playerName and c.characterName=ri.characterName and ri.eventName like '%event%') numEvents
	,culture,religion,bloodline,[ip]
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		)
select * 
		,dbo.cleanRawReligion(religion) cleanReligion
	into #work from cte
		where eventName is not null


drop table if exists #deduped
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case 
		when spentCP between 1 and 149 and numEvents<3 then '[tier 1] 0-2 games'
		when spentCP between 1 and 149 then '[tier 2] 3+ games, under 150 CP'
		when spentCp between 150 and 300 then '[tier 3] 150-300 CP'
		when spentCp between 301 and 450 then '[tier 4] 301-450 CP'
		when spentCp between 451 and 600 then '[tier 5] 451-600 CP'
		when spentCp>=601 then '[tier 6] 601+ CP' end as cpGrouping

		into #deduped from cte where rn=1
--dedupe to player
;with cte as (select *,row_number() over(partition by playerName order by spentCP desc) rn2 from #deduped) delete cte where rn2>1
create unique clustered index cp on #deduped(playerName) --unique to players

rawSkills where rawSkill like '%priest%'

select * from #deduped x
	where cleanReligion like '%mandala%'
	and exists (select null from rawSkills s where s.characterName=x.characterName and s.playerName=x.playerName
		and s.rawSkill like '%priest%')
	--and exists (select null from rawSkills s where s.characterName=x.characterName and s.playerName=x.playerName
	--	and s.rawSkill like '%mandala%faith%')
	order by eventDate desc,spentCp desc

playerName                                  characterName                                                                                        
------------------------------------------- -------------------------------------------------
Alice Tsai                                  Alleria Kibou                                                                                        
Nathaniel Choi                              Jayeon                                                                                               
Nicholas Tucker                             Mogee Maleeg                                                                                         
Steven Maus                                 Sagar Proudeyes                                                                                      
Matthew Chaisson                            Vahn Matsu                                                                                           
Bradley West                                Bryndon (Brynn) McAllister                                                                           

select dateadd(day,10,getdate())

update #deduped set cleanReligion=dbo.cleanRawReligion(religion) where len(religion)>1
--in general, what is the religion breakdown on mains
select top 20 convert(varchar(35),cleanReligion) cleanReligion
	,count(*) totalMainCharacters
	,sum(case when eventDate>=dateadd(month,-6,getdate()) then 1 end) active6moMainCharacters
	from #deduped 
		where len(cleanReligion)>1
	group by cleanReligion order by 3 desc


select * from #work x
	where cleanReligion like '%world%'
	and exists (select null from rawSkills s where s.characterName=x.characterName and s.playerName=x.playerName
		and s.rawSkill like '%priest%')
	--and exists (select null from rawSkills s where s.characterName=x.characterName and s.playerName=x.playerName
	--	and s.rawSkill like '%mandala%faith%')
	order by eventDate desc,spentCp desc