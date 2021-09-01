select * 
from PortfolioProject..housing


-- date time format



select SaleDateConverted, convert(date, saledate)
from PortfolioProject..housing

update housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE housing
add SaleDateConverted Date;

update housing 
SET SaleDateConverted = Convert(Date, SaleDate)



-- Populate Property Address Data



select *
from PortfolioProject..housing
where ParcelID like '%052 01 0 296.00%' -- equal Parcel IDs should have the same property addresses

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..housing a
JOIN PortfolioProject..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 

update a 
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..housing a
JOIN PortfolioProject..housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 



--breaking address into individual columns (address and city)



select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address, -- minus 1, plus 1 to delete the comma
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(propertyaddress)) as City 
from PortfolioProject..housing

ALTER TABLE housing
add PropertySplitAddress Nvarchar(250); --without adding a new column to the whole table it won't save

update housing 
SET PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

ALTER TABLE housing
add PropertySplitCity Nvarchar(250);

update housing 
SET PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(propertyaddress))

-- spilt OwnerAddress with parsename. Parsename only takes periods (.), we can replace comas with periods to use this

select 
parsename(replace(OwnerAddress,',','.'), 3),
parsename(replace(OwnerAddress,',','.'), 2),
parsename(replace(OwnerAddress,',','.'), 1)
from PortfolioProject..housing

ALTER TABLE housing
add OwnerSplitAddress Nvarchar(250);

update housing 
SET OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'), 3)

ALTER TABLE housing
add OwnerSplitCity Nvarchar(250);

update housing 
SET OwnerSplitCity = parsename(replace(OwnerAddress,',','.'), 2)

ALTER TABLE housing
add OwnerSplitState Nvarchar(250);

update housing 
SET OwnerSplitState = parsename(replace(OwnerAddress,',','.'), 1)

c

-- Change Y and N to Yes and No in "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..housing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from PortfolioProject..housing

Update housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove the duplicates
--create a cte
with RowNumCTE AS(
select *,
		row_number () over (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
					UniqueID
					) row_num
from PortfolioProject..housing
--order by ParcelID (we cannot write an order by on a cte)
)
--DELETE 
--from RowNumCTE
--where row_num > 1
SELECT *
from RowNumCTE
where row_num >1
order by PropertyAddress

--Delete unused columns

Select *
from PortfolioProject..housing
ALTER TABLE PortfolioProject..housing
DROP COLUMN OwnerAddress, SaleDate, PropertyAddress
