select * from nyc_condo_data;

set sql_safe_updates = 0;

-- fixes --

alter table nyc_condo_data
rename column `Date Sold` to date_sold;

alter table nyc_condo_data
rename column `Size (sqm)` to sqm;

alter table nyc_condo_data
rename column `Population Density`  to pop_dens;

-- check for duplicates --

with cte1 (addy, popu, ds, pd, price, sqm, rw) as 
(
select *, row_number() over (partition by Address, Population, date_sold, pop_dens, Price, sqm) as row_num
from nyc_condo_data
)
select * from cte1
where rw != 1;

create table nyc_condos like nyc_condo_data;

alter table nyc_condos
add column rw int;

insert into nyc_condos
select *, row_number() over (partition by Address, Population, date_sold, pop_dens, Price, sqm) as row_num
from nyc_condo_data;

select * from nyc_condos
where rw != 1;

delete from nyc_condos
where rw != 1;

-- no more dupes --

select * from nyc_condos;

-- seperate the city from the address --

select address, substring_index(address, ',', 1), substring_index(address, ',', -1) from nyc_condos;

alter table nyc_condos
add column address_street varchar(50) after address;

alter table nyc_condos
add column address_town varchar(50) after address_street;

alter table nyc_condos
add column year int after date_sold;

select * from nyc_condos;

update nyc_condos
set year = substring_index(date_sold, '-', 1);

update nyc_condos 
set address_street = substring_index(address, ',', 1);

update nyc_condos 
set address_town = substring_index(address, ',', -1);

alter table nyc_condos
drop column address;

alter table nyc_condos
drop column rw;

drop table nyc_condo_data;

-- checking --

SELECT 
	ROUND(AVG(sqm)) as avg_sqm,
    (address_town) AS town,
    COUNT(address_town) AS number_sold,
    ROUND(AVG(price)) AS avg_price,
	ROUND((AVG(price)) / (AVG(sqm))) as appsqm_IN_USD
FROM
    nyc_condos
GROUP BY 2
ORDER BY 3 DESC;
