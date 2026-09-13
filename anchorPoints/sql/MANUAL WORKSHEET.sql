use TM

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