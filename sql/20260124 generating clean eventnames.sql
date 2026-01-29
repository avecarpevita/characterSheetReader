drop table if exists #x
select *,eventDate as originalEventDate into #x from rawEvents where characterName in ('Shakes','Gaeden') and eventName like '%event%' 
update #x set eventName=replace(eventName,'/',' ')+' '
update #x
	set eventDate=replace(eventDate,'/','/01/')
	where try_cast(eventDate as date) is null
update #x
	set eventDate=replace(eventDate,'-','-01-')
	where try_cast(eventDate as date) is null
drop table if exists #x2
select eventName
	,eventDate
	,originalEventDate
	,ltrim(rtrim(left(replace(eventName,'event ',''),patindex('% %',replace(eventName,'event ',''))))) eventNum
	,'Event '+ltrim(rtrim(left(replace(eventName,'event ',''),patindex('% %',replace(eventName,'event ',''))))) cleanEventNameFront
	,DATENAME(month, try_cast(eventDate as date))+' '+convert(varchar(4),year(try_cast(eventdate as date))) cleanEventNameBack
	into #x2
	from #x

--select * from #x2 order by try_cast(eventDate as date)

select distinct try_cast(eventDate as date) as eventDate
	,cleanEventNameFront+' '+cleanEventNameBack 
	--first check
	,'when @eventName like ''%'+lower(cleanEventNameFront)+'%'' then '''+cleanEventNameFront+' '+cleanEventNameBack+''' '
	--second check
	,'when month(try_cast(@eventDate as date))='+convert(varchar,month(try_cast(eventDate as date)))+' 
		and year(try_cast(@eventDate as date))='+convert(varchar,year(try_cast(eventDate as date)))+' 
		then '''+cleanEventNameFront+' '+cleanEventNameBack+''' '
	from #x2 where try_cast(eventDate as date) > '2011.01.01'
		
	order by eventDate
