use tm

--[1] load the existing master sheet 
	--[https://docs.google.com/spreadsheets/d/1k7nJRc1OglY8B7dkddJlQeOo4hPL7Dq1Cp-ItnEREWI/edit?gid=0#gid=0]
	-- player level detttail, which is the system of record to be updated -- i.e. I manually update this sheet as the system of record

drop table if exists #master
create table #master (
	realName varchar(255) not null
	,characterName varchar(255) not null
	,style varchar(25) not null
	,practiceCount int not null
	,gameDetail varchar(4000) not null
	,rankEarned varchar(255) null
)
alter table #master add primary key clustered(realName,characterName,style)
bulk insert #master from 'C:\characterSheetReader\fightingStyles\masterSnapshot20260219.tsv' with(datafiletype='char',firstrow=4)

--make sure I see row 4
select top 100 * from #master where realName like 'adam camp%'

--[2] load the practices (Jan26 only) to determine adds to the master sheet
	--[https://docs.google.com/spreadsheets/d/1YE-w8_xgApOd9nh6FOo851ZJjkLhuj9RZtAdnRR4C-o/edit?gid=1431206453#gid=1431206453]
	--export as .tsv
	
drop table if exists #practicesToDateRaw
create table #practicesToDateRaw (
	[timestamp] datetime not null
	,email varchar(255) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,game varchar(255) not null
	,style varchar(255) not null
	,practiceWhen varchar(255) not null
	,oocRules varchar(4000) not null
	,participants varchar(8000) not null
	)
alter table #practicesToDateRaw add primary key clustered(game,style,realName,practicewhen)
bulk insert #practicesToDateRaw from 'C:\characterSheetReader\fightingStyles\practicesSnapshot2026219.tsv' with(datafiletype='char',firstrow=2)
--still got everything
delete #practicesToDateRaw where game='December 2025'--11

--[3]--note the max cutoff from #practicesToDate for future use
select * from #practicesToDateRaw order by [timestamp] desc--2026-01-29 14:49:34.000

--[4]--delete previous practices, and practices that did not complete oocRules
delete #practicesToDateRaw where [timestamp]<='1970.01.01'
select  * from #practicesToDateRaw 
	where (oocRules not like '%charging%'
	or oocRules not like '%Caution%'
	or oocRules not like '%Flurry%'
	or oocRules not like '%Parry%'
	or oocRules not like '%Roleplaying%')--none
--delete #practicesToDateRaw where participants='Jaguar - Taylor, Slip - Gil, '




