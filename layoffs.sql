SELECT * FROM `data cleanup for tableau analysis`.Data_Science_Job_Listing;
set sql_safe_updates = 0;

-- rename table `Data_Science_Job_Listing` to joblistings; --

SELECT 
    *
FROM
    joblistings;


-- look for duplicates --


select a.`Position`, a.`Job Title`, a.`Company Name`,  a.`Salary`,  a.`Job Link`, a.`Logo`, a.`Location`, a.`Company Rating`
from joblistings2 as a
order by a.`Job Title`;

with `cte` (`Position`, `Job Title`, `Company Name`, `Location`, `Salary`, `Logos`, `Job Link`, `Company Rating`, dupes) as
(
select *,
row_number() over (partition by `Job Title`, `Company Name`, `Salary`, `Company Rating`) as dupes
from joblistings2
)
select * from `cte`
where dupes != 1;

create table joblistings3
like joblistings2;

alter table joblistings3
add column `count_of_company` int;

insert into joblistings3
select *,
row_number() over (partition by `Job Title`, `Company Name`, `Salary`, `Company Rating`) as dupes
from joblistings2;

delete from joblistings3
where `count_of_company` != 1;

select * from joblistings3
where `count_of_company` = 1;

-- no more dupes for now just gotta fix the job titles --

-- attempt to fill in nulls/blanks for sal -- 

select a.`Job Title`, b.`Job Title`, a.`Company Name`, b. `Company Name`, a.`Salary`, b.`Salary`, a.`Job Link`, b.`Job Link`
from joblistings3 as a
join joblistings3 as b
on a.`Job Link` = b.`Job Link` -- (a.`Job Title` = b.`Job Title` and a.`Company Name` = b.`Company Name`) -- 
where a.salary = '' and b.salary != '';

-- no possible fixes to empty salary --

select * from joblistings3;

alter table joblistings3
drop column date;

-- might be able to add logo links --

select a.`Position`, b.`Position`, a.`Job Title`, b.`Job Title`, a.`Company Name`, b. `Company Name`, a.`Salary`, b.`Salary`, a.`Job Link`, b.`Job Link`, a.`Logo`, b.`Logo`
from joblistings3 as a
join joblistings3 as b
on a.`Company Name` = b.`Company Name` and a.`Job Link` = b.`Job Link` -- (a.`Job Title` = b.`Job Title` and a.`Company Name` = b.`Company Name`) -- 
order by a.`Job Title`;

-- no logo fixes but issues with the job titles --

update joblistings3
set `Job Title` = 'Manager - Data Science'
where `Job Title` like 'Manager of Data Science%';

-- just fix the common one this was the big obvious copy paste failure -- 

select * from joblistings3;

alter table joblistings3
drop column count_of_company;

-- change all the blanks to nulls and drop unused columns--

update joblistings3
set salary = NULL 
where salary = '';
select * from joblistings3;

alter table joblistings3
drop column Logo;

-- done --
-- main fixes include removal of duplicates, unused columns,
-- fixing the names of some repeated job titles like manager - data sci etc, and changing of blank data to null data --

