select * from `southeast_asia_flu_data_extended`;
rename table `southeast_asia_flu_data_extended` to SEASFLUDATA;

set sql_safe_updates = 0;


-- remove duplicates first --

select * from SEASFLUDATA;

with cte1 (Country, Date, New_Cases_count, New_Deaths_count, New_Vaccinations_count, Country_Population, duplicates) as
(
select Country, Date, New_Cases_count, New_Deaths_count, New_Vaccinations_count, Country_Population, 
row_number() over (partition by Country, Date, New_Cases_count, New_Deaths_count, New_Vaccinations_count, Country_Population)
as row_num from SEASFLUDATA
)
select * from cte1
where duplicates != 1;

create table SEASFLUDATA2
like SEASFLUDATA;

alter table SEASFLUDATA2
add column count_of_rows int;

select * from SEASFLUDATA;
select * from SEASFLUDATA2;

alter table SEASFLUDATA
drop column count_of_rows;

insert into SEASFLUDATA2
select *, (row_number() over (partition by Country, Date, New_Cases_count, New_Deaths_count, New_Vaccinations_count, Country_Population)) from SEASFLUDATA;

delete from SEASFLUDATA2
where count_of_rows != 1;

delete from SEASFLUDATA2
where Country is NULL;

alter table SEASFLUDATA2
drop column count_of_rows;

-- no more duplicates -- 

select * from seasfludata2;

select Country, New_Vaccinations_count, max(New_Vaccinations_count) over (partition by country) from SEASFLUDATA2;

-- try to get the max vaccination count per country --

with cte2 (Country, Max_Vacc_Count, date, MAXMAX) as
(
select country, new_vaccinations_count, date, max(New_Vaccinations_count) over (partition by country)
from SEASFLUDATA2
)
select country, max_vacc_count, date from cte2
where max_vacc_count = maxmax;

-- at the end of the time collected all countries got their max vaccinations at the 200k range --

select * from seasfludata2
where Date = '2021-02-28'
order by country_population desc;

create view vaccinated_populations as
SELECT 
    *, ((new_vaccinations_count / country_population)*100)
FROM
    seasfludata2
WHERE
    Date = '2021-02-28';
    
    -- gdp, population density, and count of cases does not correlate much on the vaccinations percentage of the populatiom --
    -- same way life expentacy does not change on if the population gets vaccinated or not --
    -- Philippines here has the most cases and most deaths yet having the second highest population density, by far from Singapore --
    
-- see the relationship of deaths to case --

create view mortality_rate as 
SELECT 
    `country`,
    `date`,
    new_cases_count,
    new_deaths_count,
    ((new_deaths_count / new_cases_count) * 100)
FROM
    seasfludata2
WHERE
    Date = '2021-02-28';

-- Cambodia got the highest mortality rate while the Philippines got the lowest despite the former having the lowest case count --

select * from mortality_rate;
select * from vaccinated_populations;

-- make a final data table for clarity --

create table SEASFLUDATAENDD
like SEASFLUDATA2;

insert into SEASFLUDATAENDD
select * from SEASFLUDATA2
where Date = '2021-02-28';

select * from seasfludataendd;
select * from SEASFLuDATA;
SELECT * FROM SEASFLUDATA2;

drop table SEASFLUDATA;

-- end cleanup and analysis on sql --