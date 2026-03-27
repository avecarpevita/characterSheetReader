use tm

drop table if exists #crystal
create table #crystal (
	rawDate varchar(255)
	,playerName varchar(255)
	,characterName varchar(255)
	,topic varchar(max)
	,notes varchar(max)
	,crap1 varchar(max)
	,crap2 varchar(max)
	)
bulk insert #crystal from 'c:\charactersheetReader\influenceAndResearch\crystal.tsv' with(datafiletype='char')--1023
update #crystal set rawDate=ltrim(rtrim(rawDate))

drop table if exists #monthNames
SELECT distinct DATENAME(month, try_cast(eventDate as date)) AS [monthName] 
	,datepart(month,try_cast(eventDate as date)) as monthNum
	into #monthNames from rawEvents where try_cast(eventDate as date) is not null
select * from #monthNames order by 2

--select rawDate,count(*) from #crystal group by rawDate
drop table if exists #work
select *
	,case when try_cast(rawDate as date) is not null then try_cast(rawDate as date) 
		when left(rawDate,3) in ('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')
			then try_cast('20'+right(rawDate,2)+'/'+
			(select top 1 right('0'+convert(varchar,monthNum),2) from #monthNames mn where left(mn.[monthName],3)=left(w.rawDate,3)) 
			+'/01'
			as date)
		else null end as gameDate
	,convert(varchar(255),null) eventName
	,convert(varchar(255),'Open-Ended Research') actionType
	,convert(varchar(4000),null) cleanTopic
	into #work
	from #crystal w
delete #work where gameDate is null
update #work set eventName=dbo.getEventName(null , gameDate)
	,cleanTopic=case when topic like '%:%' then left(topic,patindex('%:%',topic)-1) else null end
update #work set eventName=case when rawDate='Feb 26' then 'Event 89 February 2026' 
	when rawDate='Nov 23' then 'Event 72 October 2023' else null end
	where eventName is null
--eventsWithDates order by 2 desc
update #work set cleanTopic=replace(cleanTopic,'/HP','')

--#work order by gameDate desc

update w
	set w.actionType=case when cleanTopic not like '%research%' then CleanTopic
	else 'Open-Ended Research' end
	
	from #work w where actionType='Open-Ended Research'


select actionType,count(*) from #work 
	where eventName='Event 89 February 2026'
	group by actionType order by 1


select actionType,count(*) from #work 
	where eventName like 'Event % 202[5/6]'
	group by actionType order by 1

select actionType,count(*) from #work 
	where eventName like 'Event % 202[5/6]'
	group by actionType order by 2 desc

drop table if exists #actionTypes
create table #actionTypes (
	[action] varchar(255)
	,actionCount int
	,modRequest varchar(20)
	,actionType varchar(20)
	)
bulk insert #actionTypes from 'c:\charactersheetReader\influenceAndResearch\actionTypes.tsv' with(datafiletype='char',firstrow=2)--1023

select actionType,sum(actionCount) from #actionTypes group by actionType order by 2 desc

actionType           totalActions_2025&2026
-------------------- -----------
Political            113					--I can address this with ?
											--hexcrawl phase 4, but that is a long way away
Underworld           94						--I can address this with R. Lore Smuggling
Academic             54			--I can address this with R. Lore Magic Theory/Soul
		
Military             47			--hitting this hard with hexcrawl
Economic             22			--hitting this hard with hexcrawl


n/a	148	--these are open-ended research

RESTRICTED LORE: BARGAINS AND CONTRACTS		--economic (but it's a stretch!)	
RESTRICTED LORE: DEMONIC ETIQUETTE			--political		
												--short term, could relate to expensive actions to war of fire
												--I'm not sure what that would be?  
												--Inside information?
												--influence (or delay) attacks on the roots (at the expense of speeding them up elsewhere)



RESTRICTED LORE: SMUGGLING					--underworld
											--I need to write the lore doc
											--spend 50 UW to get X rank 50-70 ranks of tags (all the same time) the next event
												--delivery will be by npc, you'll need to provide availability for a two-hour window
												--poignant with glass
											--this is the test bed to do something with Demonic Etiquette
												

RESTRICTED LORE: GUERILLA WARFARE			--military
											--I could writ et
RESTRICTED LORE: BLOOD SOMMELIER			--academic 

