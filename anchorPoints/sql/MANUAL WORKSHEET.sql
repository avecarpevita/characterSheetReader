use tm

select top 100 * from anchorChangelog where characterId='8M9ZY'
anchorChangelog order by 1 desc

select top 100 * from anchorChangelog where playerName like '%max%'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointchange,sourceFile,characterId)
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'Friday Night (9/18), 8:30m -- 2 AP' timeSlot,2 pointchange,'manual 20260913' sourceFile,characterId from anchorChangeLog where id=1967

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointchange,sourceFile,characterId)
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'Friday Night (9/18), 8:30m -- 2 AP' timeSlot,2 pointchange,'manual 20260913' sourceFile,characterId from anchorChangeLog where id=2512
	
select top 100 * from anchorChangelog where playerName like '%Bay%'

update a
	set a.TimeSlot='Saturday Night (9/19), 11:00pm, 1 AP', a.pointchange=1
	from anchorChangeLog a where id=2560
	
select top 100 * From anchorChangeLog where id=2590

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointchange,sourceFile,characterId)
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,3 pointchange,'manual 20260915' sourceFile,characterId from anchorChangeLog where id=2590


select top 100 * From anchorChangeLog where id=2602
delete anchorChangeLog where id=2602

--cxl from 8bvaz Saerest
select top 100 * From anchorChangeLog where characterId='8bvaz'
delete anchorChangeLog where id=2593

select top 100 * From anchorChangeLog where playername like '%cons%'
update a
	set a.pointchange=1, notes='only did a partial, the other half was scheduled advo shift'
	from anchorChangeLog a where id=2573


select top 100 * From anchorChangeLog where playername like '%jacob%'

--canceled over pms
delete a from anchorChangeLog a where id=2573

--get everybody from hexcrawl
select top 100 * from anchorChangeLog where playerName like '%stephen%'-	--8J6WX
select top 100 * from anchorChangeLog where playerName like '%valen%'		--76DWM
select top 100 * from anchorChangeLog where playerName like '%murphy%'		--8KG6R
select top 100 * from anchorChangeLog where playerName like '%camp%'		--8QJ4E
select top 100 * from anchorChangeLog where playerName like '%katt%'		--8M9ZY
select top 100 * from anchorChangeLog where playerName like '%ashford%'		--794PD
select top 100 * from anchorChangeLog where playerName like '%deshaz%'		--7E4ZE
select top 100 * from anchorChangeLog where playerName like '%lisa%'		--7BD4Y
select top 100 * from anchorChangeLog where playerName like '%luna%'		--7DZ9B
select top 100 * from anchorChangeLog where playerName like '%levi%'		--8D54B
select top 100 * from anchorChangeLog where playerName like '%nat%'			--8ZMNQ
select top 100 * from anchorChangeLog where playerName like '%alv%'			--8PQWR
select top 100 * from anchorChangeLog where playerName like '%grab%'		--7A4EX

select top 100 * from anchorChangeLog where playerName like '%deal%'		--7V6XB
select top 100 * from anchorChangeLog where playerName like '%cass%'		--8ARRV
select top 100 * from anchorChangeLog where playerName like '%jesse%'		--8VNMK
select top 100 * from anchorChangeLog where playerName like '%matt%'		--7VMXN
select top 100 * from anchorChangeLog where playerName like '%jerrod%'		--8GZXE
select top 100 * from anchorChangeLog where playerName like '%wong%'		--7J5ZW
select top 100 * from anchorChangeLog where playerName like '%melton%'		--7QYN9
select top 100 * from anchorChangeLog where playerName like '%corin%'		--8YQPE
select top 100 * from anchorChangeLog where playerName like '%silli%'		--8DDMP

select top 100 * from anchorChangeLog where playerName like '%alex%'		--8W6XB
select top 100 * from anchorChangeLog where playerName like '%ale%'			--7QMWX
select top 100 * from anchorChangeLog where playerName like '%nich%'		--8QDXY

select top 100 * from rawCPData where characterId in ('8J6WX','76DWM','8KG6R','8QJ4E','8M9ZY','794PD','7E4ZE','7BD4Y','7DZ9B','8D54B','8ZMNQ','8PQWR','7A4EX'
,'7V6XB','8ARRV','8VNMK','7VMXN','8GZXE','7J5ZW','7QYN9','8YQPE','8DDMP','8W6XB','7QMWX','8QDXY')


insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId in ('8J6WX','76DWM','8KG6R','8QJ4E','8M9ZY','794PD','7E4ZE','7BD4Y','7DZ9B','8D54B','8ZMNQ','8PQWR','7A4EX'
,'7V6XB','8ARRV','8VNMK','7VMXN','8GZXE','7J5ZW','7QYN9','8YQPE','8DDMP','8W6XB','7QMWX','8QDXY')


insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId in ('7N6XZ')
insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId in ('8M9NJ')


--substract the AP mod spends


select top 100 * from rawCPData where characterId in ('8QV4A','8B9P9','7VJX4','8VMJP','7ARG6','8K49R','7VMXN','8M9NJ','7N6XZ','8A6NQ','7JJNQ')


insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'S' eventType,'Event 93 September 2026' eventName,'AP Mod' timeSlot,-5 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId in ('8QV4A','8B9P9','7VJX4','8VMJP','7ARG6','8K49R','7VMXN','8M9NJ','7N6XZ','8A6NQ','7JJNQ')

exec buildAnchorPointSheet

select * from anchorChangeLog where characterId='8QV4A'
select sum(pointChange) from anchorChangeLog where characterId='8QV4A'


--Wesley Rockholzf flaked, but did reach out afterwards
delete anchorChangeLog where id=2633



select * from anchorChangeLog where playername like '%has%'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId in ('8J5GP')




select * from anchorChangeLog where playername like '%baxter%'
delete anchorChangeLog where id=2311

rawCPData where playerName like '%kelsi%'

select * from anchorChangeLog where id=1946

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 89 February 2026' eventName,'SatPMCarnival' timeSlot,3 pointChange,'manual 20260921' sourcefile,characterId
		from rawCPData where characterId='8XZPK'

select top 100 * from anchorChangeLog where playerName like '%hall%'


select top 100 * from anchorChangelog where playerName like '%pedersen%'

update a 
	set timeSlot='cxl '+timeSlot, pointChange=0, notes='was a no show, but did fess up later'
	from anchorChangeLog a where id in (2596,2597)

select top 100 * from anchorChangeLog where characterId='8KGJM'

select top 100 * from anchorChangeLog where playerName like '%mca%'

select top 100 * from anchorChangeLog where playerName like '%aurum%'
select top 100 * from anchorChangeLog where playerName like '%Steven Calise%'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 92 July 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260928' sourcefile,characterId
		from rawCPData where characterId in('85GKA','8J6WX','7V6ME')



select top 100 * from anchorChangelog where playerName like '%collin%'
insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 92 July 2026' eventName,'manual' timeSlot,2 pointChange,'manual 20260928' sourcefile,characterId
		from rawCPData where characterId in('8EDVE')
insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'manual' timeSlot,1 pointChange,'manual 20260928' sourcefile,characterId
		from rawCPData where characterId in('8EDVE')




select top 100 * from anchorChangelog where playerName like '%corin%'
insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 92 July 2026' eventName,'manual' timeSlot,2 pointChange,'manual 20260928' sourcefile,characterId
		from rawCPData where characterId in('8YQPE')


select top 100 * from anchorChangelog where characterId='86DG5' -- 
delete anchorChangelog where characterId='86DG5' and id=2512


select top 100 * from anchorChangelog where eventName like 'Event 93 September 2026'
select top 100 * from anchorChangelog where playerName like '%Bay%'--7A4EX. 2546

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,sourcefile,characterId) 
	select playerName,email,getdate() timestamp,'C' eventType,'Event 93 September 2026' eventName,'Friday Night (9/18), 8:30m -- 2 AP' timeSlot,2 pointChange,'manual 20261010' sourcefile,characterId
		from rawCPData where characterId in('7A4EX')

buildAnchorPointSheet

select * from anchorChangeLog where playerName like '%corin%' order by eventName

update a
	set pointChange=2, notes='both extra hour after hexcrawl, and extra before'
	from anchorChangeLog a where id=2681

select top 100 * from anchorChangeLog where characterId='T0245'--James Medina, false spend for Treatise
delete anchorChangeLog where id=2324