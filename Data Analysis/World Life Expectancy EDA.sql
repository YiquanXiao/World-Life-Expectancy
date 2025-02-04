# Exploratory Data Analysis

select 
	Country, 
    min(`Life expectancy`) as min_life_expect, 
    max(`Life expectancy`) as max_life_expect, 
    round(max(`Life expectancy`) - min(`Life expectancy`), 1) as life_increase
from world_life_expectancy
group by Country
having 
	min(`Life expectancy`) != 0 and
    max(`Life expectancy`) != 0
order by life_increase asc
;


# average Life expectancy increase as Year increase
select 
	`Year`, round(avg(`Life expectancy`), 2) as avg_life_expect
from world_life_expectancy
where `Life expectancy` != 0
group by `Year` 
order by `Year`
;


# It seems that Life expectancy has positive correlation with GDP
select 
	Country, 
    round(avg(`Life expectancy`), 2) as avg_life_expect, 
    round(avg(GDP)) as avg_gdp
from world_life_expectancy
group by Country
having 
	avg_life_expect > 0
    and avg_gdp > 0
order by avg_gdp desc
;

select 
	sum(case
			when GDP >= 1500 then 1 else 0 
		end) as high_gdp_cnt, 
	avg(case
			when GDP >= 1500 then `Life expectancy` else null 
		end) as high_gdp_life_expect, 
	sum(case
			when GDP <= 1500 then 1 else 0 
		end) as low_gdp_cnt, 
	avg(case
			when GDP <= 1500 then `Life expectancy` else null 
		end) as low_gdp_life_expect
from world_life_expectancy
;
# similar strategy can be applied to Life expectancy vs. other columns


# Status vs. Life Expectancy
select 
	`Status`, 
    count(distinct Country) as num_countries, 
    round(avg(`Life expectancy`), 2) as avg_life_expect
from world_life_expectancy
where `Life expectancy` != 0
group by `Status` 
;


# BMI vs. Life Expectancy
select 
	Country, 
    round(avg(`Life expectancy`), 2) as avg_life_expect, 
    round(avg(BMI)) as avg_bmi
from world_life_expectancy
group by Country
having 
	avg_life_expect > 0
    and avg_bmi > 0
order by avg_bmi desc
;
# no obvious pattern


# Looking at Adult Mortality
select 
	Country, 
    `Year`, 
    `Life expectancy`, 
	`Adult Mortality`, 
    sum(`Adult Mortality`) over(partition by Country order by `Year`) as rolling_total
from world_life_expectancy
;








