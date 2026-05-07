use tm

select * from sys.schemas

create schema postFeb26--x

select * 
	,'select * into postFeb26.'+table_name+' from dbo.'+table_name
	from information_schema.tables where table_schema='dbo' and table_name not like 'temp%' and table_name not like '%bak2%'
	order by table_name

select * into postFeb26.anchorChangeLog from dbo.anchorChangeLog
select * into postFeb26.bloodlines from dbo.bloodlines
select * into postFeb26.chaff from dbo.chaff
select * into postFeb26.characterBloodlines from dbo.characterBloodlines
select * into postFeb26.characterCorruptionEvents from dbo.characterCorruptionEvents
select * into postFeb26.characterCPEvents from dbo.characterCPEvents
select * into postFeb26.characterCultures from dbo.characterCultures
select * into postFeb26.characterLoadExceptions from dbo.characterLoadExceptions
select * into postFeb26.characters from dbo.characters
select * into postFeb26.characterSkills from dbo.characterSkills
select * into postFeb26.cultures from dbo.cultures
select * into postFeb26.eventsWithDates from dbo.eventsWithDates
select * into postFeb26.games from dbo.games
select * into postFeb26.loreAbbrev from dbo.loreAbbrev
select * into postFeb26.parsedCharacterBlob from dbo.parsedCharacterBlob
select * into postFeb26.parsedprogressionBlob from dbo.parsedprogressionBlob
select * into postFeb26.playerIPEvents from dbo.playerIPEvents
select * into postFeb26.players from dbo.players
select * into postFeb26.practicesToDateDetail_bak_20260210 from dbo.practicesToDateDetail_bak_20260210
select * into postFeb26.rawCpData from dbo.rawCpData
select * into postFeb26.rawEvents from dbo.rawEvents
select * into postFeb26.rawLores from dbo.rawLores
select * into postFeb26.rawSkills from dbo.rawSkills
select * into postFeb26.religions from dbo.religions
select * into postFeb26.skills from dbo.skills
select * into postFeb26.tickets from dbo.tickets