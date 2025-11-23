use tm
go
drop table if exists rawCpData
create table rawCpData (
	characterName nvarchar(100) not null
	,playerName nvarchar(100) not null
	,spentCP nvarchar(100) not null 
	,corruption nvarchar(100) not null 
	,insertDate datetime not null default getdate()
	)
alter table rawCpData add primary key clustered(characterName,playerName)