use tm
go
create or alter function cleanRawLore (@rawLore nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)
select @retval=@rawLore
--double spaces, *, quotes, "restricted lore" normalized to R. Lore

set @retval=replace(@retval,'"','')
set @retval=replace(@retval,'''','')
set @retval=replace(@retval,'*','')
set @retval=replace(@retval,'restricted','R.')
while @retval like '%  %'
	select @retval=replace(@retval,'  ',' ') 
while @retval like '% :'
	set @retval=replace(@retval,' :',':')

set @retval=replace(@retval,'lore','Lore: ')
while @retval like '%: :%' 
	select @retval=replace(@retval,': :',':')

while @retval like '%::%' 
	select @retval=replace(@retval,'::',':')
--must be ': ' after lore
set @retval=stuff(@retval,patindex('%:%',@retval), 2,': ')
while @retval like '%  %'
	select @retval=replace(@retval,'  ',' ') 




	
--remove anything with "POK Lore"
if @retval like '%POK%Lore%' set @retval=null

--handle the (magic) 



return ltrim(rtrim(@retval))
end
/*

cleanRawLore

*/