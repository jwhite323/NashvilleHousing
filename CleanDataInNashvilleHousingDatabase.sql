SELECT *
FROM NashvilleHousing


--Convert Date Format to YYYY-MM-DD:

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE


--Remove NULL addresses:

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Break out Addresses into Individual Columns for Address, City, and State:
--Property Address:
SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD NewPropAddress nvarchar(255);

UPDATE NashvilleHousing
SET NewPropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD NewPropCity nvarchar(255);

UPDATE NashvilleHousing
SET NewPropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Owner Address:
SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD NewOwnerAddress nvarchar(255);

UPDATE NashvilleHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing 
ADD NewOwnerCity nvarchar(255);

UPDATE NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing 
ADD NewOwnerState nvarchar(255);

UPDATE NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" field:

SELECT DISTINCT(soldasvacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant,
CASE SoldAsVacant
	WHEN 'N' THEN 'No'
	WHEN 'Y' THEN 'YES'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE SoldAsVacant
	WHEN 'N' THEN 'No'
	WHEN 'Y' THEN 'YES'
	ELSE SoldAsVacant
END


--Remove Duplicates:

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns (Would usually do this to a view, not the raw data):

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict