SELECT * FROM layoffs

-- 1. REMOVING DUPLICATES

-- Create a new table for not touching the original raw data

SELECT *
INTO layoff_staging
FROM layoffs
WHERE 1 = 0

SELECT * FROM layoff_staging

INSERT INTO layoff_staging
SELECT * FROM layoffs

-- Check over all columns to look for duplicates

WITH t2 AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country,
	funds_raised_millions ORDER BY location) AS "row_number"
	FROM layoff_staging)
SELECT * FROM t2
WHERE "row_number" >= 1

WITH t2 AS (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, "date", stage, country,
	funds_raised_millions ORDER BY location) AS "row_number"
	FROM layoff_staging)
DELETE FROM t2
WHERE "row_number" >= 2

SELECT * FROM layoff_staging
WHERE company like 'E Inc.%'

-- 2. STANDARIZING DATA

-- Removing blank spaces in companys' names

SELECT DISTINCT company, TRIM(company)
FROM layoff_staging

UPDATE layoff_staging
SET company = TRIM(company)

-- Checking industry column

SELECT DISTINCT industry
FROM layoff_staging
ORDER BY 1

SELECT *
FROM layoff_staging
WHERE industry LIKE 'crypto%'
ORDER BY 1

UPDATE layoff_staging
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%'

SELECT DISTINCT country
FROM layoff_staging
ORDER BY 1

UPDATE layoff_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'

-- Converting date column to date data type (There was one null so created a new table without that one to be able to convert the column to date type)

SELECT * FROM layoff_staging
WHERE company <> 'Blackbaud'

SELECT date FROM layoff_staging
WHERE date IS NULL

SELECT DISTINCT date FROM layoff_staging

UPDATE layoff_staging
SET "date" = CONVERT(DATE, "date", 101)
WHERE "date" NOT LIKE '%-%' AND company <> 'Blackbaud'

SELECT *
INTO layoff_staging2
FROM layoff_staging
WHERE 1 = 0

INSERT INTO layoff_staging2
SELECT * FROM layoff_staging

SELECT * FROM layoff_staging2

DELETE FROM layoff_staging2
WHERE company = 'Blackbaud'

-- 3. MANAGING NULL AND BLANKS

SELECT DISTINCT industry 
FROM layoff_staging2
WHERE industry IS NOT NULL
AND location <> 'NULL'

SELECT DISTINCT industry 
FROM layoff_staging2
WHERE industry IS NULL
OR location = 'NULL'

SELECT * 
FROM layoff_staging2
WHERE industry IS NULL
OR location = 'NULL'

SELECT * 
FROM layoff_staging2
WHERE industry IS NULL
OR location = 'NULL'

SELECT * 
FROM layoff_staging2
WHERE company = 'Airbnb'
AND total_laid_off = 30

UPDATE layoff_staging2
SET industry = NULL
WHERE company = 'Airbnb'
AND total_laid_off = 30

SELECT t1.company, t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND t2.industry IS NOT NULL

UPDATE layoff_staging2
SET industry = 'Consumer'
WHERE company = 'Juul' AND industry IS NULL

SELECT * FROM layoff_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL'

SELECT * FROM layoff_staging2

DELETE
FROM layoff_staging2
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'NULL'