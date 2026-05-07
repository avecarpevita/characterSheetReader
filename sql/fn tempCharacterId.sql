use tm
go
create or alter function tempCharacterId (@playerName nvarchar(100), @characterName nvarchar(100))
returns varchar(5)
as
/*
select dbo.tempCharacterId('taco','tues')
select dbo.tempCharacterId('Olivia Lizardo','Lark Morrigan')

	
*/
begin
declare @maxTempCharacterId varchar(5), @work int
declare @characterId varchar(5)
--select @characterId=characterId from rawSkills r where r.playerName=@playerName and r.characterName=@characterName
--if nullif(@characterId,'') is null
--	select @characterId=characterId from rawCpData r where r.playerName=@playerName and r.characterName=@characterName
--if nullif(@characterId,'') is null
--	begin
	select @work=max(substring(characterId,2,4)) from rawCpData where characterId like 'T%'
	set @work=isnull(@work,0)
	set @characterId='T'+right('000'+convert(varchar,@work+1),4)
	--end



return @characterId
end
