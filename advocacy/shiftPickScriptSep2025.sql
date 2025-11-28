--use work
use tm

--get the form loaded
drop table if exists #shiftFormRaw--select * from #shiftFormRaw where advocateName like 'kil%'
create table #shiftFormRaw (
	xTimestamp varchar(255)
	--,email varchar(255)--2025.02.14, I removed this, I did not need it any more
	,advocateName varchar(255)
	,logiStory varchar(255)
	,advocateLevel varchar(255)
	,preferredShift varchar(255)
	,blockedShift varchar(255)
	)
bulk insert #shiftFormRaw from 'c:\temp\sep25.tsv' with(datafiletype='char',firstrow=2)
--select * From #shiftFormRaw where advocatename is null
delete #shiftFormRaw where advocatename is null
--select * from #shiftFormRaw where preferredShift='On Call [full logi advocate only] (read the details above before signing up)'
update #shiftFormRaw set preferredShift='On Call [full advocate only]' where preferredShift='On Call [full logi advocate only] (read the details above before signing up)'
--forcing Joshua Branch into sunday shift, so removing from raw
--select * from #shiftFormRaw where advocatename like '%josh%'
--delete #shiftFormRaw where advocatename like '%josh%branch%'
--select top 100 * from #shiftFormRaw where preferredShift like 'SUN%'--sidney and Ivy are the only signups
--I have to exclude Sidney from 

--select * from #shiftFormRaw where advocatename='Jennifer Klasing'
--select * from #shiftFormRaw
--select * from #shiftFormRaw where advocateName like '%jir%'
--#shiftFormRaw where preferredShift like '%aiden%'
--#shiftFormRaw where advocateName like '%ev%'--
--#shiftFormRaw where advocateName like '%sid%'--
;with cte as (select *,row_number() over(partition by advocateName order by convert(datetime,xTimeStamp) desc) rn from #shiftFormRaw) --select * from #shiftFormRaw where advocateName in (select advocateName from cte where rn>1)
	delete cte where rn>1

--select logiStory,advocateLevel,count(*) from #shiftFormRaw group by logiStory,advocateLevel order by 1,2

drop table if exists #shiftForm
select *,row_number() over(order by case when advocateLevel like '%veteran%' then 1 else 0 end--veterans go to the "end", and get hand placed
	,newid()) rn 
	,convert(varchar(255),null) assignedShift
	,case when advocateLevel like '%trainee%' then 'Yes' 
		when advocateLevel like '%veteran%' then 'Vet'
		else 'No' end trainee
			
	into #shiftForm from #shiftFormRaw

--select * from #shiftForm where advocateName like 'Kil%'




--build out the available shifts
drop table if exists #allShifts
create table #allShifts (
	shiftOrder int identity(1,1) not null primary key clustered
	,[shift] varchar(255) not null
	,[prevShift] varchar(255) null
	,[nextShift] varchar(255) null
	)
	

insert into #allShifts([shift],prevShift,nextShift) select 'FRI 4pm-8pm [Full Logi Only]',null,'FRI 8pm-12am'
insert into #allShifts([shift],prevShift,nextShift) select 'FRI 8pm-12am','FRI 4pm-8pm [Full Logi Only]','FRI 10pm-2am'
insert into #allShifts([shift],prevShift,nextShift) select 'FRI 10pm-2am','FRI 8pm-12am','SAT Midnight-4am [Logi Only]'
--insert into #allShifts([shift],prevShift,nextShift) select 'SAT Midnight-4am [Logi Only]','FRI 10pm-2am',null
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 8am-Noon',null,'SAT 10am-2pm'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 10am-2pm','SAT 8am-Noon','SAT Noon-4pm'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT Noon-4pm','SAT 10am-2pm','SAT 2pm-6pm'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 2pm-6pm','SAT Noon-4pm','SAT 4pm-8pm'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 4pm-8pm','SAT 2pm-6pm','SAT 6pm-10pm'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 6pm-10pm','SAT 4pm-8pm','SAT 8pm-Midnight'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 8pm-Midnight','SAT 6pm-10pm','SAT 10pm-2am'
insert into #allShifts([shift],prevShift,nextShift) select 'SAT 10pm-2am','SAT 8pm-Midnight','SUN Midnight-4am [Logi Only]'
--insert into #allShifts([shift],prevShift,nextShift) select 'SUN Midnight-4am [Logi Only]','SAT 10pm-2am',null
insert into #allShifts([shift],prevShift,nextShift) select 'SUN 8am-Noon [Logi Only]',null,null
insert into #allShifts([shift],prevShift,nextShift) select 'SUN 10am-2pm [Logi Only]',null,null
--insert into #allShifts([shift],prevShift,nextShift) select 'SUN 10am-2pm [Logi Only]','SUN 8am-Noon [Logi Only]',null
insert into #allShifts([shift],prevShift,nextShift) select 'On Call [full advocate only]',null,null

