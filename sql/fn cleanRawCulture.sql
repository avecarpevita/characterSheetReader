use tm
go
create or alter function cleanRawCulture (@rawCulture nvarchar(100),@rawBloodline nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)
select @retval=ltrim(rtrim(@rawCulture))
--double spaces, *, quotes, "restricted Culture" normalized to R. Culture

if @retVal like '%citadel%' set @retVal='Cultural Effendal'
if @retVal like '%endurant%' set @retVal='Cultural Effendal'
if @retVal like '%Effendal%' set @retVal='Cultural Effendal'
if @retVal like '%Kaelin%' set @retVal='Cultural Effendal'
if @retVal like '%Delfestrae%' set @retVal='Cultural Effendal'
if @retVal like '%Oni''ven%' set @retVal='Cultural Effendal'
if @retVal like '%Etilvor%' set @retVal='Cultural Effendal'
if @retVal like '%Dace%' set @retVal='Dace'
if @retVal like '%Mandala%' set @retVal='Mandala'
if @retVal like '%Ad Decimum%' set @retVal='Ad Decimum'
if @retVal like '%Wayrest%' set @retVal='Wayrest'
if @retVal like '%Breach%' set @retVal='Breach'
if @retVal like '%Redemption%' set @retVal='Redemption'
if @retVal like '%Celestine%' set @retVal='The Celestine Empire'
if @retVal like '%Paradox%' set @retVal='Paradox: Dawn and Dusk'
if @retVal like '%Amalg%' set @retVal='Amalgamation'
if @retVal like '%Nadine%' set @retVal='The Nadine Empire'
if @retVal like '%Breach%' set @retVal='Breach'
if @retVal like '%Coatl%' set @retVal='Ko''aat'
if @retVal like '%Ko'' aat%' set @retVal='Ko''aat'
if @rawBloodline like '%newborn%' set @retVal='Newborn Dream - no culture'




return ltrim(rtrim(@retval))
end
/*

cleanRawCulture

*/