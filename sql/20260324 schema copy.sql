use tm

create schema postJan26--x

select * 
	,'select * into postJan26.'+table_name+' from dbo.'+table_name
	from information_schema.tables where table_schema='dbo' and table_name not like 'temp%' and table_name not like '%bak2%'
	order by table_name

select * into postJan26.anchorChangeLog from dbo.anchorChangeLog
select * into postJan26.bloodlines from dbo.bloodlines
select * into postJan26.chaff from dbo.chaff
select * into postJan26.characterBloodlines from dbo.characterBloodlines
select * into postJan26.characterCorruptionEvents from dbo.characterCorruptionEvents
select * into postJan26.characterCPEvents from dbo.characterCPEvents
select * into postJan26.characterCultures from dbo.characterCultures
select * into postJan26.characterLoadExceptions from dbo.characterLoadExceptions
select * into postJan26.characters from dbo.characters
select * into postJan26.characterSkills from dbo.characterSkills
select * into postJan26.cultures from dbo.cultures
select * into postJan26.eventsWithDates from dbo.eventsWithDates
select * into postJan26.games from dbo.games
select * into postJan26.loreAbbrev from dbo.loreAbbrev
select * into postJan26.parsedCharacterBlob from dbo.parsedCharacterBlob
select * into postJan26.parsedprogressionBlob from dbo.parsedprogressionBlob
select * into postJan26.playerIPEvents from dbo.playerIPEvents
select * into postJan26.players from dbo.players
select * into postJan26.practicesToDateDetail_bak_20260210 from dbo.practicesToDateDetail_bak_20260210
select * into postJan26.rawCpData from dbo.rawCpData
select * into postJan26.rawEvents from dbo.rawEvents
select * into postJan26.rawLores from dbo.rawLores
select * into postJan26.rawSkills from dbo.rawSkills
select * into postJan26.religions from dbo.religions
select * into postJan26.skills from dbo.skills
select * into postJan26.tickets from dbo.tickets