--build out the shiftGrid
if object_id('tempdb..#shiftGrid')<>0 drop table #shiftGrid
select a.* 
	,'Logi' logiStory
	,'No' Trainee
	,convert(varchar(255),null) advocate
	into #shiftGrid
	from #allShifts a
union select a.* 
	,'Logi' logiStory
	,'Yes' Trainee
	,convert(varchar(255),null) advocate
	from #allShifts a where [shift] not like '%Full Logi Only%' and [shift] not like '%full%'
union select a.* 
	,'Story' logiStory
	,'No' Trainee
	,convert(varchar(255),null) advocate
	from #allShifts a where [shift] not like '%Logi%'
union select a.* 
	,'Story' logiStory
	,'Yes' Trainee
	,convert(varchar(255),null) advocate
	from #allShifts a where [shift] not like '%Logi%'	and [shift] not like '%full%'
create unique clustered index slt on #shiftGrid([shift],logiStory,trainee)
--select * from #shiftGrid order by 1

--hard forces go here
--force Josh Branch into Sunday
--select top 100 * from #shiftGrid where shift='SUN 8am-Noon [Logi Only]'  and Trainee='No'
--update s 
--    set advocate='Joshua Branch'
--    from #shiftGrid s where shift='SUN 8am-Noon [Logi Only]' and Trainee='No'

if object_id('tempdb..#work')<>0 drop table #work
select * into #work from #shiftForm 
--select * from #work 

if object_id('tempdb..#availShifts')<>0 drop table #availShifts
select * 
		,0 shiftDistance
		into #availShifts 
		from #shiftGrid s 


declare @rn int, @pShift varchar(255), @bShift varchar(255), @advocate varchar(255), @pShiftOrder int, @assignedShift varchar(255)
declare @logiStory varchar(255)='Logi'
declare @trainee varchar(255)='No'


--this code is repeated for each block, resetting the above variables

