select * from `2015_Street_Tree_Census`;

-- data cleaning + analysis --
-- seperate live, stump and dead data --

set sql_safe_updates = 0;

-- 1. --
rename table `2015_Street_Tree_Census` to tree_data;

select * from tree_data
where status = 'dead' ; 

select * from tree_data
where status = 'stump' ; 

select * from tree_data
where status = 'alive' ; 

create table tree_dead
like tree_data;

create table tree_alive
like tree_data;

create table tree_stump
like tree_data;

-- 2. find duplicates first --
-- following was used to trim the data to find the ids of which trees has been ids multiple times by diff people --

with cte (`tree_id`, `block_id`, `status`, `spc_latin`, `spc_common`, `address`, `zip_city`, `latitude`, `longitude`, `x_sp`, `y_sp`, count_of_rows) as
(
select `tree_id`, `block_id`, `status`, `spc_latin`, `spc_common`, `address`, `zip_city`, `latitude`, `longitude`, `x_sp`, `y_sp`, 
row_number() over (partition by tree_id, block_id, status, spc_latin, spc_common, address, zip_city, latitude, longitude, x_sp, y_sp) as dupes
from tree_data
)
select * from cte
where count_of_rows != 1;

-- no dupes --
-- standardize data --

alter table tree_data
add column dates_standardized DATE;

select * from tree_data;

UPDATE tree_data
SET dates_standardized = 
    CONCAT(
        SUBSTRING(`created_at`, 7, 4),
        SUBSTRING(`created_at`, 1, 2), 
        SUBSTRING(`created_at`, 4, 2)      
    );

alter table tree_data
drop column created_at;

alter table tree_data
rename column dates_standardized to created_at;

update tree_data
set spc_latin = TRIM(UPPER(spc_latin));

update tree_data
set spc_common = TRIM(UPPER(spc_common));

-- fix tables --

insert into tree_alive
select * from tree_data
where status = 'Alive';

insert into tree_dead
select * from tree_data
where status = 'Dead';

insert into tree_stump
select * from tree_data
where status = 'Stump';

select * from tree_data;
select * from tree_dead;
select * from tree_stump;
select * from tree_alive;


-- update HONEYLOCUST --

select spc_common from tree_alive;

UPDATE tree_alive
set spc_common = 'HONEYLOCUST'
where spc_common = 'OONEYY';

UPDATE tree_alive 
SET 
    spc_common = CONCAT(SUBSTRING(`spc_common`, 1, 5),
            ' ',
            SUBSTRING(`spc_common`, 6, 6))
WHERE
    spc_common = 'HONEYLOCUST';

-- data cleaned will go under excel --
