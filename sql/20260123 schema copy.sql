use tm

create schema postDec25--x

select * 
	,'select * into postDec25.'+table_name+' from dbo.'+table_name
	from information_schema.tables where table_schema='dbo' and table_name not like 'temp%' and table_name not like '%bak2%'

select * into postDec25.rawLores from dbo.rawLores
select * into postDec25.rawEvents from dbo.rawEvents
select * into postDec25.rawSkills from dbo.rawSkills
select * into postDec25.rawCpData from dbo.rawCpData
select * into postDec25.players from dbo.players
select * into postDec25.characters from dbo.characters
select * into postDec25.cultures from dbo.cultures
select * into postDec25.eventsWithDates from dbo.eventsWithDates
select * into postDec25.bloodlines from dbo.bloodlines
select * into postDec25.religions from dbo.religions
select * into postDec25.skills from dbo.skills
select * into postDec25.characterSkills from dbo.characterSkills
select * into postDec25.characterCultures from dbo.characterCultures
select * into postDec25.parsedCharacterBlob from dbo.parsedCharacterBlob
select * into postDec25.parsedprogressionBlob from dbo.parsedprogressionBlob
select * into postDec25.characterBloodlines from dbo.characterBloodlines
select * into postDec25.games from dbo.games
select * into postDec25.characterCPEvents from dbo.characterCPEvents
select * into postDec25.characterCorruptionEvents from dbo.characterCorruptionEvents
select * into postDec25.anchorChangeLog from dbo.anchorChangeLog
select * into postDec25.loreAbbrev from dbo.loreAbbrev
select * into postDec25.playerIPEvents from dbo.playerIPEvents
select * into postDec25.chaff from dbo.chaff
select * into postDec25.characterLoadExceptions from dbo.characterLoadExceptions
select * into postDec25.tickets from dbo.tickets