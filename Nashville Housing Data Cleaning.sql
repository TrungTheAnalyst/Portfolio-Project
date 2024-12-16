SELECT *
FROM PoforlioProject.[dbo].[NashvilleHousing];

-- Cleaning Data In SQL Queries

-- Standardize |Check and Transform Time Series Column
-- Create A New Column with Standard Time Value
SELECT SaleDateConverted,
CONVERT(DATE,SaleDate)
FROM  .[dbo].[NashvilleHousing];

UPDATE  PoforlioProject.[dbo].[NashvilleHousing]
SET SaleDate = CONVEPoforlioProjectRT(DATE,SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing	
SET SaleDateConverted = CONVERT(DATE,SaleDate);

SELECT SaleDateConverted
FROM  PoforlioProject.[dbo].[NashvilleHousing]
ORDER BY 1 ASC;




--Populate Property Address Data

SELECT *
FROM  NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT L1.ParcelID, L1.PropertyAddress, L2.ParcelID, L2.PropertyAddress, ISNULL(L1.PropertyAddress, L2.PropertyAddress)
FROM NashvilleHousing as L1
JOIN NashvilleHousing as L2
	ON L1.ParcelID = L2.ParcelID
	AND L1.[UniqueID ] <> L2.[UniqueID ]
WHERE L1.PropertyAddress IS NULL;

UPDATE L1
SET L1.PropertyAddress = ISNULL(L1.PropertyAddress, L2.PropertyAddress)
FROM NashvilleHousing as L1
JOIN NashvilleHousing as L2
	ON L1.ParcelID = L2.ParcelID
	AND L1.[UniqueID ] <> L2.[UniqueID ]
WHERE L1.PropertyAddress IS NULL;

SELECT PropertyAddress
FROM  NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- Breaking Out Address into (ADDRESS, CITY. STATE)

-- First Way Substring Function Style
-- SUBSTRING(Name,Start, Length)
-- CHARINDEX('Hyphen', Name)
--Len(Length)

SELECT PropertyAddress,
SUBSTRING( PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS CITY
FROM  NashvilleHousing;

 -- Create New Column With New Value Property Address.
 Select *
 From NashvilleHousing;
 
 ALTER TABLE NashvilleHousing
 ADD PropertySplitAddress nvarchar(255);

 UPDATE NashvilleHousing
 SET PropertySplitAddress = SUBSTRING( PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress));

-- Second Way PARSENAME Function Style
-- PARSENAME ('object_name' , object_piece )
-- REPLACE ( string_expression , string_pattern , string_replacement )  


SELECT OwnerAddress
FROM NashvilleHousing;

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS STATE,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS CITY,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS ADDRESS
FROM NashvilleHousing;

-- Create New Column With New OwnerAdress Value.

Select *
 From NashvilleHousing;
 
 ALTER TABLE NashvilleHousing
 ADD OwnerAdressSplitAddress nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerAdressSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

 ALTER TABLE NashvilleHousing
 ADD OwnerAdressSplitCity nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerAdressSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

 ALTER TABLE NashvilleHousing
 ADD OwnerAdressSplitState nvarchar(255);

 UPDATE NashvilleHousing
 SET OwnerAdressSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);




 -- Change Y and N to Yes and No in "SOLD as Vacant" Field.

 SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
 FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2;

 -- CASE STATEMENT
 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
 FROM NashvilleHousing; 
  
 -- Update Column SoldAsVacant AS CASE Statement.
 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
 FROM NashvilleHousing; 

 SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
 FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2;




 -- Remove Duplicate
 -- Identify Duplicate.|Row_Number()|Window Function

SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS row_num
FROM NashvilleHousing;

-- Create CTE to and remove Duplicate
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
 DELETE 
 FROM duplicate_cte
 WHERE row_num > 1;

 -- Confirmed CTE HAS No Duplicate
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
 SELECT * 
 FROM duplicate_cte
 WHERE row_num > 1
 ORDER BY PropertyAddress;




 -- DELETE COLUMNS HAS NOT USE.
SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;