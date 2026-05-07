use tm


exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsMay26.tsv'
	, @eventName='Event 91 May 2026'
	, @doublePointSlots=null, @triplePointSlots=null
	, @whitelistCharacterIdList='7W6V9'

select * from anchorChangeLog where eventName='Event 91 May 2026' order by timeSlot--42 commitments, looks right

exec buildAnchorPointSheet--use this to update the private master


select * from anchorChangeLog a where eventName='Event 91 May 2026' and not exists (select null from rawCpData r where r.characterId=a.characterid)
