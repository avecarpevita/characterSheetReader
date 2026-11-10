use tm
go
create or alter function tempCharacterId (@playerName nvarchar(100), @characterName nvarchar(100))
returns varchar(5)
as
/*
select dbo.tempCharacterId('taco','tues')
select dbo.tempCharacterId('Olivia Lizardo','Lark Morrigan')

2026.11.09 -- revised to not use T, but the first characetr of playerName and characterNAME

	
*/
begin
declare @maxTempCharacterId varchar(5), @work int
declare @characterId varchar(5)
declare @p1 varchar(1), @c1 varchar(1)

SELECT @p1=upper(SUBSTRING(
    @playerName, 
    NULLIF(PATINDEX('%[a-zA-Z]%', @playerName), 0), 
    1
))
SELECT @c1=upper(SUBSTRING(
    @characterName, 
    NULLIF(PATINDEX('%[a-zA-Z]%', @characterName), 0), 
    1
))


select @work=max(substring(characterId,2,4)) from rawCpData where characterId like @p1+@c1+'%'
set @work=isnull(@work,0)
set @characterId=@p1+@c1++right('000'+convert(varchar,@work+1),3)



return @characterId
end
