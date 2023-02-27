CREATE DATABASE PortfolioProject
GO
USE PortfolioProject
GO 

SELECT * FROM NashvilleHousing

-- Formate SaleDate from Datetime format to Date Format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- To confirm that the update was successful
SELECT SaleDate, SaleDateConverted 
FROM NashvilleHousing

-- Populate Property Address Data
SELECT PropertyAddress 
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Seperating Propertyaddress into individual columns (Address, city)
SELECT PropertyAddress 
FROM NashvilleHousing

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress text;

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity text;

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT PropertySplitaddress, PropertySplitCity 
FROM NashvilleHousing

--Seperating OwnerAddress into Address,city and state
SELECT OwnerAddress 
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1) AS State
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress text

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity text

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState text

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing

-- Change Y and N to "Yes" and "No" in "SoldAsVacant"
SELECT SoldAsVacant, 
	CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

SELECT SoldAsVacant
FROM NashvilleHousing
WHERE SoldAsVacant <> 'YES' AND SoldAsVacant <> 'NO'

-- Remove Duplicates
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
					) row_num

FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

-- Remove unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress

--Recap
SELECT *
FROM NashvilleHousing