use tm


exec applyAnchorCommitments @file='c:\characterSheetReader\anchorpoints\data\signupsApr26.tsv', @eventName='Event 90 April 2026',@doublePointSlots=null, @triplePointSlots='FriPM3'

--then pull the list to email to remind them of their commitments

select * from anchorChangeLog where eventType='C' and eventName='Event 90 April 2026'  order by timeSlot,playerName

--also look for people buying advo tickets they should not

select * from tickets where eventName='Event 90 April 2026' and ticketType like '%advo%' order by playerName