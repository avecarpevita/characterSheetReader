drop table if exists #x
select row_number() over(order by rn,game,style) id,* into #x from tempxx

declare @id int, @participantRealNameRaw nvarchar(1000), @participantCharacterNameRaw nvarchar(1000), @participantRaw nvarchar(1000)
while (select count(*) from #x)>0
	begin
	select @id=min(id) from #x
	select @participantRaw=participantRaw from #x where id=@id
	begin try
		
		select @participantRealNameRaw=tm.dbo.parseParticipant(participantRaw,1) 
		,@participantCharacterNameRaw=tm.dbo.parseParticipant(participantRaw,0) 
		from #x where id=@id
	end try
	begin catch
		print '@id '+convert(varchar,@id)
		print 'participantRaw '+@participantRaw
	end catch

	delete #x where id=@id
	end

/*
@id 139
participantRaw Trainer&#45;- Justen Speratos&#45;- Azymondias Zysyss


select tm.dbo.parseParticipant('Trainer&#45;- Justen Speratos&#45;- Azymondias Zysyss',1) 

*/