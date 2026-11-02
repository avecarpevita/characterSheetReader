use tm

/* this is the format for the .tsv files
drop table if exists #signupsRaw
create table #signupsRaw (
	timestamp varchar(255)
	,email nvarchar(255)
	,playerName nvarchar(255)
	,characterId nvarchar(255)
	,timeSlots varchar(1000)
	,check1 varchar(100)
	,combat1 varchar(255)
	)
*/

exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\nov26Fri1.tsv'
	, @eventName='Event 94 November 2026'
	, @possibleShifts='Friday Night (11/13), 8:30m -- 2 AP|Friday Night (11/13), 8:30m -- 1 NLP'
	--, @doublePointSlots=null, @triplePointSlots=null
	--, @whitelistCharacterIdList='8MG4R'

select * from anchorChangeLog where eventName='Event 94 November 2026' order by timeSlot--21, correct

exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\nov26Sat1.tsv'
	, @eventName='Event 94 November 2026'
	, @possibleShifts='Saturday Morning (11/14), 11:00am -- 1 AP'
	--, @doublePointSlots=null, @triplePointSlots=null
	, @whitelistCharacterIdList='8QRKJ|7N6JZ'

select * from anchorChangeLog where eventName='Event 94 November 2026' and timeslot='Saturday Morning (11/14), 11:00am -- 1 AP' order by timeSlot--26, correct


exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\nov26Sat2.tsv'
	, @eventName='Event 94 November 2026'
	, @possibleShifts='Saturday Afternoon (11/14) 3:30 pm -- 1 NLP|Saturday Afternoon (11/14) 3:30 pm -- 2 AP'
	--, @doublePointSlots=null, @triplePointSlots=null
	--, @whitelistCharacterIdList='8QRKJ|7N6JZ'

select * from anchorChangeLog where eventName='Event 94 November 2026' and timeslot='Saturday Afternoon (11/14) 3:30 pm -- 2 AP' order by timeSlot--11, correct



exec buildAnchorPointSheet--use this to update the private master


select * from anchorChangeLog a where eventName='Event 92 July 2026' and not exists (select null from rawCpData r where r.characterId=a.characterid)
