use tm

select * from sys.schemas

create schema postApr26--x

select * 
	,'select * into postApr26.'+table_name+' from dbo.'+table_name
	from information_schema.tables where table_schema='dbo' and table_name not like 'temp%' and table_name not like '%bak2%'
	order by table_name

select * into postApr26.anchorChangeLog from dbo.anchorChangeLog
select * into postApr26.bloodlines from dbo.bloodlines
select * into postApr26.chaff from dbo.chaff
select * into postApr26.characterBloodlines from dbo.characterBloodlines
select * into postApr26.characterCorruptionEvents from dbo.characterCorruptionEvents
select * into postApr26.characterCPEvents from dbo.characterCPEvents
select * into postApr26.characterCultures from dbo.characterCultures
select * into postApr26.characterLoadExceptions from dbo.characterLoadExceptions
select * into postApr26.characters from dbo.characters
select * into postApr26.characterSkills from dbo.characterSkills
select * into postApr26.cultures from dbo.cultures
select * into postApr26.eventsWithDates from dbo.eventsWithDates
select * into postApr26.games from dbo.games
select * into postApr26.loreAbbrev from dbo.loreAbbrev
select * into postApr26.parsedCharacterBlob from dbo.parsedCharacterBlob
select * into postApr26.parsedprogressionBlob from dbo.parsedprogressionBlob
select * into postApr26.playerIPEvents from dbo.playerIPEvents
select * into postApr26.players from dbo.players
select * into postApr26.rawCpData from dbo.rawCpData
select * into postApr26.rawEvents from dbo.rawEvents
select * into postApr26.rawLores from dbo.rawLores
select * into postApr26.rawSkills from dbo.rawSkills
select * into postApr26.religions from dbo.religions
select * into postApr26.skills from dbo.skills
select * into postApr26.tickets from dbo.tickets