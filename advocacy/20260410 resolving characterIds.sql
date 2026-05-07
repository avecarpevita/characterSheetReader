use tm

drop table if exists #a
create table #a (
playerName varchar(255)
,characterName varchar(255)
,discord varchar(255)
,advocateType varchar(255)
,notes varchar(255)
)

bulk insert #a from 'c:\charactersheetReader\advocacy\advocacyMembershipRaw20260410.tsv' with(datafiletype='char')
delete #a where playerName='PlayerName'



select count(*) from #a a
	join rawCPData r on 1=1--2.1MM

drop table if exists #r

select *
	,dbo.firstWord(playerName) firstname
	,reverse(dbo.firstWord(reverse(playerName))) lastname
	into #r
	from rawCpData



drop table if exists #a2
select *
	,dbo.firstWord(playerName) firstname
	,reverse(dbo.firstWord(reverse(playerName))) lastname
	,playerName as fixedName
	into #a2
	from #a


update a
	set fixedName=case playerName
		when 'Quynh Anh (Maureen Ha)' then 'Maureen Ha'
		when 'Bec Mossington' then 'COULD NOT FIND'
		when 'Gaby Jentzsch' then 'Gabriela Jentzsch'
		when 'Lux Sparrow-London' then 'Lux Icarian'
		when 'Mary Lou Kolbenschlag' then 'Mary Lou'
		when 'Isaac Dorntge' then 'Jacen Black'
		when 'J''Amy Elizabeth' then 'J''Amy Pacheco'

when 'JC Schmerker' then 'John Charles Schmerker'
when 'Corlath Vandraco (Donavon T Thorne)' then 'Donavon Thorne'
when 'Shiloe Swisher' then 'COULD NOT FIND'
when 'Talon Hack Bowler' then 'Talon Bowler'
when 'Truong Nguyen' then 'Truong Hai Nguyen'
when 'Todd Renstrom' then 'COULD NOT FIND'
when 'Parker GǣPuckGǥ Essers' then 'Puck Essers'
when 'Robyn Parker (Robyn Lopez)' then 'Robyn Lopez'
when 'Nicole (Nyx) Hunsicker' then 'Nicole Hunsicker (Nyx)'
when 'David Levi Wardell' then 'Levi wardell'

when 'Arianna(Alex) Forest ' then 'Alex Forest'				--select top 100 * from #r where lastname like '%Forest%'	--select top 100 * from #r where firstname like '%cass%'
when 'Ashley "Charlie" Fowler' then 'Charlie Fowler'		--select top 100 * from #r where lastname like '%Fowler%'
when 'Cass Manning' then 'COULD NOT FIND'			--select top 100 * from #r where lastname like '%manni%'	--select top 100 * from #r where firstname like '%cass%'
when 'Connor Gonzagalino' then 'Connor Palacio'
when 'Eliran (Eliana) Sternin' then 'Eliran Sternin'
when 'Grey Karis-Sconyers' then 'Greyson Karis-Sconyers'
when 'AnnaBella Thomason' then 'Anne Thomason'			--select top 100 * from #r where lastname like '%Thomason%'	--select top 100 * from #r where firstname like '%cass%'
when 'James William Medina' then 'James Medina'
when 'Justin Larry James Montague' then 'Justin Montague'
when 'Kelsi Reel' then 'Kelsi Johnson'								--select top 100 * from #r where lastname like '%Reel%'	--select top 100 * from #r where firstname like '%Kelsi%'
when 'Kelley McFarland ' then 'Kiel McFarland'
when 'Kiley Cuite' then 'Kiley "Kiki" Cuite'
when 'Aleks Thurman' then 'Aleksandr Thurman'					--select top 100 * from #r where lastname like '%Thurman%'	--select top 100 * from #r where firstname like '%Kelsi%'
when 'Blakely Thomas Light' then 'Blakely Light'
when 'Bryan w. Bolles' then 'Bryan Bolles'--select top 100 * from #r where lastname like '%Bolles%'	--select top 100 * from #r where firstname like '%Kelsi%'
when 'Sunny Slaton' then 'Sunny'					--select top 100 * from #r where lastname like '%Slaton%'	--select top 100 * from #r where firstname like '%Sunny%'
when 'Miriam Comber' then 'Mariam Dittmann'						--select top 100 * from #r where lastname like '%Comber%'	--select top 100 * from #r where firstname like '%Miriam%' --select * from #a2 where playerName like '%miriam%'
when 'Jessica Simpson Hall' then 'Jessica Galletto'					--select top 100 * from #r where lastname like '%Gallet%'	--select top 100 * from #r where firstname like '%Jessica%' --select * from #a2 where playerName like '%miriam%'
when 'Kait Sofai' then 'COULD NOT FIND'
when 'Melissa Anne Sakrison' then 'Melissa Sakrison'		--select top 100 * from #r where lastname like '%Gallet%'	--select top 100 * from #r where firstname like '%Melissa%' --select * from #a2 where playerName like '%miriam%'
when 'Michael Reesha (Lancaster?)' then 'Michael Lancaster'				--select top 100 * from #r where lastname like '%Lancaster%'	--select top 100 * from #r where firstname like '%Melissa%' --select * from #a2 where playerName like '%miriam%'
when 'Mike Geifman' then 'Michael Geifman'								--select top 100 * from #r where lastname like '%Geifman%'	--select top 100 * from #r where firstname like '%Melissa%' --select * from #a2 where playerName like '%miriam%'
when 'Atlas Oyewole' then 'Mir Oyewole'								--select top 100 * from #r where lastname like '%Bauman%'	--select top 100 * from #r where firstname like '%Kylie%' --select * from #a2 where playerName like '%Kylie%'
when 'Nemo Fett' then 'COULD NOT FIND'
when 'Oak Lane (Anna Lane)' then 'Oak Lane'
when 'Finn Pierson ' then 'Rhys Pierson'
when 'Shoshi Hope' then 'Shoshi Kinzel'
when 'Sierra Stroebel (now Talesin)' then 'Taliesin Stroebel'
when 'Zachary Ekstedt' then 'Zach Ekstedt'
when 'Benjamin David Aldercast' then 'Benjamin Aldercast'
when 'Brianna Paris' then 'Brie Paris'
when 'Brian Soares' then 'Bee Soares'
when 'Caitlin Adams' then 'Atlas Adams'
when 'Edward Bauman' then 'Ed Bauman'
when 'Kylie Marie' then 'COULD NOT FIND'
	when 'Kha Kyle Vu Duong' then 'Kyle Duong'
