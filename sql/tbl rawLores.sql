use tm
drop table if exists rawLores
create table rawLores (
	characterName nvarchar(100) not null
	,playerName nvarchar(100) not null
	,rawLore nvarchar(100) not null 
	,insertDate datetime not null default getdate()
	)
alter table rawLores add primary key clustered(characterName,playerName,rawLore)