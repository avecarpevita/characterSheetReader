use tm


exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsApr26.tsv', @eventName='Event 90 April 2026',@doublePointSlots=null, @triplePointSlots='FriPM3'

select * from anchorChangeLog where eventName='Event 90 April 2026' order by timeSlot

exec buildAnchorPointSheet--use this to update the private master


select * from anchorChangeLog a where eventName='Event 90 April 2026' and not exists (select null from rawCpData r where r.characterId=a.characterid)
