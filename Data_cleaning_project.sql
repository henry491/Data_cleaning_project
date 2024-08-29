-- standardize Date Format

SELECT
	SaleDate, CONVERT(date, SaleDate)
FROM
	Port_folio_project.dbo.NashvilleHousing;



UPDATE
	Port_folio_project.dbo.NashvilleHousing;
SET
	SaleDate = CONVERT(date, SaleDate);



ALTER TABLE Port_folio_project.dbo.NashvilleHousing; 
ADD
	saledateconverted DATE;


UPDATE
	Port_folio_project.dbo.NashvilleHousing;
SET
	saledateconverted = CONVERT(date, [SaleDate]);



ALTER TABLE Port_folio_project.dbo.NashvilleHousing;
DROP COLUMN SaleDate;



---------------------------------------------------------------------------------------------------

-- population property Address data

SELECT *
FROM
	Port_folio_project.dbo.NashvilleHousing
WHERE
	PropertyAddress IS NULL
--ORDER BY ParcelID;



SELECT
	nvh1.ParcelID, nvh1.PropertyAddress, nvh2.ParcelID, nvh2.PropertyAddress
	,ISNULL(nvh1.PropertyAddress, nvh2.PropertyAddress)
FROM
	Port_folio_project.dbo.NashvilleHousing nvh1
JOIN
	Port_folio_project.dbo.NashvilleHousing nvh2
ON
	nvh1.ParcelID = nvh2.ParcelID
AND
	nvh1.UniqueID != nvh2.UniqueID
WHERE
	nvh1.PropertyAddress IS NULL;


	
UPDATE nvh1
SET 
	PropertyAddress = ISNULL(nvh1.PropertyAddress, nvh2.PropertyAddress)
FROM
	Port_folio_project.dbo.NashvilleHousing nvh1
JOIN
	Port_folio_project.dbo.NashvilleHousing nvh2
ON
	nvh1.ParcelID = nvh2.ParcelID
AND
	nvh1.UniqueID != nvh2.UniqueID;


-----------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertysplitAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertysplitCity
FROM
	Port_folio_project.dbo.NashvilleHousing;



ALTER TABLE Port_folio_project.dbo.NashvilleHousing
ADD
	PropertysplitAddress NVARCHAR(255);


UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);



ALTER TABLE Port_folio_project.dbo.NashvilleHousing
ADD
	PropertysplitCity NVARCHAR(255);


UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnersplitAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnersplitCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnersplitState
FROM
	Port_folio_project.dbo.NashvilleHousing;



ALTER TABLE Port_folio_project.dbo.NashvilleHousing
ADD
	OwnersplitAddress NVARCHAR(255);


UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);



ALTER TABLE Port_folio_project.dbo.NashvilleHousing
ADD
	OwnersplitCity NVARCHAR(255);


UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE Port_folio_project.dbo.NashvilleHousing
ADD
	OwnersplitState NVARCHAR(255);

UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" fleld


SELECT
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM
	Port_folio_project.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2;


SELECT
	SoldAsVacant
,CASE
	WHEN
		SoldAsVacant = 'N' THEN 'No'
	WHEN
		SoldAsVacant = 'Y' THEN 'Yes'
	ELSE
		SoldAsVacant
END
FROM
	Port_folio_project.dbo.NashvilleHousing;


UPDATE
	Port_folio_project.dbo.NashvilleHousing
SET
	SoldAsVacant = CASE
						WHEN
							SoldAsVacant = 'N' THEN 'No'
						WHEN
							SoldAsVacant = 'Y' THEN 'Yes'
						ELSE
							SoldAsVacant
					END;


--------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH Duplicates AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
							 [ParcelID]
							,[PropertyAddress]
							,[SalePrice]
							,[saledateconverted]
							,[LegalReference]
			ORDER BY
							 [UniqueID ]) row_num
FROM
	Port_folio_project.dbo.NashvilleHousing
	)
DELETE
FROM
	Duplicates
WHERE
	row_num > 1;


------------------------------------------------------------------------------------------------------

-- Delete unused column

ALTER TABLE Port_folio_project.dbo.NashvilleHousing
DROP COLUMN
	TaxDistrict
   ,PropertyAddress
   ,OwnerAddress;