-- data cleaning --

set sql_safe_updates = 0;

select * from nashville_housing;

-- fill in missing property addresses --

select * from nashville_housing
where PropertyAddress = ''
order by ParcelID;

-- let prop add b be like a hypothetical/alternate timeline table same as a --

select a.ParcelID, a.PropertyAddress, b.PropertyAddress, b.ParcelID, 
COALESCE(b.PropertyAddress, a.PropertyAddress) as 'Propertyadd', -- no idea which fills or not --
COALESCE(a.PropertyAddress, b.PropertyAddress) as 'PropertyAdd' 
from nashville_housing a
join nashville_housing b
on a.parcelID = b.parcelID and a.uniqueID !=  b.uniqueID;

update nashville_housing a
join nashville_housing b
on a.parcelID = b.parcelID and a.uniqueID != b.uniqueID
set a.PropertyAddress = COALESCE(b.PropertyAddress, a.PropertyAddress)
where a.PropertyAddress = '';

select * from nashville_housing;

-- street, city split --

SELECT
    TRIM(SUBSTRING_INDEX(propertyaddress, ',', 1)) AS street,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ',', 2), ',', -1)) AS city
    from nashville_housing;
    
    select * from nashville_housing;
    
    -- adding it into the table --
    
    alter table nashville_housing
    add column streetcity varchar(200);
    
    update nashville_housing
    set streetcity = TRIM(SUBSTRING_INDEX(propertyaddress, ',', 1)) ;
    
    alter table nashville_housing
    add column citystreet varchar(200);
    
    update nashville_housing
    set citystreet = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(propertyaddress, ',', 2), ',', -1)) ;
    
    -- just to adjust the columns --
    
    alter table nashville_housing
    change column streetcity streetcity varchar(200) after propertyaddress;
    
       alter table nashville_housing
    change column citystreet citystreet varchar(200) after streetcity;
    
    -- street, city, state split --
    
    SELECT
    TRIM(SUBSTRING_INDEX(owneraddress, ',', 1)) AS street,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)) AS city,
	TRIM(SUBSTRING_INDEX(owneraddress, ', ', -1)) AS state 
    from nashville_housing;

-- fix the table --
alter table nashville_housing
add column street varchar(200);
alter table nashville_housing
add column city varchar(200);
alter table nashville_housing
add column state varchar(200);

alter table nashville_housing
change column street street varchar(200) after owneraddress;
alter table nashville_housing
change column city city varchar(200) after street;
alter table nashville_housing
change column state state varchar(200) after city;

update nashville_housing
set street = TRIM(SUBSTRING_INDEX(owneraddress, ',', 1));
update nashville_housing
set city = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)) ;
update nashville_housing
set state = TRIM(SUBSTRING_INDEX(owneraddress, ', ', -1));

-- change y or n to yes or no --

select distinct(soldasvacant) from nashville_housing;

select soldasvacant,
case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from nashville_housing;

update nashville_housing
set soldasvacant = 
case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end;

-- if ever duplicates are wanted to be removed --

with cte1 as(
SELECT *, ROW_NUMBER() OVER 
(PARTITION BY parcelid, saledate, owneraddress ORDER BY uniqueid)
AS rownumber
FROM nashville_housing
where uniqueid != ''
)
delete from cte1
where rownumber > 1;
















