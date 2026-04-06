use tm

--C:\characterSheetReader\influenceAndResearch
drop table if exists #research
--Timestamp	Email Address	What is your ticket number?	What is your real name?	What is the name of your character?	What is your Character Id?	What is the Character Id for Assistant #1?	What is the Character Id for Assistant #2?	What were the libraries or research objects used?	What is the topic of the research?	What are you trying to accomplish with this research?	What story staff member are you targeting with this research, if any?
create table #research (
	[timestamp] datetime
	,email varchar(255)
	,ticketNum varchar(255)
	,playerName varchar(255)
	,characterName varchar(255)
	,characterId varchar(5)
	,assistant1 varchar(5)
	,assistant2 varchar(5)
	,researchObject varchar(255)
	,researchTopic varchar(max)
	,goal varchar(max)
	,storyStaff varchar(100)
	)
bulk insert #research from 'C:\characterSheetReader\influenceAndResearch\apr26Research.tsv' with(datafiletype='char',firstrow=2)



--select * from #research r where not exists (Select null from rawSkills s where r.characterId=s.characterId)
--select * from #research r where not exists (Select null from rawSkills s where r.assistant1=s.characterId)
--select * from #research r where not exists (Select null from rawSkills s where r.assistant2=s.characterId)

--Timestamp	Email Address	What is your ticket number?	What is your real name?	What is the name of your character?	What is your Character Id?	What influence action did you perform?	What additional details or targeting apply to this action (i.e. what faction, area or person are you targeting with this action, where that is applicable?)	What are you trying to accomplish with this influence acition?	What story staff member are you targeting with this action, if any?
drop table if exists #influence
create table #influence (
	[timestamp] datetime
	,email varchar(255)
	,ticketNum varchar(255)
	,playerName varchar(255)
	,characterName varchar(255)
	,characterId varchar(5)
	,influenceAction varchar(255)
	,influenceDetail varchar(max)
	,goal varchar(max)
	,storyStaff varchar(255)
)

bulk insert #influence from 'C:\characterSheetReader\influenceAndResearch\apr26Political.tsv' with(datafiletype='char', firstrow=2)
bulk insert #influence from 'C:\characterSheetReader\influenceAndResearch\apr26Underworld.tsv' with(datafiletype='char', firstrow=2)
bulk insert #influence from 'C:\characterSheetReader\influenceAndResearch\apr26AEM.tsv' with(datafiletype='char', firstrow=2)


--combine
drop table if exists #combine
select [timestamp],email,ticketNum,playerName,characterName,characterId,'open-ended research' as [action] 
	,'research topic: '+researchTopic as [actionDetail]
	,'goal: '+goal as [actionGoal]
	,'research object(s): '+researchObject as actionDetail2
	,'researcher lores: '+(select string_agg(dbo.cleanRawLore(rawSkill),', ') from rawSkills s where s.characterId=r.characterId and s.rawSkill like '%lore%') as actionDetail3
	,'assistant lores: '+(select string_agg(dbo.cleanRawLore(rawSkill),', ') from rawSkills s where s.characterId in (r.assistant1,r.assistant2) and s.rawSkill like '%lore%') as actionDetail4
	into #combine
	from #research r
union all
select [timestamp],email,ticketNum,playerName,characterName,characterId,influenceAction as [action] 
	,influenceDetail as [actionDetail]
	,goal as [actionGoal]
	,'' actionDetail2
	,'' actionDetail3
	,'' actionDetail4
	from #influence
		


--look for anomolous or duped tickets
select * from #combine
delete #combine where ticketNum='4JJ3NNYU'


