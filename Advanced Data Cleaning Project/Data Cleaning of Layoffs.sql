select * from layoffs;

-- 1. Remove Duplicates 
-- 2. Standardize data
-- 3. Null Values or Blank Values
-- 4. Remove Unnecessary Columns
-- 

-- first we'll create copy of our data for data security 
CREATE TABLE layoffs_copy
LIKE layoffs;

-- Check 2nd Table
select * from layoffs_copy;

-- Insert values into 2nd table
INSERT layoffs_copy 
SELECT * FROM layoffs; # now we have data to work in easily without the fear of loosing data

--  Check & Remove Duplicates 
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
--  we partition the data by so many columns to identify duplicates easily
FROM layoffs_copy;
-- row no will give the 1 to each row and 2,3,4 to duplicate data 

-- To identify duplicate data use CTE of Subquery
WITH duplicate_data as ( SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
--  we partition the data by so many columns to identify duplicates easily
FROM layoffs_copy )

SELECT * FROM duplicate_data
WHERE row_num > 1; # This is our duplicate data

--  Check with the company name
SELECT * FROM layoffs_copy
WHERE company in ('Oda','Ola', 'Microsoft') ;
-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- We need to partition data by each columns to identify duplicates accurately
WITH duplicate_data as ( SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
--  we partition the data by so many columns to identify duplicates easily
FROM layoffs_copy )

SELECT * FROM duplicate_data
WHERE row_num > 1;  # This is our actual duplicate data

-- ---------------------------- Remove Duplicates from Data -------------------------------
-- Try with CTE we've used 
WITH duplicate_data as ( SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
--  we partition the data by so many columns to identify duplicates easily
FROM layoffs_copy )

DELETE FROM duplicate_data
WHERE row_num > 1;  -- its now working properly so,,,

--  Create one more duplicate table with row_num 
CREATE TABLE `layoffs_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 		-- Add one more extra column 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 -- Check Table
 select * from layoffs_copy2; # perfect 
 -- INsert data into new copy table with row_num 
INSERT INTO layoffs_copy2
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
FROM layoffs_copy; -- NOW WE HAVE NEW TABLE WITH row_num columns 

-- REMOVE DUPLICATES
 select * from layoffs_copy2
 WHERE row_num > 1;

--  DELETE
DELETE from layoffs_copy2
WHERE row_num > 1;

-- CHECK 
 select * from layoffs_copy2;
 -- -------------------------------------------- ----------------------------------------------------------------------------------
 -- -- 2. Standardize data
 select company, trim(company) from layoffs_copy2;
--  there are so many white spaces so first we'll fix them
UPDATE layoffs_copy2
SET company = trim(company);

-- Do same with industry columns
 select distinct industry, trim(industry) from layoffs_copy2 order by 1;
 -- Here are some null values as well as duplicates in this industry like Crypto, Crypto Currency , Finance, Fintech
 
 -- Let's fix industry
UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

--  Check is it worked or not 
SELECT * FROM layoffs_copy2 WHERE industry like 'Crypto%';

-- Check now Locations 
 select distinct location, trim(location) from layoffs_copy2 order by 1; -- everything is good in a locations 

-- Check now Country 
 select distinct country, TRIM(TRAILING '.' FROM country) from layoffs_copy2 order by 1;
 -- Here also issue in a country like united states and united state, states. so,,,
 
 SELECT * FROM layoffs_copy2 WHERE country like 'United States%';
-- Let's fix country
UPDATE layoffs_copy2
SET country = TRIM(TRAILING '.' FROM country) -- we use trailing to remove '.' from right/back of the text
WHERE country LIKE 'United States%';
 
-- If you look at your date it is in text dtype so we have to convert date into date data type
SELECT `date` FROM layoffs_copy2;

-- Convert date into proper format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') -- this is a standard format to modify your date 
FROM layoffs_copy2;
-- UPDATE in original data
UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); -- this is not working bcz we have diff date format in our data so
-- use CASE statement
UPDATE layoffs_copy2
SET `date` = CASE
    WHEN `date` LIKE '%/%/%' THEN STR_TO_DATE(`date`, '%m/%d/%Y') -- for dates in MM/DD/YYYY format
    WHEN `date` LIKE '%-%-%' THEN STR_TO_DATE(`date`, '%d-%m-%Y') -- for dates in DD-MM-YYYY format
    ELSE NULL
END;

select date from layoffs_copy2
