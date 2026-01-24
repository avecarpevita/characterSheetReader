use tm
go
create or alter function cleanRawCulture (@rawCulture nvarchar(100),@rawBloodline nvarchar(100))
returns nvarchar(100)
as
begin
declare @retval nvarchar(100)
select @rawCulture=ltrim(rtrim(@rawCulture))
--select dbo.CleanRawCulture('effendal','taco')

if @retval is null and @rawCulture like '%citadel%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%endurant%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Effendal%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Kaelin%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Delfestrae%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Oni''ven%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Etilvor%' begin; set @retVal='Cultural Effendal'; goto eoj; end

if @retval is null and @rawCulture like '%Castle%th%n%' begin; set @retVal='Castle Thorn'; goto eoj; end

if @retval is null and @rawCulture like '%Dace%' begin; set @retVal='Dace'; goto eoj; end

if @retval is null and @rawCulture like '%Mandala%' begin; set @retVal='Mandala'; goto eoj; end

if @retval is null and @rawCulture like '%Ad Decimum%' begin; set @retVal='Ad Decimum'; goto eoj; end

if @retval is null and @rawCulture like '%Wayrest%' begin; set @retVal='Wayrest'; goto eoj; end

if @retval is null and @rawCulture like '%Breach%' begin; set @retVal='Breach'; goto eoj; end

if @retval is null and @rawCulture like '%Redemption%' begin; set @retVal='Redemption'; goto eoj; end


if @retval is null and @rawCulture like '%Celestine%' begin; set @retVal='The Celestine Empire'; goto eoj; end

if @retval is null and @rawCulture like '%Paradox%' begin; set @retVal='Paradox: Dawn and Dusk'; goto eoj; end

if @retval is null and @rawCulture like '%Amalg%' begin; set @retVal='Amalgamation'; goto eoj; end

if @retval is null and @rawCulture like '%Hastings%' begin; set @retVal='Amalgamation'; goto eoj; end

if @retval is null and @rawCulture like '%Vein%' begin; set @retVal='Amalgamation'; goto eoj; end

if @retval is null and @rawCulture like '%Nadine%' begin; set @retVal='The Nadine Empire'; goto eoj; end

if @retval is null and @rawCulture like '%Breach%' begin; set @retVal='Breach'; goto eoj; end

if @retval is null and @rawCulture like '%Coatl%' begin; set @retVal='Ko''aat'; goto eoj; end

if @retval is null and @rawCulture like '%Ko'' aat%' begin; set @retVal='Ko''aat'; goto eoj; end

if @retval is null and @rawBloodline like '%newborn%' begin; set @retVal='Newborn Dream - no culture'; goto eoj; end

if @retval is null and @rawCulture like '%Coatl%' begin; set @retVal='Ko''aat'; goto eoj; end

if @retval is null set @retVal=@rawCulture


eoj:
return ltrim(rtrim(@retval))
end
/*

cleanRawCulture

*/