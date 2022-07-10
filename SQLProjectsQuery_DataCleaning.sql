-- cleaning data in SQL Queries

select *
from SQLProjects.dbo.NashvilleHousing
----------------
-- standardized format
Select SaleDateConverted, CONVERT(Date,SaleDate)
From SQLProjects.dbo.NashvilleHousing

Update SQLProjects.dbo.NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update SQLProjects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

----------------
-- Populate Property address data

Select *
From SQLProjects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProjects.dbo.NashvilleHousing a
JOIN SQLProjects.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a -- when doing joins use the alias 'a' instead for NashvilleHousing in Update query
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProjects.dbo.NashvilleHousing a
JOIN SQLProjects.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From SQLProjects.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address 
From SQLProjects.dbo.NashvilleHousing

ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update SQLProjects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update SQLProjects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


Select *
From SQLProjects.dbo.NashvilleHousing



Select OwnerAddress
From SQLProjects.dbo.NashvilleHousing

-- using ParseName instead of substring to split the owneraddress.
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From SQLProjects.dbo.NashvilleHousing

ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update SQLProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update SQLProjects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE SQLProjects.dbo.NashvilleHousing
Add OwnerSplitState  Nvarchar(255);

Update SQLProjects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From SQLProjects.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in " Sold as Vacant" column

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From SQLProjects.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO' 
	 ELSE SoldAsVacant 
	 END 
From SQLProjects.dbo.NashvilleHousing

Update SQLProjects.dbo.NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO' 
	 ELSE SoldAsVacant 
	 END 


Select *
From SQLProjects.dbo.NashvilleHousing

---------------------------------------------------------------

--SELECT name, compatibility_level FROM sys.databases;
-- I had to change the compatibility for the CTE below so I set it to 90
--ALTER DATABASE database_name




-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQLProjects.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From SQLProjects.dbo.NashvilleHousing
------------------------------------------


-- Deleting columns
-- should not do this to the raw data 

Select *
From SQLProjects.dbo.NashvilleHousing

ALTER TABLE SQLProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- dont need owner address when we have already split