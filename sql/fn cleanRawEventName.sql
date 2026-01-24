
use tm
go
create or alter function cleanRawEventName (@eventName nvarchar(100),@eventDate nvarchar(100))
returns nvarchar(100)
begin
declare @retval nvarchar(100)
set @retVal=case 
	when @eventName like '%event 74%' then 'Event 74 February 2024'
	when @eventName like '%event 75%' then 'Event 75 March 2024'
	when @eventName like '%event 76%' then 'Event 76 April 2024'
	when @eventName like '%event 77%' then 'Event 77 July 2024'
	when @eventName like '%event 78%' then 'Event 78 August 2024'
	when @eventName like '%event 79%' then 'Event 79 September 2024'
	when @eventName like '%event 80%' then 'Event 80 November 2024'
	when @eventName like '%event 81%' then 'Event 81 December 2024'
	when @eventName like '%event 82%' then 'Event 82 February 2025'
	when @eventName like '%event 83%' then 'Event 83 March 2025'
	when @eventName like '%event 84%' then 'Event 84 April 2025'
	when @eventName like '%event 85%' then 'Event 85 August 2025'
	when @eventName like '%event 86%' then 'Event 86 September 2025' 
	when @eventName like '%event 87%' then 'Event 87 December 2025' 
	when try_cast(@eventDate as date) between '2024.02.01' and '2024.02.29' then 'Event 74 February 2024'
	when try_cast(@eventDate as date) between '2024.03.01' and '2024.03.31' then 'Event 75 March 2024'
	when try_cast(@eventDate as date) between '2024.04.01' and '2024.04.30' then 'Event 76 April 2024'
	when try_cast(@eventDate as date) between '2024.07.01' and '2024.07.31' then 'Event 77 July 2024'
	when try_cast(@eventDate as date) between '2024.08.01' and '2024.08.31' then 'Event 78 August 2024'
	when try_cast(@eventDate as date) between '2024.09.01' and '2024.09.30' then 'Event 79 September 2024'
	when try_cast(@eventDate as date) between '2024.11.01' and '2024.11.30' then 'Event 80 November 2024'
	when try_cast(@eventDate as date) between '2024.12.01' and '2024.12.31' then 'Event 81 December 2024'
	when try_cast(@eventDate as date) between '2025.02.01' and '2025.02.28' then 'Event 82 Feb 2025'
	when try_cast(@eventDate as date) between '2025.03.01' and '2025.03.31' then 'Event 83 March 2025'
	when try_cast(@eventDate as date) between '2025.04.01' and '2025.04.30' then 'Event 84 April 2025'
	when try_cast(@eventDate as date) between '2025.08.01' and '2025.08.31' then 'Event 85 August 2025'
	when try_cast(@eventDate as date) between '2025.09.01' and '2025.09.30' then 'Event 85 September 2025'
	when try_cast(@eventDate as date) between '2025.12.01' and '2025.12.31' then 'Event 87 December 2025'
		else null end

eoj:
return ltrim(rtrim(@retval))
end