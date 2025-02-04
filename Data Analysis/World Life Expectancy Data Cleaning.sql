use world_life_expectancy; 

# cloning original data
create table world_life_expectancy_backup like world_life_expectancy;
insert into world_life_expectancy_backup select * from world_life_expectancy;

# view the data
select * from world_life_expectancy;

########################## Remove Duplicate ##########################
# Note: should not have same country & year at the same time
select 
	Country, 
    `Year`, 
    concat(Country, `Year`), 
    count(concat(Country, `Year`)) as cnt
from world_life_expectancy
group by Country, `Year`
having cnt > 1
;
select 
	*
from (
	select 
		Row_ID, 
		concat(Country, `Year`), 
		row_number() over(partition by concat(Country, `Year`) order by concat(Country, `Year`)) as row_num
	from world_life_expectancy
    ) as row_tab
where row_num > 1
;
delete from world_life_expectancy
where Row_ID in (
	select 
		Row_ID
	from (
		select 
			Row_ID, 
			concat(Country, `Year`), 
			row_number() over(partition by concat(Country, `Year`) 
							  order by concat(Country, `Year`)) as row_num
		from world_life_expectancy
		) as row_tab
	where row_num > 1
	)
;


########################## Dealing with Status null/blank values ##########################
select distinct `Status` from world_life_expectancy;
# Note: No null values but there are blank in Status 
# Status can be 'Developing' or 'Developed'. So blank values can be inferred from same country of other years

# Note that the update below will not work
update world_life_expectancy
set `Status` = 'Developing' 
where Country in (
	select distinct(country) 
    from world_life_expectancy
    where `Status` = 'Developing'
	)
;
# But the update below will work
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
set t1.`Status` = 'Developing' 
where 
	t1.`Status` = '' 
	and t2.`Status` != ''
    and t2.`Status` = 'Developing'
;
# similarly, fill blanks for Developed countries
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
set t1.`Status` = 'Developed' 
where 
	t1.`Status` = '' 
	and t2.`Status` != ''
    and t2.`Status` = 'Developed'
;

# verify no blank/null values
select distinct `Status` from world_life_expectancy;


########################## Dealing with Status null/blank values ##########################
select distinct `Life expectancy` from world_life_expectancy;  # too many possible values
# instead, we can do: 
select * 
from world_life_expectancy
where `Life expectancy` = ''
;  # 2 blank values

select * 
from world_life_expectancy
where `Life expectancy` is null
;  # no null values

# observe pattern of Life expectancy
select 
	Country,  
    `Year`, 
    `Life expectancy`
from world_life_expectancy
where Country = 'Afghanistan'  # 'Albania'
order by `Year`
;

# It seems that Life expectancy increase as Year increase
# So we can fill the blank values with average of prev and next year's Life expectancy
select 
	t1.Country,  
    t1.`Year`, t1.`Life expectancy`, 
    t2.`Year`, t2.`Life expectancy`, 
    t3.`Year`, t3.`Life expectancy`, 
    round((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1) as avg_life_expect
from world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.`Year` = t2.`Year` + 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.`Year` = t3.`Year` - 1
where t1.`Life expectancy` = ''
;

# update 
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.`Year` = t2.`Year` + 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.`Year` = t3.`Year` - 1
set t1.`Life expectancy` = round((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
where t1.`Life expectancy` = ''
;

# verify
select * 
from world_life_expectancy
where `Life expectancy` = ''
;




