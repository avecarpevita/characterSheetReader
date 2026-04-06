use tm

/*
APR26 -- sophia -- from bex		--select top 100 * from rawCPData where playerName like '%sophia%'		--8NQQP
--rotting returned				--select top 100 * from rawCPData where playerName like '%scharff%'		--8KNK5
--hexcrawl advos				--select top 100 * from rawCPData where playerName like '%cassidy%'		--8ARRV x3
--hexcrawl advos				--select top 100 * from rawCPData where playerName like '%michel%'		--7M4X5 x3
--hexcrawl advos				--select top 100 * from rawCPData where playerName like '%ethan%'		--7BDKY x3
--hexcrawl advos				--select top 100 * from rawCPData where playerName like '%melton%'		--7QYN9 x3
--hexcrawl advos				--select top 100 * from rawCPData where playerName like '%jerrod%'		--8GZXE x3
								--select top 100 * from rawCPData where playerName like '%matt%'		--7VMXN x3
								--select top 100 * from rawCPData where playerName like '%klas%'		--8DMRY x3
--decimal npcs					--nothing
--greater shades				--select top 100 * from rawCPData where playerName like '%jeremiah%'	--75GQK 
								--select top 100 * from rawCPData where playerName like '%teodosio%'	--7DZAZ 
--Quincys						--select top 100 * from rawCPData where playerName like '%ben%'			--8J5GP 
								--select top 100 * from rawCPData where playerName like '%ember%'		--8YAMX 
--manual re-entry				--select top 100 * from rawCPData where playerName like '%ken%han%'		--8ZZ4Q
*/

select top 100 * from anchorChangeLog order by eventName desc

select * from anchorChangeLog where sourcefile='manual20260406'
delete anchorChangeLog where sourcefile='manual20260406'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourceFile,characterId)
select playerName,email,getdate() as timestamp
	,'C' as eventType
	,'Event 90 April 2026' eventName
	,'FriPM3' timeSlot
	,case when characterId in ('8ARRV'
						   ,'7M4X5'
				   ,'7BDKY'
				   ,'7QYN9'
				   ,'8GZXE'
				   ,'7VMXN'
				   ,'8DMRY') then 3 else  1 end pointChange
	,'manual20260406' sourcefile
	,characterId
	from rawCPData
	where characterId in ('8NQQP'
						   ,'8KNK5'
						   ,'8ARRV'
						   ,'7M4X5'
				   ,'7BDKY'
				   ,'7QYN9'
				   ,'8GZXE'
				   ,'7VMXN'
				   ,'8DMRY'
				   ,'75GQK' 
				   ,'7DZAZ'
				   ,'8J5GP'
				   ,'8YAMX')
				   order by pointChange
				   --13



insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourceFile,characterId)
select playerName,email,getdate() as timestamp
	,'C' as eventType
	,'Event 90 April 2026' eventName
	,'SatPM' timeSlot
	,case when characterId in ('8ARRV'
						   ,'7M4X5'
				   ,'7BDKY'
				   ,'7QYN9'
				   ,'8GZXE'
				   ,'7VMXN'
				   ,'8DMRY') then 3 else  1 end pointChange
	,'manual20260406' sourcefile
	,characterId
	from rawCPData
	where characterId in ('8ZZ4Q')
				   order by pointChange
				   --13