when 'Fawn Trigili-Quinn' then 'Fawn Quinn'
when 'Parker GÇ£PuckGÇ¥ Essers' then 'Puck Essers'--
when 'George Kenton Zeng' then 'George Zeng'
when 'Heather Crumly' then 'Heather Crumly'--x
when 'Jesse D Kennedy' then 'Jesse Kennedy'
when 'Jesse Riley' then 'Jesse Riley-Frola'--x
when 'Johnny Tarbuskovich' then 'John Tarbuskovich'
when 'Matthew David Mandel Hemsley' then 'Matthew Mandel Hemsley'
when 'Momo Meas' then 'Momo '
when 'Steven Skyler Dean' then 'Steven Dean'
when 'Moira Carter' then 'Moira Denton'
when 'Alejandro (Alex) Gonzalez ' then 'Alejandro Gonzalez'--x
when 'Andrew Cu+¦ado' then 'Andrew Cunado'--x
when 'Ariana Paris' then 'Ari Paris'
when 'Bev Thomas' then 'Beverly Thomas'--x
when 'Ben Paris' then 'Price Paris'--x
when 'Chris Rice' then 'Christopher Rice'--x
when 'Sammy Swader' then 'Danny Swader'--x

when 'Dave Williams' then 'David Williams'
when 'Georgi ridgeway' then 'Georgi Ridgway'
when 'Harrison Watson' then 'Harrison Watson'
when 'Kelsey Hornby' then 'COULD NOT  FIND'
when 'Matt Myers' then 'Matthew Myers'
when 'Michael Haydel' then 'Mike Haydel'
when 'Nick Kane' then 'Nick Kane'
when 'Meagan Helms' then 'Meagan Helms'
when 'Richard Moonil Choi' then 'Richard Choi'
when 'Rozlyn Nuttle' then 'Roz Nuttle'
when 'Skye Jackson' then 'Skye Johnson'
when 'Alexander Nicholson' then 'Alexander Nicholson'
when 'Alexandria Shin' then 'Alex Shin'
when 'Arianna Isbell' then 'Ariana Isbell'
when 'Brit Silver Weber' then 'Brit Silver'
when 'Cassandra Josephine Mogavero' then 'Cassandra Mogavero'
when 'Catherine (Kate) Crain' then 'Catherine Crain'
when 'Charles B. Johnson' then 'Charles B Johnson '
when 'Claire Wunshel' then 'Claire Wunschel'
when 'clayton frits' then 'Clayton Frits'
when 'Hayley Hudkins' then 'Haley Hudkins'
when 'Jazz Galanodel' then 'Jazzy Galanodel'
when 'Josh Branch' then 'Joshua Branch'
when 'Kevin Hue  ' then 'Kevin Hue'

		else playerName end
	from #a2 a

