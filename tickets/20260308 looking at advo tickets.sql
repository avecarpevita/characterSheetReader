use tm

select distinct ticketType from tickets where eventName like 'Event 89%'--Full Event: Player Advocate ONLY

select * from tickets where ticketType='Full Event: Player Advocate ONLY' and eventName like 'Event 89%' --170

drop table if exists #advo
create table #advo (
	playerName varchar(255)
	,characterName varchar(255)
	,discord varchar(255)
	,advoType varchar(255)
	,notes varchar(1000)
)

bulk insert #advo from 'c:\anchorPoints\data\advocacyRoster.tsv' with(datafiletype='char')

drop table if exists #advoLastNames
select *,dbo.getLastWord(playerName) lastname into #advoLastNames from #advo

drop table if exists #tickets
select  *,dbo.getLastWord(playerName) lastname 
	into #tickets
	from tickets t
	where ticketType='Full Event: Player Advocate ONLY' and eventName like 'Event 89%' 

select distinct * from #tickets t
	left join #advoLastNames a on a.lastname=t.lastname
	where advoType is null
	
Bay Grabowski			
Brittany Woollenweber	--records under brit
Greyson Karis-Sconyers	--records missing "grey" for some reason, but look at applicants
Jacob Miyashiro			--1st  aid thing
Jenn Hynum 
Josh Bisquera
MATTHEW Goode Frickert -- why is he buying a ticket?
Moira Denton -- records (under other name tho)
Summer Latimer -- not in my records 

Reiner Perillo		-- suss, this guy is power flake
Rick Quitoriano		-- more suss, and given his actions, if he snuck through, should be booted
Rowan Norenberg		-- no idea


--To Followup with the individual
Bay Grabowski
Christopher Bennett
Greyson Karis-Sconyers
Josh Bisquera
Madeline McHugh		
Reiner Perillo
Rick Quitoriano
Rowan Norenberg
Summer Latimer




--To Get In My Records
AJ Lepe, Safety
Amelia Lewis, Muscle Crew
Andrew Frejek, Muscle Crew
Hannah Butler
Jackson Korsgaard

--special followup
MATTHEW Goode Frickert



--To Followup with the individual
drop table if exists #names
create table #names (playerName varchar(255))
insert into #names values (
'Bay Grabowski')
,('Christopher Bennett')
,('Greyson Karis-Sconyers')
,('Josh Bisquera')
,('Madeline McHugh'	)
,('Reiner Perillo')
,('Rick Quitoriano')
,('Rowan Norenberg')
,('Summer Latimer')

select distinct r.email,n.* from rawCpData r right join #names n on n.playerName=r.playerName

email                                                                                                playerName
---------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------
joshbisquera12@gmail.com                                                                             Josh Bisquera				--sent PM
grey@karissconyers.com                                                                               Greyson Karis-Sconyers		--sent email
baygrabowski@gmail.com                                                                               Bay Grabowski				--sent PM
dayalasaek@gmail.com                                                                                 Christopher Bennett		--sent email
reiner.perillo@gmail.com                                                                             Reiner Perillo				--sent email
madelinemq22@gmail.com                                                                               Madeline McHugh			--sent email
rickquitoriano@gmail.com                                                                             Rick Quitoriano			--sent email
summer.c.latimer@gmail.com                                                                           Summer Latimer				--sent email
shoofkitty18@gmail.com                                                                               Rowan Norenberg			--sent email


--look at this -- is there a stinker or a battle to have
;with cte as (
select distinct t.*,dbo.CleanupAdvoType(a.advoType) advoType from #tickets t
	left join #advoLastNames a on a.lastname=t.lastname
	where advoType is not null
	)
select convert(varchar(20),advoType) advoType,count(*) totalAdvocates
	,string_agg(playerName,', ') playerNames
from cte group by advoType order by 1

--Aimee Pery, Henry Nicholson, Jason Baxter, Kiel McFarland, Puck Essers, Sneha Nicholson, Toya Raveneau, Zara Baxter

--Kiel does what exactly that warrants getting out of a shift?

