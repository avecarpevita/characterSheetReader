use tm
drop table if exists rawSkills
create table rawSkills (
	characterName nvarchar(100) not null
	,playerName nvarchar(100) not null
	,rawSkill nvarchar(100) not null 
	,rawCpSpent nvarchar(100) not null
	,insertDate datetime not null default getdate()
	)
alter table rawSkills add primary key clustered(characterName,playerName,rawSkill)