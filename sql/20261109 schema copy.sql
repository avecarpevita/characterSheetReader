use tm

select * from sys.schemas

create schema postJul26--x

select * 
	,'select * into postJul26.'+table_name+' from dbo.'+table_name
	from information_schema.tables where table_schema='dbo' and table_name not like 'temp%' and table_name not like '%bak2%'
	order by table_name

select * from INFORMATION_SCHEMA.tables where table_schema='postMay26'

select * into postJul26.anchorChangeLog from dbo.anchorChangeLog
select * into postJul26.bloodlines from dbo.bloodlines
select * into postJul26.chaff from dbo.chaff
select * into postJul26.characterBloodlines from dbo.characterBloodlines
select * into postJul26.characterCorruptionEvents from dbo.characterCorruptionEvents
select * into postJul26.characterCPEvents from dbo.characterCPEvents
select * into postJul26.characterCultures from dbo.characterCultures
select * into postJul26.characterLoadExceptions from dbo.characterLoadExceptions
select * into postJul26.characters from dbo.characters
select * into postJul26.characterSkills from dbo.characterSkills
select * into postJul26.cultures from dbo.cultures
select * into postJul26.eventsWithDates from dbo.eventsWithDates
select * into postJul26.games from dbo.games
select * into postJul26.loreAbbrev from dbo.loreAbbrev
select * into postJul26.parsedCharacterBlob from dbo.parsedCharacterBlob
select * into postJul26.parsedprogressionBlob from dbo.parsedprogressionBlob
select * into postJul26.playerIPEvents from dbo.playerIPEvents
select * into postJul26.players from dbo.players
select * into postJul26.practicesToDateDetail_bak_20260210 from dbo.practicesToDateDetail_bak_20260210
select * into postJul26.rawCpData from dbo.rawCpData
select * into postJul26.rawEvents from dbo.rawEvents
select * into postJul26.rawLores from dbo.rawLores
select * into postJul26.rawSkills from dbo.rawSkills
select * into postJul26.religions from dbo.religions
select * into postJul26.skills from dbo.skills
select * into postJul26.tickets from dbo.tickets
