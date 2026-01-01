use tm
go
create or alter function parseParticipant (@rawParticipant nvarchar(100), @frontOrBack bit=0)
returns varchar(50)
as
/*
print dbo.parseParticipant('taco - greg',0) 
*/
begin
declare @retVal varchar(50)=null
declare @realName varchar(50)=null
declare @characterName varchar(50)=null
DECLARE @CharsToKill VARCHAR(50) = '0123456789.';



SELECT @rawParticipant=
    REPLACE(
        TRANSLATE(@rawParticipant, @CharsToKill, REPLICATE('*', LEN(@CharsToKill))), 
        '*', 
        ''
    ) 


	
--if there is only one dash it is easy
if @realName is null and len(@rawParticipant)-len(replace(@rawParticipant,'-',''))=1
	begin
	set @realName=convert(varchar(50),left(@rawParticipant,patindex('%-%',@rawParticipant)-1))
	set @characterName=convert(varchar(50),substring(@rawParticipant,patindex('%-%',@rawParticipant)+1,255))
	end
if @realName is null and len(@rawParticipant)-len(replace(@rawParticipant,'-',''))=2
	begin
	set @realName=replace(convert(varchar(50),left(@rawParticipant,patindex('% - %',@rawParticipant)-1)),' - ','')
	set @characterName=convert(varchar(50),substring(@rawParticipant,patindex('% - %',@rawParticipant)+1,255))
	end


eoj:
if @frontOrBack=1 set @retVal=@characterName 
	else set @retVal=@realName
return replace(ltrim(rtrim(@retVal)),'- ','')
end