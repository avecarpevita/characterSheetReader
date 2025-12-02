use tm

--select top 100 * from sys.tables order by create_date desc--rawCpData
--select distinct ticketType from tickets order by 1
--select distinct ticketType from tickets order by 1

--select eventName,count(*) from tickets where ticketType like '%NEW PLAYER%' group by eventName order by 1

drop table if exists #np
select distinct eventName,eventDate,rawPlayerName,playerName into #np from tickets where ticketType like '%NEW PLAYER%' --132

drop table if exists #npEvents
select np.eventName npEventName, np.eventDate npEventDate,np.rawPlayerName,np.playerName
	,r.characterName,dbo.getEventName(r.eventName,r.eventDate) eventName
	,dbo.getEventDate(r.eventName,r.eventDate) eventDate
	into #npEvents
	from #np np
		left join rawEvents r on r.playerName=np.playerName 

--clean up non events
delete #npEvents where eventName is null
--delete duplicates by player (i.e. alts)
;with cte as (select *,row_number() over(partition by playerName,eventName order by characterName) rn from #npEvents) 
	delete cte where rn>1
--delete tickets matching to impossible (i.e. tickets bought by somebody else) 		
--select * from #npEvents where eventDate<npEventDate--23
delete #npEvents where playerName in (select playerName from #npEvents where eventDate<npEventDate)--29

--at this point, we have indication they turned in a sheet that matched their ticket (which is dicey)
--select * from #npEvents

drop table if exists #agg
select npEventName,npEventDate,playerName
	,count(distinct eventName) totalEvents
	into #agg
	from #npEvents
	group by npEventName,npEventDate,playerName

select npEventName,npEventDate,count(*) newPlayerCount
	,sum(case when totalEvents>=1 then 1 else 0 end) played1p
	,sum(case when totalEvents>=2 then 1 else 0 end) played2p
	,sum(case when totalEvents>=3 then 1 else 0 end) played3p
	,sum(case when totalEvents>=4 then 1 else 0 end) played4p
	,sum(case when totalEvents>=5 then 1 else 0 end) played5p
	from #agg
	group by npEventName,npEventDate order by 2

	

--how about just using rawEvents
select top 100 *
	,dbo.getEventName(r.eventName,r.eventDate) eventName
	,dbo.getEventDate(r.eventName,r.eventDate) eventDate
	from rawEvents r where eventName like '%event%'

drop table if exists #work
select characterName,playerName
	,dbo.getEventName(r.eventName,r.eventDate) eventName
	,convert(date,null) eventDate
	into #work
	from rawEvents r where eventName like '%event%'
update w 
	set w.eventDate=ed.eventDate
	from #work w join eventsWithDates ed on ed.eventName=w.eventName


drop table if exists #firstEvents
select w.playerName	
	,min(eventName) as firstEventName
	,(select top 1 eventName from eventsWithDates e where e.eventDate=max(w.eventDate)) as lastEventName
	,max(eventdate) as lastEventDate 
	,count(distinct eventName) totalEvents
	,convert(int,null) totalEventsIn8
	,max(spentCp) spentCP
	into #firstEvents
	from #work w
		left join rawCPData r on r.playerName=w.playerName
	group by w.playerName



select lastEventName,count(*) from #firstEvents group by lastEventName order by 1 desc



select firstEventName
	,count(*) playerCount
	,convert(numeric(3,1),round(avg(totalEvents*1.0),1)) avgTotalEvents
	,sum(case when totalEvents>=3 then 1 else 0 end) tier2Count
	--,sum(case when spentCP>=150 then 1 else 0 end) tier3Count
	--,sum(case when spentCP>=300 then 1 else 0 end) tier4Count
	--,sum(case when spentCP>=450 then 1 else 0 end) tier5Count
	--,sum(case when spentCP>=600 then 1 else 0 end) tier6Count
	,sum(case when totalEvents>=3 then 1.0 else 0 end)/count(*) retentionRate3GamesLifeTime
	,sum(case when totalEvents>=3 then 1.0 else 0 end)/count(*) retentionRate3GamesIn5
	
	from #firstEvents f
		where firstEventName>='Event 55 September 2021'
	group by firstEventName
	order by 1 desc


select lastEventName,lastEventDate,count(*) from #firstEvents 
	where totalEvents>=3
	group by lastEventName,lastEventDate order by lastEventDate desc


select * from #firstEvents where lastEventName='Event 75 March 2024' and totalEvents>=3 order by totalEvents desc

#firstEvents where playerName like '%atlas%'
#firstEvents where playerName like '%blair%'