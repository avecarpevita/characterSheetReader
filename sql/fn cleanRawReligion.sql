use tm
go
create or alter function cleanRawReligion (@rawReligion nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)
select @retval=ltrim(rtrim(@rawReligion))
--double spaces, *, quotes, "restricted Religion" normalized to R. Religion

if @retVal like '%old way%' set @retVal='Old Ways'
if @retVal like '%Celestine%' set @retVal='Celestine Faith'
if @retVal like '%Tree of Life%' set @retVal='World Tree Faith'
if @retVal like '%World Tree%' set @retVal='World Tree Faith'
if @retVal like '%Equilibrium%' set @retVal='The Equilibrium'
if @retVal like '%Luck%' set @retVal='Luck Faith'
if @retVal like '%Eden%' set @retVal='Eden'
if @retVal like '%Xolo%' set @retVal='Xolo'
if @retVal like '%Zodiac%' set @retVal='Trahazi Zodiac'
if @retVal like '%Mist%' set @retVal='Lady of the Mists'
if @retVal like '%Witch Queen%' set @retVal='The Children of the Witch Queen'
if @retVal like '%Blood Cauldron%' set @retVal='The Blood Cauldron'
if @retVal like '%gold%cho%' set @retVal='The Golden Choir'
if @retVal like '%Chorus%' set @retVal='Church of Chorus'




return ltrim(rtrim(@retval))
end
/*

cleanRawReligion

*/