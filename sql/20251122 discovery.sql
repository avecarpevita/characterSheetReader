use tm
--select * from sys.tables

/*
DECLARE @json NVARCHAR(MAX);
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\characterSheets20250916\json\Fei Leung (Anziel).json', SINGLE_CLOB) AS j; 

SELECT book.*
FROM OPENJSON(@json)
WITH (
    playerName NVARCHAR(100)
    ,characterName NVARCHAR(100)
	,[events] nvarchar(max) '$.events' as JSON
	,[skills] nvarchar(max) '$.skills' as JSON
) AS book;
*/



--select * from rawLores with(nolock)
select rawLore,count(distinct characterName) from rawLores with(nolock) group by rawLore order by 2 desc

select distinct playerName from rawLores where playerName like 'Kelsey Daily%'

--need to process for
--double spaces, *, quotes, "restricted lore" normalized to R. Lore
--remove anything with "POK Lore"

drop table if exists #lores
select *,dbo.cleanRawLore(rawLore) lore into #lores from rawLores with(nolock)
select lore
	,count(distinct characterName) 
	from #lores where lore is not null
	group by lore order by 2 desc


select * from #lores where lore='Lore: : Demon'--Lore: Demon

--and then dump into this sheet
https://docs.google.com/spreadsheets/d/1Mm4u8ijQ20ado_d8-YTDiv05o5wS01PfoZ22p5Ilftc/

select * from #lores--dump this into a snapshot 


select * from rawCpData with(nolock)
select * from rawEvents with(nolock)

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
select * into #work from cte_charactersLast3Games

--select distinct rawEventName,eventName,rawEventDate,eventDate from #work--only two, since this is a snapshot that does not include September games
--select * from #work where eventDate is null--a few, but we'll live with it

select eventName,count(distinct playerName) playerCount,count(distinct characterName) characterCount from #work group by eventName order by 1


select distinct left(playerName,1) from #work order by 1 --only 24, incomplete -- no U, Uli hasn't played recently, as nobody recent with a Q either

--dedupe to latest event
drop table if exists #deduped
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventDate desc) rn from #work) 
	select * 
		,case when spentCP between 1 and 149 then '[1] under 150 CP'
		when spentCp between 150 and 300 then '[2] 150-300 CP'
		when spentCp between 301 and 450 then '[3] 301-450 CP'
		when spentCp between 451 and 600 then '[4] 451-600 CP'
		when spentCp>=601 then '[5] 601+ CP' end as cpGrouping

		into #deduped from cte where rn=1
--dedupe to player
;with cte as (select *,row_number() over(partition by playerName order by spentCP desc) rn2 from #deduped) delete cte where rn2>1
create unique clustered index cp on #deduped(playerName) --unique to players



--median/avg CP
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spentCP) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--
select avg(spentCp*1.0) from #deduped--




--corruption
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY corruption) OVER (PARTITION BY 1) AS MedianValue
FROM
    #deduped;		--median corruption is 1
select avg(corruption*1.0) from #deduped--avg is 1.5


--bands
select cpGrouping,count(*) numberOfMainCharacters
	,avg(corruption*1.0) avgCorruption
	,min(corruption) minCorruption,max(corruption) maxCorruption
	from #deduped group by cpGrouping order by 1

	
select * from #deduped where corruption>5


--I popped these into https://docs.google.com/spreadsheets/d/12FbiG3viVmbceeo0zyUV5Zn4GUtNY1RO8pOJdLzuLLw/edit?gid=0#gid=0