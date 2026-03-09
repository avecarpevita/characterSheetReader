use tm

drop table if exists anchorChangeLog 
create table anchorChangeLog (
	id int identity(1,1) not null primary key clustered
	,playerName varchar(100) not null
	,email varchar(100) null
	,timeStamp datetime not null
	,eventType char(1) not null
	,eventName nvarchar(25) not null
	,timeSlot varchar(6) null
	,spendReason varchar(255) null
	,pointChange int not null
	,notes varchar(max) null
	,sourcefile varchar(255) not null
	)

drop table if exists loreAbbrev 
create table loreAbbrev (
	loreAbbrev varchar(10) not null primary key clustered
	,loreDescription varchar(255) not null
	)

insert into loreAbbrev select 'ass','The Assassin''s Arts'
insert into loreAbbrev select 'sos','The School of Suffering'
insert into loreAbbrev select 'aet','Aethermancy'
insert into loreAbbrev select 'blo','Blood Sommelier'
insert into loreAbbrev select 'cat','Catacombs'
insert into loreAbbrev select 'hyd','Hydrology'
insert into loreAbbrev select 'lit','Lithoturgy'
insert into loreAbbrev select 'mag','Magical Theory'
insert into loreAbbrev select 'mmts','Mountain Meets the Sky'
insert into loreAbbrev select 'luc','Lucenturgy'
insert into loreAbbrev select 'pyr','Pyromancy'
insert into loreAbbrev select '6drag','Six Dragons'
insert into loreAbbrev select 'sou','Souls'
insert into loreAbbrev select 'Swanwall','Swanwall'
insert into loreAbbrev select 'ten','Tenebrimancy'
insert into loreAbbrev select 'thi','Thinniraid'
insert into loreAbbrev select 'treat','Treatise Methodologies'
insert into loreAbbrev select 'ruins','Ruins of Port Frey'

select * from loreAbbrev