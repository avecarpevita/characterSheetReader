use tm

select top 100 * from anchorChangeLog where playerName like '%lily%'

select * from anchorChangeLog where playerName in ('James McCloskey','Lily Thiemens') order by playerName,timestamp

delete anchorChangeLog where id in (1293,1295)--2

exec buildAnchorPointSheet