-- Exploratory Data Analysis
-- We have cleaned our data now we'll explore our data to understand patterns, trends and insights.
SELECT * FROM layoffs_copy2;

-- Brief Summary of Our Data
SELECT 
MIN(total_laid_off) as Min_LayOff,
MAX(total_laid_off) as Max_LayOff,
MIN(percentage_laid_off) as Min_Per_Layoff,
MAX(percentage_laid_off) as Max_Per_Layoff
FROM layoffs_copy2;

-- Here percentage_laid_off = 1 means 100% or full company has been laid off
-- Let's Understand More
SELECT * FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- How much funds they raised untill laid off
SELECT * FROM layoffs_copy2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; -- Companies Billions of Dollars 

-- Let's Look at each Company wise laid_off
SELECT company, SUM(total_laid_off) as Total_LaidOff_by_Company
FROM layoffs_copy2
GROUP BY company
ORDER BY Total_LaidOff_by_Company DESC; -- Here is Amazon on the 1st Place in LaidOff and All the Unicorns in the Top List 
-- They laid thousand of people's from 2020 to 2023 because of Covid and slight change technology or AI...

-- Check Dates 
SELECT MIN(date), MAX(date) FROM layoffs_copy2;

-- Check Date wise LayOffs in Company
SELECT date, company, SUM(total_laid_off) as Total_LaidOff_by_Company
FROM layoffs_copy2
GROUP BY 1,2
ORDER BY Total_LaidOff_by_Company DESC, date asc, company;

-- Let's Look at each Industry wise laid_off
SELECT industry, SUM(total_laid_off) as Total_LaidOff_by_Industry
FROM layoffs_copy2
GROUP BY industry
ORDER BY Total_LaidOff_by_Industry DESC;
-- Consumer and Retail Indsutry almost did a 40 thousand+ LaidOff that's a shocking

-- Let's Look at each Country wise laid_off
SELECT country, SUM(total_laid_off) as Total_LaidOff_by_Country
FROM layoffs_copy2
GROUP BY country
ORDER BY Total_LaidOff_by_Country DESC;
-- US laid 2 Lakh 56 Thousand Paid off till 2023 and India also on 2nd with 35k+

-- Check Date wise LayOffs in Company
SELECT date, SUM(total_laid_off) as Total_LaidOff_by_Date
FROM layoffs_copy2
GROUP BY date
ORDER BY date DESC; -- Looking some messy 

-- Let's Check Year wise LayOffs in Company
SELECT Year(date) as YearOfLaidOff, SUM(total_laid_off) as Total_LaidOff_by_Date
FROM layoffs_copy2
GROUP BY YearOfLaidOff
ORDER BY Total_LaidOff_by_Date DESC; -- Look at this 2022 is have the highest number of laidoff recorded 
--  But 2023 have only few months data so it might be possible that it will break the record of 2022
-- It means LaidOff trend is going high continuously

-- Let's Look at each Stage wise laid_off
SELECT stage, SUM(total_laid_off) as Total_LaidOff_by_Company
FROM layoffs_copy2
GROUP BY stage
ORDER BY Total_LaidOff_by_Company DESC;
-- Here are highest laidoff recorded after the IPO lauching of Company and Aquisition on the 3rd 
-- Lot's of LaidOff Occured while aquisition

-- ---------------------------------------------------------------------------------------------------------------------
-- Let's go deep dive into this data
-- Let's Check the rolling total of LaidOff with month
SELECT substring(date,1,7) as Months, -- we have to extract month from date which is on the 6th position and we want a 2 values but we also want a year with month so we'll do this 1,7
SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
WHERE substring(date,1,7) is not null
GROUP BY Months
ORDER BY Months; 
-- This query group the laid of each month in each year 
-- 01- 2023 is a scary month recorded 63k+ LaidOff

-- Let's Check the rolling total of LaidOff with month in deep
-- Use last query to calculate running total 
WITH rolling_cte AS (
SELECT substring(date,1,7) as Months, 
SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
WHERE substring(date,1,7) is not null
GROUP BY Months
ORDER BY Months)
SELECT Months, Total_LaidOff,SUM(Total_LaidOff) OVER(ORDER BY Months) as RollingTotal 
FROM rolling_cte;
-- Look at here the breakdown of all LaidOff total 

-- Let's check company wise rolling total of laid off
SELECT company, Year(date) as YearOfLaidOff, SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
GROUP BY company,YearOfLaidOff
ORDER BY company ASC; 

-- Let's Check companies with total laid off in a year
SELECT company, Year(date) as YearOfLaidOff, SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
GROUP BY company,YearOfLaidOff
ORDER BY Total_LaidOff DESC; 

-- Let's rank highest laid off using window function company wise
WITH Company_LaidRank AS (
SELECT company, Year(date) as YearOfLaidOff, SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
GROUP BY company,YearOfLaidOff
ORDER BY Total_LaidOff DESC         -- To check which company HIGHEST laid off the people per year 
),
Company_Rank AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY YearOfLaidOff ORDER BY Total_LaidOff DESC) AS LaidoffRankbyYear
FROM Company_LaidRank
WHERE YearOfLaidOff IS NOT NULL 			-- WE WANT TO FILTER ONLY TOP COMPANIES FOR THIS MAKE ANOTHER CTE SO
)
SELECT * FROM Company_Rank
WHERE LaidoffRankbyYear <= 5;
-- Here we can see Year wise break down of laid off by each top or highest company 

-- Check the same for industry so for this 
WITH Industry_LaidRank AS (
SELECT industry, Year(date) as YearOfLaidOff, SUM(total_laid_off) as Total_LaidOff
FROM layoffs_copy2
GROUP BY industry,YearOfLaidOff
ORDER BY Total_LaidOff DESC         -- To check which industry HIGHEST laid off the people per year 
),
Industry_Rank AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY YearOfLaidOff ORDER BY Total_LaidOff DESC) AS LaidoffRankbyYear
FROM Industry_LaidRank
WHERE YearOfLaidOff IS NOT NULL 			-- WE WANT TO FILTER ONLY TOP INDUSTIES FOR THIS MAKE ANOTHER CTE SO
)
SELECT * FROM Industry_Rank
WHERE LaidoffRankbyYear <= 5;
-- Here we can see Year wise break down of laid off by each top or highest industry 
