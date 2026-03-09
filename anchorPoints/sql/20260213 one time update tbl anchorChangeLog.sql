use tm

select * into anchorChangeLog_bak20260213 from anchorChangeLog

alter table anchorChangeLog add characterId char(5) 

drop table if exists #rawCPData
select *
	,row_number() over(partition by email,playerName order by try_cast(spentCP as int) desc) rn 
	into #rawCPData
	from rawCPData
delete #rawCPData where rn>1

update a
	set a.characterId=r.characterId
	from anchorChangeLog a join #rawCPData r on a.email=r.email and a.playerName=r.playerName--151

select * from anchorChangeLog where characterId is null--113--email is null or other stuff

update a
	set a.characterId=r.characterId
	from anchorChangeLog a join #rawCPData r on a.email=r.email where a.email is not null and a.characterId is null--10

update a
	set a.characterId=r.characterId
	from anchorChangeLog a join #rawCPData r on a.playerName=r.playerName where a.characterId is null--92


select * from anchorChangeLog where characterId is null--11 that just won't match
select distinct playerName from anchorChangeLog where characterId is null--11 that just won't match

update a
	set a.characterId=case playerName	
when 'Chris Rainey-Felley' then '7K4WB'
when 'Ismael F. Alvarez' then '86GKW'
when 'Jeffrey Gerard' then '7WJRW'
when 'Jesse Riley' then '8VNMK'
when 'Morgan Smith' then '7QYXJ'
when 'Nicole Hunsicker' then '8BZ4R' else null end
	from anchorChangeLog a where a.characterId is null

--now standardize names back

select * from anchorChangeLog a where not exists (select null from rawCpData r where r.characterId=a.characterId)

--look for REALLY off names first
select distinct a.playername,r.playername,a.characterId from anchorChangeLog a join rawCpData r on r.characterId=a.characterId
	where a.playerName<>r.playerName

update a
	set a.playerName=r.playerName
	from anchorChangeLog a join rawCpData r on r.characterId=a.characterId
	--264