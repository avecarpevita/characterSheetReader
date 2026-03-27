use tm

select top 100 * from INFORMATION_SCHEMA.tables where TABLE_SCHEMA='dbo' and table_name like 'raw%'

alter table rawEvents add characterId char(5)
alter table rawSkills add characterId char(5)

update e
	set e.characterId=c.characterId
	from rawEvents e join rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName
update e
	set e.characterId=c.characterId
	from rawSkills e join rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName

alter table rawSkills alter column characterId char(5) not null
alter table rawEvents alter column characterId char(5) not null

create unique index c on rawSkills(characterId,rawSkill)
create unique index c on rawEvents(characterId,eventName)