update a
	set firstname=dbo.firstWord(fixedName) 
	,lastname=reverse(dbo.firstWord(reverse(fixedName))) 
	from #a2 a
	


drop table if exists #work
select a.* 
	,r.playerName as playerNameSheets
	,r.characterName as characterNameSheets
	,r.characterId,r.spentCp
	,dbo.clr_LevenshteinDistance(left(a.characterName,13),left(r.characterName,13)) characterNameDistance
	,dbo.clr_LevenshteinDistance(left(a.fixedName,13),left(r.playerName,13)) playerNameDistance
	,dbo.clr_LevenshteinDistance(left(a.firstname,13),left(r.firstname,13)) firstnameDistance
	,dbo.clr_LevenshteinDistance(left(a.lastname,13),left(r.lastname,13)) lastnameDistance
	into #work
	from #a2 a
	join #r r on 1=1--2.1MM
	
drop table if exists #work2
;with cte2 as (select *
	,square(firstnameDistance)+square(lastnameDistance)+square(playerNameDistance) totalDistance 
	,dbo.matchFromStartCount(characterName,characterNameSheets) characterNameMatchCount
	,dbo.matchFromStartCount(playerName,playerNameSheets) playerNameMatchCount
	from #work)
select * into #work2 from cte2--2183026



drop table if exists #matches
;with cte3 as (select *,row_number() over(partition by playerName
	order by totalDistance asc,firstnameDistance asc,lastnameDistance asc,playerNameMatchCount desc,characterNameDistance asc) rn from #work2)
	select * into #matches from cte3 where rn=1
--471



--to be moved to the top for resolution
update a
	set fixedName=case playerName
	
		else playerName end
	from #a2 a

select top 1


select playerNameDistance
	,'when '''+playerName+''' then '''+playerNameSheets+'''',playerNameSheets,fixedName
	,* from #matches 
		where fixedName<>'COULD NOT FIND'
		order by 1 desc,3

select playerNameDistance,* from #matches where playerNameDistance>1 
	order by 1 desc

--get a final list with characterId first
drop table if exists #advocatesWithCharacterIds
select playerName,characterName,discord,advocateType,notes
	,playerNameDistance
	,case when playerNameDistance<=1 then playerNameSheets else null end playerNameSheets
	,case when playerNameDistance<=1 then characterId else null end characterId
	,case when playerNameDistance<=1 then characterNameSheets else null end characterNameSheets
	,convert(varchar(255),null) lastPlayEvent
	,0 toRemove
	
	into #advocatesWithCharacterIds
	from #matches
	order by playerNameDistance desc

select * 
	from #advocatesWithCharacterIds where characterId is null

update a
	set a.characterId=case playerName
		when 'Alexander Nicholson' then '7ARXM'
		when 'Heather Crumly' then '7RY4V'
		--when 'Meagan Helms' then ''
		when 'Millier Friedman' then '7YZAX'
		when 'Nicholas Brown' then '7VMWP'
		when 'Samantha Carletta' then '7YZEV'
		else null end
	from #advocatesWithCharacterIds a where characterId is null

select count(*),count(distinct characterId) from #advocatesWithCharacterIds
select characterId,count(*) from #advocatesWithCharacterIds group by characterId order by 2 desc
select * from #advocatesWithCharacterIds where characterId='8NADW'
delete #advocatesWithCharacterIds where playerName='Rozlyn Nuttle'

drop table if exists #maxDates
;with cte as(
select r.* 
	,dbo.cleanRawEventName(eventName,eventDate) cleanEventName
	,dbo.getEventDate(eventName,eventDate) cleanEventDate
	
	from rawEvents r join #advocatesWithCharacterIds a on r.characterId=a.characterId
	where r.eventName like '%event%'
	)
,cte2 as (select *,row_number() over(partition by characterId order by cleanEventDate desc) rn from cte)
select * into #maxDates from cte2 where rn=1

update a
	set a.lastPlayEvent=m.cleanEventName
	from #advocatesWithCharacterIds a join #maxDates m on m.characterId=a.characterId

select * from #advocatesWithCharacterIds order by lastPlayEvent

--discord members
drop table if exists #rawDiscord
create table #rawDiscord (id varchar(255)
	,discord varchar(255)
	,discriminator varchar(255)
	,nickname varchar(255)
	
	,avatar varchar(255)
	,roles varchar(255)
	,joinDate varchar(255)
	,activity varchar(255)
	,status varchar(255)
	,avatar_url  varchar(255))
bulk insert #rawDiscord from 'c:\characterSheetReader\advocacy\discordMembers.txt' with(datafiletype='char')

select * from #rawDiscord where roles like '%advo%' order by try_cast(left(joinDate,10) as date)

arsonistgoose
