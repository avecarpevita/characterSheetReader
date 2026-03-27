use tm

select top 100 * from INFORMATION_SCHEMA.tables where TABLE_SCHEMA='postDec25' and table_name like 'raw%'

alter table postDec25.rawEvents add characterId char(5)
alter table postDec25.rawSkills add characterId char(5)

update e
	set e.characterId=c.characterId
	from postDec25.rawEvents e join postDec25.rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName
update e
	set e.characterId=c.characterId
	from postDec25.rawSkills e join postDec25.rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName

delete postDec25.rawEvents where characterId is null
delete postDec25.rawSkills where characterId is null



alter table postDec25.rawSkills alter column characterId char(5) not null
alter table postDec25.rawEvents alter column characterId char(5) not null

create unique index c on postDec25.rawSkills(characterId,rawSkill)
create unique index c on postDec25.rawEvents(characterId,eventName)

