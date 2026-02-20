use tm

select top 100 s.*,try_cast(c.spentCp as int) from rawCpData c join rawSkills s on c.playerName=s.playerName and c.characterName=s.characterName
	where s.rawSkill like '%lucen%'
	order by try_cast(c.spentCp as int)  desc

--also beacons
Castete Malutas	-- Andre Urbano
Azirael de Concord	-- Amanda McKibbin
Ghislain de Concord	-- Chance Brown
Sornin Genet	-- David Ziegert