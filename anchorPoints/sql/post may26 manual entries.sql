use tm

/*
MAY26 -- 

--rotting returned				--select top 100 * from rawCPData where playerName like '%cohen%'		--7A6BQ
								--select top 100 * from rawCPData where playerName like '%seki%'		--8W6PD
								--select top 100 * from rawCPData where playerName like '%oye%'			--8YANZ

--Quincys						--select top 100 * from rawCPData where playerName like '%aislin%'		--8XZWD 
								--select top 100 * from rawCPData where playerName like '%ethan b%'		--7BDKY 

--manual removal				--select top 100 * from rawCPData where playerName like '%justen%'		--8K49R 
*/

select top 100 * from anchorChangeLog order by eventName desc

select * from anchorChangeLog where sourcefile='manual20260519'
delete anchorChangeLog where sourcefile='manual20260519'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourceFile,characterId)
	select playerName,email,getdate() as timestamp
	,'C' as eventType
	,'Event 91 May 2026' eventName
	,'FriPM' timeSlot
	,1 pointChange
	,'manual20260519' sourcefile
	,characterId
	from rawCPData
	where characterId in ('7A6BQ','8W6PD','8YANZ','8XZWD','7BDKY')
				   order by pointChange
--5				   

select * from anchorChangeLog where characterId='8K49R' order by id desc
delete anchorChangeLog where id=2282--1

exec buildAnchorPointSheet