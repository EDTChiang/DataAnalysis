SELECT 
    *
FROM
    layoffs;
set sql_safe_updates = 0;

-- fix blanks -- -- fix dupes -- -- standardize -- 

with cteDUPE (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions, dupe) as
(
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
from layoffs
)
select * from ctedupe
where dupe = 2;

CREATE TABLE layoffsFINAL LIKE layoffs;

alter table layoffsFINAL
add column companycount int;

insert into layoffsFINAL
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) as row_num
from layoffs;

SELECT 
    *
FROM
    layoffsFINAL
WHERE
    companycount != 1;

SELECT 
    *
FROM
    layoffsFINAL
WHERE
    companycount = 1;

DELETE FROM layoffsFINAL 
WHERE
    companycount != 1;

-- no more duplicates --

SELECT 
    *
FROM
    layoffsFINAL;

UPDATE layoffsFINAL 
SET 
    company = TRIM(company);

UPDATE layoffsFINAL 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

-- fix nulls -- 

SELECT 
    a.company,
    b.company,
    a.industry,
    b.industry,
    COALESCE(b.industry, a.industry),
    COALESCE(a.industry, b.industry)
FROM
    layoffsFINAL AS a
        JOIN
    layoffsFINAL AS b ON a.company = b.company
WHERE
    a.industry = '' AND b.industry != '';

UPDATE layoffsFINAL a
        JOIN
    layoffsFINAL b ON a.company = b.company
        AND a.country = b.country 
SET 
    a.industry = COALESCE(b.industry, a.industry)
WHERE
    a.industry = '' AND b.industry != '';

alter table layoffsFINAL
drop column total_laid_off;
alter table layoffsFINAL
drop column percentage_laid_off;
alter table layoffsFINAL
drop column funds_raised_millions;
SELECT 
    *
FROM
    layoffsFINAL;





