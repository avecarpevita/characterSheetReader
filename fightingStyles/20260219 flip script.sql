use tm

drop table if exists #x
create table #x (bline varchar(255))
bulk insert #x from 'c:\temp\fightingFix.txt' with(datafiletype='char')

select *,substring(bline,patindex('% - %',bline)+3,255) characterName 
	,rtrim(left(bline,patindex('% - %',bline))) playerName
	,substring(bline,patindex('% - %',bline)+3,255)+' - '+rtrim(left(bline,patindex('% - %',bline))) fixed
	from #x