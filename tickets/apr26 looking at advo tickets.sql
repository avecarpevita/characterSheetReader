use tm

select distinct ticketType from tickets where eventName like 'Event 90%'--Full Event: Player Advocate ONLY

select * from tickets where ticketType='Full Event: Player Advocate ONLY' and eventName like 'Event 90%' --141--smells right

drop table if exists #advo
create table #advo (
	playerName varchar(255)
	,characterName varchar(255)
	,discord varchar(255)
	,advoType varchar(255)
	,notes varchar(1000)
)

bulk insert #advo from 'C:\characterSheetReader\tickets\advocacyRoster.tsv' with(datafiletype='char')

drop table if exists #advoLastNames
select *,dbo.getLastWord(playerName) lastname into #advoLastNames from #advo

drop table if exists #tickets
select  *,dbo.getLastWord(playerName) lastname 
	into #tickets
	from tickets t
	where ticketType='Full Event: Player Advocate ONLY' and eventName like 'Event 90%' 

select distinct * from #tickets t
	left join #advoLastNames a on a.lastname=t.lastname
	where advoType is null
	

Reiner Perillo		-- first aid
Hera Dewan			-- not in my records, pinged on discord