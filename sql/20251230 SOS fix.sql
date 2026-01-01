use tm

select top 100 * from rawSkills where rawSkill like '%suff%'--22

select top 100 * from anchorChangeLog where spendReason like '%suff%'--only 6
Iris Do
Ismael F. Alvarez
Jordan Irby
Michael Whelchel
Nicole Hunsicker
Trevor Ryan

select top 100 * from rawSkills r where r.rawSkill like '%suff%'
	and not exists (select null from anchorChangeLog a where a.spendReason like '%suff%' and a.playerName=r.playerName)--

	anchorChangeLog where playerName like '%ronald%'--spend events is not parsing the comma on load

/*
Olivia Gobert-Hicks--staff
Nicole (Nyx) Hunsicker--name
Andre Urbano--staff
Ismael Alvarez--name
Connor Palacio--staff
Christopher Rainey-Felley--name
Gil Ramirez--staff
*/