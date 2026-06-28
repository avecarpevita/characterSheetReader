use tm


exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsJul26.tsv'
	, @eventName='Event 92 July 2026'
	, @possibleShifts='Friday Night (7/10), 10pm -- 1 AP|Friday Night (7/10), 10pm -- 1 NLP|Saturday Night (7/11), 7:30pm, 1 NLP|Saturday Night (7/11), 7:30pm, 2 AP|Saturday Night (7/11), 9:00pm, 1 AP (note: this conflicts with the earlier 7:30 call)'
	--, @doublePointSlots=null, @triplePointSlots=null
	, @whitelistCharacterIdList='8MG4R'

select * from anchorChangeLog where eventName='Event 92 July 2026' order by timeSlot--55 commitments, looks right

exec buildAnchorPointSheet--use this to update the private master


select * from anchorChangeLog a where eventName='Event 92 July 2026' and not exists (select null from rawCpData r where r.characterId=a.characterid)