--[5]--explode #practicesToDateRaw into #practicesToDateRaw_words
drop table if exists #practicesToDateRaw_words
;with cte as (select distinct p.game,p.style,p.realName,p.practicewhen
	,ltrim(rtrim(x.value)) as word
	from #practicesToDateRaw p cross apply string_split(participants,' ') x)
	select * into #practicesToDateRaw_words from cte	
		where isnull(word,'') not in ('',' ','-')
			and isnull(word,'') not like '%[0-9]%'
select * from #practicesToDateRaw_words order by word--690

--[6] --get xml version of practices-- 
--export as .xlsx first, and then from Excel into 2003 xml
drop table if exists #practicesToDateXml
create table #practicesToDateXml (xmlLine varchar(4000) null)
bulk insert #practicesToDateXml from 'C:\characterSheetReader\fightingStyles\practicesSnapshot20260219.xml' with(datafiletype='char',firstrow=1)
--    <Cell><Data ss:Type="String">Brady Heaton </Data></Cell>
--find the lines like these to match up 


drop table if exists #practicesToDate
;with cte_xml as 
--pull out this cell
--Khar'tan - Brian Kibler&#10;Audax - Collin Babcock&#10;Victor Frost - Dylan Yanke&#10;Jarin'ael Aethyn - Jonathan Young&#10;Chimera - Lux Icarian&#10;Sylver Sequioa - Russell Willoughby&#10;Kavu - Sebastian della Gatta&#10;Sa'ad Aldin Wajid - Shaun Wada&#
(select xmlLine 
	,substring(xmlLine,patindex('%"String">%',xmlLine)+9,4000) toBreakIntoWords
	,row_number() over(order by xmlLine) rn
	from #practicesToDateXml where xmlLine like '%"String">%' )
,cte_words as 
(select p.*
	,x.value as word
	from cte_xml p cross apply string_split(toBreakIntoWords,' ') x)
,cte_matches as 
(select w.* 
	,p.game,p.style,p.realName,p.practiceWhen,p.word as matchedWord
	from cte_words w join #practicesToDateRaw_words p on p.word=w.word)
,cte_matchCounts as
(select rn,game,style,realName,practiceWhen,count(*) matchCount from cte_matches group by rn,game,style,realName,practiceWhen) --order by count(*) desc)
,cte_matchCounts2 as
(select *,row_number() over(partition by game,style,realName,practiceWhen order by matchCount desc) bestMatch from cte_matchCounts)
--select * from cte_matchCounts2 c where c.bestMatch=1
select c.* 
	,x.xmlLine
	,substring(xmlLine,patindex('%"String">%',xmlLine)+9,4000) participantList
	,pr.[timestamp],pr.email,pr.oocRules,pr.characterName
	into #practicesToDate
	from cte_matchCounts2 c
	join cte_xml x on c.rn=x.rn and c.bestMatch=1
	join #practicesToDateRaw pr on pr.realName=c.realName and pr.style=c.style and pr.practiceWhen=c.practiceWhen
update p
	set p.participantList=replace(replace(replace(replace(replace(p.participantList,'</Data></Cell>',''),CHAR(10),''),CHAR(13),''),'&#10;','|'),'GÇÖ','`')
	from #practicesToDate p 

--[7]--explode #practicesToDate to #practicesToDateDetail (1 row per participant)--#practicesToDateDetail where participantRealNameRaw like '% '
--need to make sure to include practice coordinator
drop table if exists #practicesToDateDetail
drop table if exists #x
;with cte as (
select p.*
	,x.value as participantRaw --this could have stuff like '1.' in it, and will need to be parse by the '-' in the middle later
	from #practicesToDate p cross apply string_split(participantList,'|') x
union all
select p.*,ltrim(rtrim(characterName))+' - '+ltrim(rtrim(realName)) as participantRaw from #practicesToDate p
)
select *into #x from cte 
delete #x where nullif(participantRaw,'') is null
update #x set participantRaw=participantRaw+' - firstname lastname' where participantRaw not like '%-%'
select game,style,realName,characterName,practiceWhen
	,participantRaw
	,tm.dbo.parseParticipant(participantRaw,1) participantRealNameRaw
	,tm.dbo.parseParticipant(participantRaw,0) participantCharacterNameRaw
	,convert(varchar(50),null) participantRealNameMatched
	,convert(varchar(50),null) participantCharacterNameMatched
	
	--include for audit
	,timestamp,email,oocRules
	,participantList
	,convert(char(5),null) characterIdMatched
	into #practicesToDateDetail from #x 
	where isnull(participantRaw,'')<>''
;with cte as (select *,row_number() over(partition by game,style,realName,practiceWhen,participantRaw order by [timestamp] desc) rn from #practicesToDateDetail) delete cte where rn>1
create unique clustered index gsrcpp on #practicesToDateDetail(game,style,realName,practiceWhen,participantRaw)
--handle more than 1 dash
select * from #practicesToDateDetail where participantRealNameRaw is null
select * from #practicesToDateDetail where participantCharacterNameRaw is null

--[8]--get characters active last 3 games
update rawCPData set playerName='William Tonx' where characterName='Deacon Ariadne'
update rawCPData set playerName='Isabel Robles' where characterName='Aina the foolish mushroom'
drop table if exists #activeCharacters
;with cte_charactersLast3Games as (select c.playerName,c.characterName,c.characterId
	,try_cast(spentCp as int) spentCp
	,try_cast(corruption as int) corruption
	,e.eventName rawEventName
	,case --when eventName like '%event 84%' then 'Event 84 April 2025'
	when eventName like '%event 85%' then 'Event 85 August 2025'
	when eventName like '%event 86%' then 'Event 86 September 2025' 
	when eventName like '%event 87%' then 'Event 87 December 2025' 
	when eventName like '%event 88%' then 'Event 88 January 2026' 
	--when try_cast(e.eventDate as date) between '2025.04.01' and '2025.04.30' then 'Event 84 April 2025'
	when try_cast(e.eventDate as date) between '2025.08.01' and '2025.08.31' then 'Event 85 August 2025'
	when try_cast(e.eventDate as date) between '2025.09.01' and '2025.09.30' then 'Event 85 September 2025'
	when try_cast(e.eventDate as date) between '2025.12.01' and '2025.12.31' then 'Event 87 December 2025'
	when try_cast(e.eventDate as date) between '2026.01.01' and '2025.01.31' then 'Event 88 January 2026'
		end eventName
	,e.eventDate as rawEventDate
	,try_cast(e.eventDate as date) eventDate
	from rawCpData c
		join rawEvents e on c.playerName=e.playerName and c.characterName=e.characterName
		where eventName like '%event%'
			and (try_cast(e.eventDate as date) between '2025.04.01' and '2026.01.31'
			or eventName like '%event 8[4568]%')
		)
select * 
	into #activeCharacters from cte_charactersLast3Games
		where eventName is not null
update #activeCharacters set playerName=ltrim(rtrim(playerName)), characterName=ltrim(rtrim(characterName))
;with cte as (select *,row_number() over(partition by playerName,characterName order by eventdate desc) rn from #activeCharacters) delete cte where rn>1
create unique clustered index pc on #activeCharacters(playerName,characterName)
insert into #activeCharacters select playerName,CharacterName,characterId,spentCp,corruption,'no event','no event','2026.01.01','2026.01.02' from rawCPData where characterId='7KGKR' 
insert into #activeCharacters select playerName,CharacterName,characterId,spentCp,corruption,'no event','no event','2026.01.01','2026.01.02' from rawCPData where characterId='8XNXE' 
insert into #activeCharacters select playerName,CharacterName,characterId,spentCp,corruption,'no event','no event','2026.01.01','2026.01.02' from rawCPData where characterId='86DYG' 

--[9]--run #activeCharacters across #practicesToDateDetail to resolve the best match (matching playerName first)
update #practicesToDateDetail set participantRealNameRaw='Neil Phelps' where participantRealNameRaw in('Neil Phelps')
update #practicesToDateDetail set participantRealNameRaw='Jackie Salow-Wiley' where participantRealNameRaw in('Jacqueline Salow Wiley')
update #practicesToDateDetail set participantRealNameRaw='Taylor Harrs',participantCharacterNameRaw='Apotheosis' where participantRealNameRaw in('Apotheosis')
update #practicesToDateDetail set participantRealNameRaw='Christopher Rainey-Felley' where participantRealNameRaw in('Chris Rdangy Fenry','Chris Rdangy Fenry</Data><NamedCell')
update #practicesToDateDetail set participantRealNameRaw='Daniel West' where participantRealNameRaw='firstname lastname'
update #practicesToDateDetail set participantRealNameRaw='Sidney Domholdt' where participantRealNameRaw='Calarco Sidney Domholdt'
update #practicesToDateDetail set participantRealNameRaw='Nicholas Prouty' where participantRealNameRaw='Nick Prouty'
update #practicesToDateDetail set participantRealNameRaw='Morgan A Smith' where participantRealNameRaw='Morgan Smith'
delete #practicesToDateDetail where participantRealNameRaw='Ethan Eril'
drop table if exists #realNameMatches
drop table if exists #realNameMatchesWork
;with cte as (
select p.participantCharacterNameRaw,p.participantRealNameRaw
	,a.characterName,a.playerName
	,dbo.clr_LevenshteinDistance(left(p.participantCharacterNameRaw,13),left(a.characterName,13)) characterNameDistance
	,dbo.clr_LevenshteinDistance(left(p.participantRealNameRaw,13),left(a.playerName,13)) realNameDistance
	,a.characterId
	from #practicesToDateDetail p join #activeCharacters a on 1=1		--#activeCharacters where playerName='Taylor Harrs' --#practicesToDateDetail where participantRealNameRaw like '%Taylor%'--Taylor Harris, Jaguar
	)
,cte2 as (select *
	,square(characterNameDistance)+square(realNameDistance) totalDistance 
	,dbo.matchFromStartCount(participantCharacterNameRaw,characterName) charMatchCount
	,dbo.matchFromStartCount(participantRealNameRaw,playerName) realMatchCount
	from cte)
,cte3 as (select *,row_number() over(partition by participantRealNameRaw 
	order by realNameDistance asc,totalDistance asc,realMatchCount desc) rn from cte2)
select * into #realNameMatchesWork from cte3
select participantRealNameRaw,playerName,realNameDistance,totalDistance into #realNameMatches from #realNameMatchesWork where rn=1
create unique clustered index pp on #realNameMatches(participantRealNameRaw)


--[9b]--inspect the worst matches to build pre-treats and then run again
select participantRealNameRaw,playerName,realNameDistance,totalDistance from #realNameMatches order by realNameDistance desc--fucking mess

--[9c]--update back to #practicesToDateDetail
update p
	set p.participantRealNameMatched=r.playerName
	from #practicesToDateDetail p join #realNameMatches r on r.participantRealNameRaw=p.participantRealNameRaw


--[9d]--use that to get characters/ids from #activeCharacters
update #practicesToDateDetail set participantCharacterNameRaw='Salomon “Slip” Jasset' where participantCharacterNameRaw='Slip Jasset'
--update #practicesToDateDetail set participantCharacterNameRaw='Jaguar' where participantCharacterNameRaw='Taylor Harrs'
drop table if exists #charNameMatches
drop table if exists #charNameMatchesWork
;with cte as (select p.participantRealNameRaw,p.participantRealNameMatched
	,p.participantCharacterNameRaw
	,a.characterName,a.characterId
	,dbo.clr_LevenshteinDistance(left(p.participantCharacterNameRaw,13),left(a.characterName,13)) characterNameDistance
	from #practicesToDateDetail p join #activeCharacters a on a.playerName=p.participantRealNameMatched)
	,cte2 as (select *
		,row_number() over(partition by participantRealNameMatched,participantCharacterNameRaw order by characterNameDistance) rn
		from cte)
select * into #charNameMatchesWork from cte2
select * into #charNameMatches from #charNameMatchesWork where rn=1
create unique clustered index pc on #charNameMatches(participantRealNameMatched,participantCharacterNameRaw)
select * from #practicesToDateDetail p where not exists (select null from #charNameMatches c where c.participantCharacterNameRaw=p.participantCharacterNameRaw)--good

--[9e]--inspect for problems
select * from #charNameMatches order by characterNameDistance desc

--[9f]--looks good now, bring back to #practicesToDateDetail
update p
	set p.participantCharacterNameMatched=r.characterName, p.characterIdMatched=r.characterId
	from #practicesToDateDetail p join #charNameMatches r on r.participantRealNameMatched=p.participantRealNameMatched and r.participantCharacterNameRaw=p.participantCharacterNameRaw

select * from #practicesToDateDetail where participantCharacterNameMatched is null

--[9f]--inspect 
--looksee for mismatches
;with cte as (select distinct participantRealNameRaw,participantRealNameMatched,participantCharacterNameRaw,participantCharacterNameMatched 
	,dbo.clr_LevenshteinDistance(left(participantCharacterNameRaw,13),left(participantCharacterNameMatched,13)) charDist
	,dbo.clr_LevenshteinDistance(left(participantRealNameRaw,13),left(participantRealNameMatched,13)) realDist
	,characterIdMatched
	from #practicesToDateDetail where (participantRealNameRaw<>participantRealNameMatched
	or participantCharacterNameRaw<>participantCharacterNameMatched) )
	select * from cte 
		--order by charDist desc
		order by realDist desc
		

--dear lord save this for now
select * into practicesToDateDetail_bak_20260210 from #practicesToDateDetail--181

/* good enough for now, I need to run

--[10]--explode #master into #masterDetail 
drop table if exists #masterDetail
select m.realName,m.characterName,m.style
	,m.practiceCount practiceCountIgnore
	,m.gameDetail gameDetailIgnore
	,m.rankEarned rankEarnedIgnore
	,convert(varchar(50),ltrim(rtrim(x.[value]))) as game
	into #masterDetail
		from #master m cross apply string_split(gameDetail,',') x
create unique clustered index rcsg on #masterDetail(realName,characterName,style,game)

--[???]--onetime fix on #master/#masterDetail to affix the name info from the sheets instead
drop table if exists #work2
;with cte as (
select md.realName,md.characterName
	,a.playerName sheetRealName,a.characterName sheetcharacterName
	,dbo.clr_LevenshteinDistance(left(md.realName,13),left(a.playerName,13)) realNameDistance
	,dbo.clr_LevenshteinDistance(left(md.characterName,13),left(a.characterName,13)) characterNameDistance
	,dbo.matchFromStartCount(md.realName,a.playerName) realMatchCount
	,dbo.matchFromStartCount(md.characterName,a.characterName) charMatchCount
	from #masterDetail md join #activeCharacters a on 1=1)
,cte2 as (select *,square(characterNameDistance)+square(realNameDistance) totalDistance from cte)
,cte3 as (select *,row_number() over(partition by characterName,realName 
	order by totalDistance asc,realMatchCount desc,charMatchCount desc) rn from cte2)
select * into #work2 from cte3 where rn=1
create unique clustered index pp on #work2(characterName,realName)



--looksee
select distinct md.realname,w.sheetRealName 
	,md.characterName,w.sheetCharacterName
	,realNameDistance
	from #masterDetail md join #work2 w on w.realName=md.realName and w.characterName=md.characterName
	where md.realName<>w.sheetRealName
	order by realNameDistance desc

select distinct md.realname,w.sheetRealName 
	,md.characterName,w.sheetCharacterName
	,characterNameDistance
	from #masterDetail md join #work2 w on w.realName=md.realName and w.characterName=md.characterName
	where md.characterName<>w.sheetCharacterName
	order by characterNameDistance desc

--Nick Prouty	Nick Brown	Shadrek	Nox
update p 
	set p.sheetCharacterName='Shadrek Dario',p.sheetRealName='Nick Prouty'
	from #work2 p where realName+characterName in ('Nick ProutyShadrek')
update p 
	set p.sheetCharacterName='Fend''alin',p.sheetRealName='Jason Deal'
	from #work2 p where realName+characterName in ('Jason DealHeinrich')
update p 
	set p.sheetCharacterName='Retitus Tenebris',p.sheetRealName='Michael-Bryan Kelly'
	from #work2 p where realName+characterName in ('Michael-Bryan KellyRetitus Tenebris')
update p 
	set p.sheetCharacterName='Sols''tur',p.sheetRealName='Corin Edwards'
	from #work2 p where realName+characterName in ('Corin EdwardsSols''tur')
update p 
	set p.sheetCharacterName='Victor Frost',p.sheetRealName='Dylan Yanke'
	from #work2 p where realName+characterName in ('Dylan YankeVictor Frost')
update p 
	set p.sheetCharacterName='Sahar Daxsharia'
	from #work2 p where realName+characterName in ('Lily ThiemensSahar')
update p 
	set p.sheetCharacterName='Jaerial Daxsharial'
	from #work2 p where realName+characterName in ('James McCloskeyJaerial')


update md
	set md.realName=w.sheetRealName
		,md.characterName=w.sheetCharacterName
	from #masterDetail md join #work2 w on w.realName=md.realName and w.characterName=md.characterName

--[11]--determine practices that do not count, and highlight manually on form
select game,style,realName,practiceWhen,count(*) from #practicesToDateDetail group by game,style,realName,practiceWhen having count(*)<10--none

--[12]--delete those practices from #practicesToDateDetail
--query is tbd

--[13]--union #practicesToDateDetail and #masterDetail, and rollup
drop table if exists #new
;with cte as (
select participantRealNameMatched realName
	,participantCharacterNameMatched characterName,style,game from #practicesToDateDetail -- #practicesToDateDetail where style like '%ass%'
union
select realName,characterName,style,game from #masterDetail				
)
--select * from cte where style like '%suf%'

select realName,characterName,style,count(*) practiceCount,string_agg(game,', ') gameDetail 
	into #new 
	from cte group by realName,characterName,style order by 1,2

--compare to old #master
select * from #master m where not exists (select null from #new n where n.realName=m.realName)--
select * from #masterDetail where realName like '%Douglas%'--corrected that to fullname, Douglas Duffy
select * from #masterDetail where realName like '%Jackie%'--corrected that to name on sheet, which is just Jackie 
select * from #masterDetail where realName like '%jeff%'--gtg
select * from #masterDetail where realName like '%cas%'--gtg
select * from #master m where not exists (select null from #new n where n.characterName=m.characterName)--17, but I did a ton of name corrects

select * from #new n where not exists (select null from #master m where n.realName=m.realName)--81, mostly dec25, but some from the name standardization
select * from #new n where not exists (select null from #master m where n.characterName=m.characterName)--103, mostly dec25, but some from the name standardization


--[14]
select * from #new order by 1,2

--use this to update the system of record
	--[https://docs.google.com/spreadsheets/d/1k7nJRc1OglY8B7dkddJlQeOo4hPL7Dq1Cp-ItnEREWI/edit?gid=0#gid=0]