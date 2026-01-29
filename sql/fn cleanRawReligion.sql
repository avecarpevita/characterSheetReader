use tm
go
create or alter function cleanRawReligion (@rawReligion nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)
--double spaces, *, quotes, "restricted Religion" normalized to R. Religion

set @retVal=case 
when @rawReligion like '%old way%' then 'Old Ways'
when @rawReligion like '%Celestine%' then 'Celestine Faith'
when @rawReligion like '%Tree of Life%' then 'World Tree Faith'
when @rawReligion like '%World Tree%' then 'World Tree Faith'
when @rawReligion like '%Equilibrium%' then 'The Equilibrium'
when @rawReligion like '%Golden Choir%' then 'The Golden Choir'
when @rawReligion like '%Luck%' then 'Luck Faith'
when @rawReligion like '%Eden%' then 'Eden'
when @rawReligion like '%Xolo%' then 'Xolo'
when @rawReligion like '%Zodiac%' then 'Trahazi Zodiac'
when @rawReligion like '%Mist%' then 'Lady of the Mists'
when @rawReligion like '%Witch Queen%' then 'The Children of the Witch Queen'
when @rawReligion like '%Blood Cauldron%' then 'The Blood Cauldron'
when @rawReligion like '%gold%cho%' then 'The Golden Choir'
when @rawReligion like '%Chorus%' then 'Church of Chorus'
when @rawReligion like '%Mandala%' then 'Mandalan Faith'
when @rawReligion like '%Dragon Faith%' then 'Dragon Faith/Worship'
when @rawReligion like '%Dragon Worship%' then 'Dragon Faith/Worship'
when @rawReligion like '%Moon%' then 'Moon Faith'
else @rawReligion end



return ltrim(rtrim(@retval))
end
/*

cleanRawReligion

*/