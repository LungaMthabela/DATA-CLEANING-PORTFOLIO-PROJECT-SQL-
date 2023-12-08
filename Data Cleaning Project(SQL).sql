SELECT*
FROM PortfolioProject..NAVISHVILLEHOUSING2
-------------------------------------------------------------------------------------------------------------
---Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject..NAVISHVILLEHOUSING2

UPDATE NAVISHVILLEHOUSING2
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NAVISHVILLEHOUSING2
ADD SaleDate_CVT DATE;

UPDATE NAVISHVILLEHOUSING2
SET SaleDate_CVT = CONVERT(date,SaleDate)
-------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM PortfolioProject..NAVISHVILLEHOUSING2
--WHERE PropertyAddress is  NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress--, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NAVISHVILLEHOUSING2 A
JOIN PortfolioProject..NAVISHVILLEHOUSING2 B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NAVISHVILLEHOUSING2 A
JOIN PortfolioProject..NAVISHVILLEHOUSING2 B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
	WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns Address, City, State

SELECT PropertyAddress
FROM PortfolioProject..NAVISHVILLEHOUSING2
--WHERE PropertyAddress is  NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS ADDRESS
FROM PortfolioProject..NAVISHVILLEHOUSING2

ALTER TABLE NAVISHVILLEHOUSING2
ADD PropertySplitAddress nvarchar(255);

UPDATE NAVISHVILLEHOUSING2
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NAVISHVILLEHOUSING2
ADD PropertySplitCity nvarchar(255);

UPDATE NAVISHVILLEHOUSING2
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT*
FROM PortfolioProject..NAVISHVILLEHOUSING2

SELECT OwnerAddress
FROM PortfolioProject..NAVISHVILLEHOUSING2

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NAVISHVILLEHOUSING2


ALTER TABLE NAVISHVILLEHOUSING2
ADD OwnerSplitAddress nvarchar(255);

UPDATE NAVISHVILLEHOUSING2
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 

ALTER TABLE NAVISHVILLEHOUSING2
ADD OwnerSplitCity nvarchar(255);

UPDATE NAVISHVILLEHOUSING2
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NAVISHVILLEHOUSING2
ADD OwnerSplitState nvarchar(255);

UPDATE NAVISHVILLEHOUSING2
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

----------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NAVISHVILLEHOUSING2
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
END
FROM NAVISHVILLEHOUSING2

UPDATE NAVISHVILLEHOUSING2
SET SoldAsVacant = CASE
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
END
FROM NAVISHVILLEHOUSING2

----------------------------------------------------------------------------------------------------------------------------------

---Remove Duplicates

WITH RowNumCTE AS (
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
				)row_num
FROM NAVISHVILLEHOUSING2
--ORDER BY ParcelID
)
select*
 FROM RowNumCTE
 WHERE row_num  > 1
 ORDER BY PropertyAddress

 -------------------------------------------------------------------------------------------------------------------------------------

 --Delete Unused colums

 SELECT*
 FROM NAVISHVILLEHOUSING2

 ALTER TABLE NAVISHVILLEHOUSING2
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER TABLE NAVISHVILLEHOUSING2
 DROP COLUMN SaleDate