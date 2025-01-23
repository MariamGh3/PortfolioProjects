SELECT * FROM nashville_housing;

-- Standarize date format;
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedDate
FROM nashville_housing;

UPDATE nashville_housing
SET SaleDate=STR_TO_DATE(SaleDate, '%M %d, %Y');

SELECT SaleDate FROM nashville_housing;


-- Populate Property Address data
-- If parcel ID is same, populate the property address.
SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL OR PropertyAddress = '';


SELECT table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress,
IFNULL(NULLIF(table1.PropertyAddress, ''), table2.propertyAddress) as propertyAddress
FROM nashville_housing AS table1
JOIN nashville_housing AS table2
ON table1.ParcelID=table2.ParcelID
AND table1.UniqueID<>table2.UniqueID
WHERE table1.PropertyAddress='';



UPDATE nashville_housing AS table1
JOIN nashville_housing AS table2
    ON table1.ParcelID = table2.ParcelID
    AND table1.UniqueID <> table2.UniqueID
SET table1.PropertyAddress = IFNULL(NULLIF(table1.PropertyAddress, ''), table2.PropertyAddress)
WHERE table1.PropertyAddress = '';


-- Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM nashville_housing;


SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2) AS City
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD PropertySplitAddress varchar(255);

UPDATE nashville_housing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE nashville_housing
ADD PropertyCity varchar(255);

UPDATE nashville_housing
SET PropertyCity=SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2);


SELECT PropertySplitAddress, propertycity
FROM nashville_housing;


-- Owner Address

SELECT OwnerAddress
FROM nashville_housing;


SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Part1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Part2,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Part3
FROM Nashville_Housing;



--

ALTER TABLE nashville_housing
ADD OwnerSplitAddress varchar(255);

UPDATE nashville_housing
SET OwnerSplitAddress=SUBSTRING_INDEX(OwnerAddress, ',', 1) ;

--

ALTER TABLE nashville_housing
ADD OwnerCity varchar(255);

UPDATE nashville_housing
SET OwnerCity=SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

--

ALTER TABLE nashville_housing
ADD OwnerState varchar(255);

UPDATE nashville_housing
SET OwnerState=SUBSTRING_INDEX(OwnerAddress, ',', -1);

--
SELECT *
FROM nashville_housing;



-- Change Y and N to YES and NO in 'Sols as Vacant'

SELECT DISTINCT SoldAsVacant
FROM nashville_housing;

SELECT  SoldasVacant,
CASE
	WHEN SoldasVacant = 'N' THEN 'NO'
	WHEN SoldasVacant = 'Y' THEN 'YES'
	ELSE SoldasVacant
END AS CaseStatement
FROM nashville_housing;



UPDATE nashville_housing
SET SoldAsVacant = CASE
	WHEN SoldasVacant = 'N' THEN 'NO'
	WHEN SoldasVacant = 'Y' THEN 'YES'
	ELSE SoldasVacant
END;



-- Remove Duplicates




WITH RowNumCTE AS (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate
               ORDER BY UniqueID
           ) AS row_num
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
);


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate
    ORDER BY UniqueID
    ) AS row_num
FROM nashville_housing)
SELECT * 
FROM RoWNumCTE
WHERE row_num>1
;

-- Delete unused columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;



ALTER TABLE nashville_housing
DROP COLUMN SaleDate;








