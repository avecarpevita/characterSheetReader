use tm
go
drop table if exists rawCpData
create table rawCpData (
	characterName nvarchar(100) not null
	,playerName nvarchar(100) not null
	,spentCP nvarchar(100) not null 
	,corruption nvarchar(100) not null 
	--2026.01.21--added characterId, email, culture, religion, bloodline(race), hp, mana, ip
	,characterId nvarchar(100) not null
	,email nvarchar(100) not null
	,culture nvarchar(100) not null
	,religion nvarchar(100) not null
	,bloodline nvarchar(100) not null
	,hp nvarchar(100) not null
	,mana nvarchar(100) not null
	,[ip] nvarchar(100) not null

	,insertDate datetime not null default getdate()
	)
alter table rawCpData add primary key clustered(characterName,playerName)
create index p on rawCpData(playerName)



