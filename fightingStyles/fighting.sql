--2025.10.14 (this was the original load of the OLD form, which will not be revisited)
use tm

--Timestamp	Email Address	Real Name	Character Name	What game did you participate in a practice session? (e.g. April 2025)	What Style did you practice at this session?	
--When was this practice session?	What ooc rules did you review in this session?	Column 8
drop table if exists #f
create table #f (
	[timestamp] varchar(255) not null
	,email varchar(255) not null
	,realName varchar(255) not null
	,characterName varchar(255) not null
	,game varchar(15) not null
	,style varchar(25) not null
	,practiceWhen varchar(35) not null
	,safetyRules varchar(4000) not null
	,column8 varchar(255) not null
	)
bulk insert #f from 'C:\characterSheetReader\fightingStyles\fighting.tsv' with(datafiletype='char',firstrow=2)

--select max(len(game)) from #f
--select len(safetyRules),count(*) from #f group by len(safetyRules)--264
--standardize "game"
--select * from #f where len(safetyRules)>225
--select game
--	,style,practiceWhen [When was this practice session?]
--,count(*) [#]
--	,sum(case when safetyRules like '%352%' and safetyRules like '%339%'
--		and safetyRules like '%350%' and safetyRules like '%335%' and safetyRules like '%325%' then 1 else 0 end) [# qualified]
		
--	from #f group by game,style,practiceWhen 
--	order by min(timestamp)
update #f set realName=ltrim(rtrim(realName)), characterName=ltrim(rtrim(characterName))

--fixes
update #f 	
	set characterName='Khar''tan' where characterName='Khartan'
update #f 	
	set characterName='Zeffladin Keareth' where characterName='Zeff Keareth'
update #f 	
	set realName='Devin McCarthy' where realName='Devin'
update #f 	
	set realName='Jason Walker', characterName='Sir Zeryth' where characterName like '%zeryth%'
update #f 	
	set realName='Jonathan Ying', characterName='Roderick ' where characterName like '%Rod%rick%'
update #f 	
	set characterName='Seeker by Light and Shadow' where realName='Jonny Martinez'
update #f 	
	set realName='Kathleen Rios (Tonks)' where characterName='Gya'
update #f 	
	set realName='Matthew Salus' where characterName='Atticus Velyrone'
update #f 	
	set realName='Kenji Zhu-Lung' where characterName='Mike Morales'
update #f 	
	set characterName='Sylver Sequioa' where realName='Russell Willoughby'
--select * from #f where realName='Russell Willoughby'
--select * from #f where realName='Sylver Sequoia'
--select * from #f where characterName like '%Rod%rick%'

select realName,characterName,style
	,count(*) practiceCount
	,string_agg(ltrim(rtrim(game)), ', ') gameDetail
	from #f 
	--where realName not in ('Ash L')
	group by style,realName,characterName order by 1,3

--2026.01.01
--take #f into a permanent table
--drop table if exists fightingProgressionPlayerDetail
select try_cast([timestamp] as datetime) as [timestamp]
	,email,realName,characterName,game,style,practiceWhen,safetyRules
	into fightingProgressionPlayerDetail
	from #f
;with cte as (select *,row_number() over(partition by characterName,realName,game,style order by [timestamp]) rn from fightingProgressionPlayerDetail)
	delete cte where rn>1
create unique clustered index crgs on fightingProgressionPlayerDetail(characterName,realName,game,style)