truncate table #work
insert into #work select * from #shiftForm where logiStory=@logiStory and trainee=@trainee
while (select count(*) from #work)>0
	begin
	select @rn=min(rn) from #work
	select @pShift=preferredShift,@bShift=blockedShift, @advocate=advocateName from #work where rn=@rn
	select @pShiftOrder=shiftOrder from #allShifts where [shift]=@pShift
	--get all available shifts for this advo
	
	truncate table #availShifts
	insert into #availShifts select * 
		,abs(@pShiftOrder-shiftOrder) shiftDistance
		from #shiftGrid s where logiStory=@logiStory and trainee=@trainee 
			and (@trainee='No'
				or exists (select null from #shiftGrid si where si.[shift]=s.[shift] and logiStory=@logiStory and trainee='No' and advocate is not null)
				)
	--modify for preferred shift = On Call [full advocate only]
	if @pShift='On Call [full advocate only]'
		update #availShifts set shiftDistance=-1 where [shift]='On Call [full advocate only]'
	else
		delete #availShifts where [shift]='On Call [full advocate only]'

	--delete any shifts blocked or adjacent to the blocked
	;with cte as (select [shift] from #allShifts where [shift]=@bShift
		union select prevShift from #allShifts where [shift]=@bShift
		union select nextShift from #allShifts where [shift]=@bShift)
	delete a from #availShifts a join cte c on c.[shift]=a.[shift] 
	--delete any shifts already assigned
	delete a from #availShifts a join #shiftGrid s on s.[shift]=a.[shift] and s.logiStory=@logiStory and s.trainee=@trainee 
		where s.advocate is not null
	--delete the closest remaining shift to the preferred shift
	set @assignedShift=null
	;with cte as (select *,row_number() over(order by shiftDistance,newid()) anum from #availShifts)
		select @assignedShift=[shift] from cte where anum=1
	--update #shiftGrid
	update s
		set advocate=@advocate
		from #shiftGrid s where s.logiStory=@logiStory and s.trainee=@trainee and [shift]=@assignedShift
	--update #shiftForm
	update s
		set assignedShift=@assignedShift
		from #shiftForm s where advocateName=@advocate

	delete #work where rn=@rn
	end



set @logiStory='Logi'
set @trainee='Yes'


--this code is repeated for each block, resetting the above variables
truncate table #work
insert into #work select * from #shiftForm where logiStory=@logiStory and trainee=@trainee
while (select count(*) from #work)>0
	begin
	select @rn=min(rn) from #work
	select @pShift=preferredShift,@bShift=blockedShift, @advocate=advocateName from #work where rn=@rn
	select @pShiftOrder=shiftOrder from #allShifts where [shift]=@pShift
	--get all available shifts for this advo
	truncate table #availShifts
	insert into #availShifts select * 
		,abs(@pShiftOrder-shiftOrder) shiftDistance
		from #shiftGrid s where logiStory=@logiStory and trainee=@trainee 
			and (@trainee='No'
				or exists (select null from #shiftGrid si where si.[shift]=s.[shift] and logiStory=@logiStory and trainee='No' and advocate is not null)
				)
	--modify for preferred shift = On Call [full advocate only]
	if @pShift='On Call [full advocate only]'
		update #availShifts set shiftDistance=-1 where [shift]='On Call [full advocate only]'
	else
		delete #availShifts where [shift]='On Call [full advocate only]'


	--delete any shifts blocked or adjacent to the blocked
	;with cte as (select [shift] from #allShifts where [shift]=@bShift
		union select prevShift from #allShifts where [shift]=@bShift
		union select nextShift from #allShifts where [shift]=@bShift)
	delete a from #availShifts a join cte c on c.[shift]=a.[shift] 
	--delete any shifts already assigned
	delete a from #availShifts a join #shiftGrid s on s.[shift]=a.[shift] and s.logiStory=@logiStory and s.trainee=@trainee 
		where s.advocate is not null
	--delete the closest remaining shift to the preferred shift
	set @assignedShift=null
	;with cte as (select *,row_number() over(order by shiftDistance,newid()) anum from #availShifts)
		select @assignedShift=[shift] from cte where anum=1
	--update #shiftGrid
	update s
		set advocate=@advocate
		from #shiftGrid s where s.logiStory=@logiStory and s.trainee=@trainee and [shift]=@assignedShift
	--update #shiftForm
	update s
		set assignedShift=@assignedShift
		from #shiftForm s where advocateName=@advocate

	delete #work where rn=@rn
	end




set @logiStory='Story'
set @trainee='No'


--this code is repeated for each block, resetting the above variables
truncate table #work
insert into #work select * from #shiftForm where logiStory=@logiStory and trainee=@trainee
while (select count(*) from #work)>0
	begin
	select @rn=min(rn) from #work
	select @pShift=preferredShift,@bShift=blockedShift, @advocate=advocateName from #work where rn=@rn
	select @pShiftOrder=shiftOrder from #allShifts where [shift]=@pShift
	--get all available shifts for this advo
	truncate table #availShifts
	insert into #availShifts select * 
		,abs(@pShiftOrder-shiftOrder) shiftDistance
		from #shiftGrid s where logiStory=@logiStory and trainee=@trainee 
			and (@trainee='No'
				or exists (select null from #shiftGrid si where si.[shift]=s.[shift] and logiStory=@logiStory and trainee='No' and advocate is not null)
				)
	--modify for preferred shift = On Call [full advocate only]
	if @pShift='On Call [full advocate only]'
		update #availShifts set shiftDistance=-1 where [shift]='On Call [full advocate only]'
	else
		delete #availShifts where [shift]='On Call [full advocate only]'

	--delete any shifts blocked or adjacent to the blocked
	;with cte as (select [shift] from #allShifts where [shift]=@bShift
		union select prevShift from #allShifts where [shift]=@bShift
		union select nextShift from #allShifts where [shift]=@bShift)
	delete a from #availShifts a join cte c on c.[shift]=a.[shift] 
	--delete any shifts already assigned
	delete a from #availShifts a join #shiftGrid s on s.[shift]=a.[shift] and s.logiStory=@logiStory and s.trainee=@trainee 
		where s.advocate is not null
	--delete the closest remaining shift to the preferred shift
	set @assignedShift=null
	;with cte as (select *,row_number() over(order by shiftDistance,newid()) anum from #availShifts)
		select @assignedShift=[shift] from cte where anum=1
	--update #shiftGrid
	update s
		set advocate=@advocate
		from #shiftGrid s where s.logiStory=@logiStory and s.trainee=@trainee and [shift]=@assignedShift
	--update #shiftForm
	update s
		set assignedShift=@assignedShift
		from #shiftForm s where advocateName=@advocate

	delete #work where rn=@rn
	end

set @logiStory='Story'
set @trainee='Yes'


--this code is repeated for each block, resetting the above variables
truncate table #work
insert into #work select * from #shiftForm where logiStory=@logiStory and trainee=@trainee
while (select count(*) from #work)>0
	begin
	select @rn=min(rn) from #work
	select @pShift=preferredShift,@bShift=blockedShift, @advocate=advocateName from #work where rn=@rn
	select @pShiftOrder=shiftOrder from #allShifts where [shift]=@pShift
	--get all available shifts for this advo
	truncate table #availShifts
	insert into #availShifts select * 
		,abs(@pShiftOrder-shiftOrder) shiftDistance
		from #shiftGrid s where logiStory=@logiStory and trainee=@trainee 
			and (@trainee='No'
				or exists (select null from #shiftGrid si where si.[shift]=s.[shift] and logiStory=@logiStory and trainee='No' and advocate is not null)
				)
	--modify for preferred shift = On Call [full advocate only]
	if @pShift='On Call [full advocate only]'
		update #availShifts set shiftDistance=-1 where [shift]='On Call [full advocate only]'
	else
		delete #availShifts where [shift]='On Call [full advocate only]'

	--delete any shifts blocked or adjacent to the blocked
	;with cte as (select [shift] from #allShifts where [shift]=@bShift
		union select prevShift from #allShifts where [shift]=@bShift
		union select nextShift from #allShifts where [shift]=@bShift)
	delete a from #availShifts a join cte c on c.[shift]=a.[shift] 
	--delete any shifts already assigned
	delete a from #availShifts a join #shiftGrid s on s.[shift]=a.[shift] and s.logiStory=@logiStory and s.trainee=@trainee 
		where s.advocate is not null
	--delete the closest remaining shift to the preferred shift
	set @assignedShift=null
	;with cte as (select *,row_number() over(order by shiftDistance,newid()) anum from #availShifts)
		select @assignedShift=[shift] from cte where anum=1
	--update #shiftGrid
	update s
		set advocate=@advocate
		from #shiftGrid s where s.logiStory=@logiStory and s.trainee=@trainee and [shift]=@assignedShift
	--update #shiftForm
	update s
		set assignedShift=@assignedShift
		from #shiftForm s where advocateName=@advocate

	delete #work where rn=@rn
	end

--final grid pivoted out
;with cte as (select distinct shiftOrder,[shift] from #shiftGrid)
select d.shiftOrder
	,d.[shift]
	,isnull(lt.advocate,'') LogiTrainee
	,isnull(lf.advocate,'') LogiFull
	,isnull(st.advocate,'') StoryTrainee	
	,isnull(sf.advocate,'') StoryFull
	from cte d
		left join #shiftGrid lf on lf.shiftOrder=d.shiftOrder and lf.logiStory='Logi' and lf.trainee='No'--select * from #shiftGrid 
		left join #shiftGrid lt on lt.shiftOrder=d.shiftOrder and lt.logiStory='Logi' and lt.trainee='Yes'
		left join #shiftGrid sf on sf.shiftOrder=d.shiftOrder and sf.logiStory='Story' and sf.trainee='No'
		left join #shiftGrid st on st.shiftOrder=d.shiftOrder and st.logiStory='Story' and st.trainee='Yes'
	order by 1
		

--unassigned
select * from #shiftForm where assignedShift is null 
	and logiStory='Story'
	order by newid()--looks like all story trainees, this time around I'll handle it manually
select * from #shiftForm where assignedShift is null 
	and logiStory='Logi'
	order by newid()--looks like all story trainees, this time around I'll handle it manually


/*	

select * from #shiftForm where assignedShift is null and advocateLevel like '%veteran%'--none, they have to be hand placed


*/