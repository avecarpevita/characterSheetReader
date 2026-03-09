use tm

--select * from string_split(
--'Timestamp	Email Address	Real Name	Character Name	What game did you organize the practice session? (e.g. December 2025)	What Style did you practice at this session? (if the session was for multiple styles, please make multiple entries)	When was this practice session?	What ooc rules did you review in this session?	Participant #1 (THIS IS PROBABLY YOU!) Please format as "CharacterId Character Name - Player Name" e.g. 8594Y Gaeden - Scott Ross	Participant #2	Participant #3	Participant #4	Participant #5	Participant #6	Participant #7	Participant #8	Participant #9	Participant #10	Participant #11	Participant #12	Participant #13	Participant #14	Participant #15	Participant #16	Participant #17	Participant #18	Participant #19	Participant #20',char(9))

drop table if exists #x
create table #x (
[Timestamp] nvarchar(1000) 
,[Email Address] nvarchar(1000)
,[Real Name] nvarchar(1000)
,[Character Name] nvarchar(1000)
,game nvarchar(1000)
,tradition nvarchar(1000)
,[When was this practice session?] nvarchar(1000)
,[What ooc rules did you review in this session?] nvarchar(1000)
,[Participant #1] nvarchar(1000)
,[Participant #2] nvarchar(1000)
,[Participant #3] nvarchar(1000)
,[Participant #4] nvarchar(1000)
,[Participant #5] nvarchar(1000)
,[Participant #6] nvarchar(1000)
,[Participant #7] nvarchar(1000)
,[Participant #8] nvarchar(1000)
,[Participant #9] nvarchar(1000)
,[Participant #10] nvarchar(1000)
,[Participant #11] nvarchar(1000)
,[Participant #12] nvarchar(1000)
,[Participant #13] nvarchar(1000)
,[Participant #14] nvarchar(1000)
,[Participant #15] nvarchar(1000)
,[Participant #16] nvarchar(1000)
,[Participant #17] nvarchar(1000)
,[Participant #18] nvarchar(1000)
,[Participant #19] nvarchar(1000)
,[Participant #20] nvarchar(1000)
)

bulk insert #x from 'c:\characterSheetReader\magicalTraditions\test.tsv' with(datafiletype='char', firstrow=2)

;with cte as (select top 20 row_number() over(order by name) rn from sys.objects)
select 'union select game,tradition,[participant #'+convert(varchar,rn)+'] from #x where len([participant #'+convert(varchar,rn)+'])>4' from cte

drop table if exists #x2
select game,tradition,[participant #1] as participant
	into #x2
	from #x where len([participant #1])>4
union select game,tradition,[participant #2] from #x where len([participant #2])>4
union select game,tradition,[participant #3] from #x where len([participant #3])>4
union select game,tradition,[participant #4] from #x where len([participant #4])>4
union select game,tradition,[participant #5] from #x where len([participant #5])>4
union select game,tradition,[participant #6] from #x where len([participant #6])>4
union select game,tradition,[participant #7] from #x where len([participant #7])>4
union select game,tradition,[participant #8] from #x where len([participant #8])>4
union select game,tradition,[participant #9] from #x where len([participant #9])>4
union select game,tradition,[participant #10] from #x where len([participant #10])>4
union select game,tradition,[participant #11] from #x where len([participant #11])>4
union select game,tradition,[participant #12] from #x where len([participant #12])>4
union select game,tradition,[participant #13] from #x where len([participant #13])>4
union select game,tradition,[participant #14] from #x where len([participant #14])>4
union select game,tradition,[participant #15] from #x where len([participant #15])>4
union select game,tradition,[participant #16] from #x where len([participant #16])>4
union select game,tradition,[participant #17] from #x where len([participant #17])>4
union select game,tradition,[participant #18] from #x where len([participant #18])>4
union select game,tradition,[participant #19] from #x where len([participant #19])>4
union select game,tradition,[participant #20] from #x where len([participant #20])>4

drop table if exists #x3
;with cte as (select *, left(ltrim(rtrim(participant)),5) characterId
	from #x2)
	select c.*
		,r.playerName,r.characterName
		from cte c left join rawCPData r on r.characterId=c.characterId
		--the data works, but it also doesn't 
		-- 8ZE4A is not 82E4A
		-- 8WN9G is not 8WN9C