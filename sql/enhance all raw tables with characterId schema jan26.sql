use tm

select top 100 * from INFORMATION_SCHEMA.tables where TABLE_SCHEMA='postJan26' and table_name like 'raw%'

alter table postJan26.rawEvents add characterId char(5)
alter table postJan26.rawSkills add characterId char(5)

update e
	set e.characterId=c.characterId
	from postJan26.rawEvents e join postJan26.rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName
update e
	set e.characterId=c.characterId
	from postJan26.rawSkills e join postJan26.rawCpData c on c.playerName=e.playerName and c.characterName=e.characterName

delete postJan26.rawEvents where characterId is null
delete postJan26.rawSkills where characterId is null



alter table postJan26.rawSkills alter column characterId char(5) not null
alter table postJan26.rawEvents alter column characterId char(5) not null

create unique index c on postJan26.rawSkills(characterId,rawSkill)
create unique index c on postJan26.rawEvents(characterId,eventName)

