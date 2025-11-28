use tm
go
--drop function getReferralCount
create or alter function dbo.getReferralCount (@playerName nvarchar(100), @characterName nvarchar(100))
returns int
as
begin
declare @retval int=0

--select dbo.getReferralCount('Scott Ross','Gaeden')
--declare @characterName nvarchar(100)='Gaeden', @playerName nvarchar(100)='Scott Ross'; declare @retval int=0
select @retval=count(*) from rawEvents r with(nolock) where r.playerName=@playerName and r.characterName=@characterName
	and (
	r.eventName like '%NPR%' or r.eventName like '%New Player%' or r.eventName like '%Referral%'
		)




		
	
	

eoj:
return @retval
end
/*

cleanRawLore

*/