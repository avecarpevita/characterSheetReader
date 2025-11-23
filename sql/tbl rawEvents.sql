use tm
go
drop table if exists rawEvents
create table rawEvents (
	characterName nvarchar(100) not null
	,playerName nvarchar(100) not null
	,eventName nvarchar(100) not null
	,eventDate nvarchar(100) not null
	,insertDate datetime not null default getdate()
	)
alter table rawEvents add primary key clustered(characterName,playerName,eventName)