use tm

select * from sys.tables order by 1 desc

rawLores
rawEvents
rawCpData


drop table if exists #lores
select *,dbo.cleanRawLore(rawLore) lore into #lores from rawLores with(nolock)
select lore
	,count(distinct characterName) 
	from #lores where lore is not null
	group by lore order by 2 desc

select * from #lores where lore like '%disease%'--only 8 characters with lore disease
	--active--Roji, Gaulten, Spider, Ferd

select * from #lores where lore like '%ardent%'--
select * from #lores where lore like '%choir%'--
select * from #lores where lore like '%chorus%'--23 have lore:church of chorus
select * from #lores where lore like '%inq%'--1 had lore inquisition


select * from #work where playerName='Anthony Menjivar'--hasn't played since April

--get characters played in the last three events
drop table if exists #work
;with cte_charactersLast3Games as (select c.playerName,c.characterName
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,case when eventName like '%event 84%' then 'Event 84 April 2025'
	when eventName like '%event 85%' then 'Event 85 August 2025'
	when eventName like '%event 86%' then 'Event 86 September 2025' 
	when try_cast(e.eventDate as date) between '2025.04.01' and '2025.04.30' then 'Event 84 April 2025'
	when try_cast(e.eventDate as date) between '2025.08.01' and '2025.08.31' then 'Event 85 August 2025'
	when try_cast(e.eventDate as date) between '2025.09.01' and '2025.09.30' then 'Event 85 September 2025'
		end eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		where eventName like '%event%'
			and (try_cast(e.eventDate as date) between '2025.04.01' and '2025.10.01'
			or eventName like '%event 8[456]%')
		)
select * 
	into #work from cte_charactersLast3Games
	

drop table if exists #jan26MyreAnchor
create table #jan26MyreAnchor (
	ntimestamp nvarchar(100)
	,realName nvarchar(255)
	,characterName nvarchar(255)
	,faction nvarchar(255)
	,boat nvarchar(255)
	,cp150Status nvarchar(255)
	)
bulk insert #jan26MyreAnchor from 'C:\characterSheetReader\sql\jan26MyreAnchor.tsv' with(datafiletype='char')

select realName,count(*) from #jan26MyreAnchor group by realName order by 2 desc
select * from #jan26MyreAnchor where realName in (select realName from #jan26MyreAnchor group by realName having count(*)>1)
;with cte as (select *,row_number() over(partition by realName order by ntimestamp desc) rn  from #jan26MyreAnchor) delete cte where rn>1

select convert(varchar(20),isnull(faction,'blank')) faction,count(distinct realName) players from #jan26MyreAnchor where isnull(faction,'') not like 'Which %' group by faction order by 1



select r.* 
	,j.realName+' '+j.characterName onMyreMod
	from rawSkills r
	left join #jan26MyreAnchor j on (r.characterName like left(ltrim(rtrim(j.characterName)),5)+'%' or r.playername=ltrim(rtrim(j.realName)))
	where rawSkill like '%chann%' and rawSkill not like '%lore%' and rawSkill like '%grand%'
	and exists (select null from #work w where w.characterName=r.characterName)
	order by case when j.characterName is not null then 0 else 1 end
		,characterName,playerName
	
	/* 6 GM channelers, so the call should be nasty, especially if they don't have the scroll already
Sifrid Payne			Jeremy Fariss
Macaria Faustus			Kelly Glaubig
Kaelan Estelmer			Kyle Duong
Kenrin Arakai			Chris Montgomery
Dame Sy'ah (Lady Luci)	Melissa (Meli) Sakrison
Aelynn					Alessandra Cruz-Putnam
*/


select convert(varchar(35),faction) faction
	,count(*) total
	,sum(case when cp150Status<>'Yes' then 1 else 0 end) sub150
	from #jan26MyreAnchor j
		where faction not like '%Which%'
		group by faction order by 1

select count(*) from #jan26MyreAnchor j
		where faction not like '%Which%' and cp150Status<>'Yes' 