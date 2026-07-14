use tm

anchorChangeLog where characterId='7E4ZE'

insert into anchorChangeLog (playerName,email,timestamp,eventType,eventName,timeSlot,pointChange,notes,sourcefile,characterId)
	select playerName	
		,email
		,getdate()
		,'C'
		,'Event 92 July 2026'
		,'manual'
		,1
		,'extra npc'
		,'manual 20260713'
		,characterId
		from rawCPData where characterId in ('7E4ZE','','','')
