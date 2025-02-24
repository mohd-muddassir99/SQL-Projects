CREATE DATABASE Monday_Coffee_D_A;
Use	Monday_Coffee_D_A;
-- Monday Coffee SCHEMAS

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales


CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- END of SCHEMAS

SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM city;
SELECT * FROM customers;
-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------ Key Questions -----------------------------------------------------------------------------------------
-- Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT city_name,
population,
CONCAT(ROUND((population*0.25)/1000000,2),"   ", "Million") AS PeopleConsume_Cofee_inMillions,
city_rank
FROM city
ORDER BY 2 DESC; -- Assumes 25% population consumed coffee in each city

-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT c.city_id,c.city_name, sum(s.total) as Revenue 
FROM city AS c
JOIN customers AS cc ON c.city_id = cc.city_id 
JOIN sales AS s ON s.customer_id = cc.customer_id 
WHERE s.sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY c.city_id,c.city_name; 

-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT p.product_id, p.product_name, count(s.product_id) as Total_SalesCount
FROM products as p
LEFT JOIN sales as s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;

-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT s.customer_id, cc.customer_name, c.city_name, ROUND(avg(s.total),1) as Avg_Sales
FROM sales as s 
LEFT JOIN customers cc ON s.customer_id = cc.customer_id
LEFT JOIN city c ON c.city_id = cc.city_id
GROUP BY 1,2
ORDER BY Avg_Sales DESC;

-- One answer might be like that
SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
			SUM(s.total)/
				COUNT(DISTINCT s.customer_id),2) as avg_sale_pr_cx	
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- City Population and Coffee Consumers (25%) consumers are estimated in each city
-- Provide a list of cities along with their populations and estimated coffee consumers.
WITH curr_cust AS (
SELECT c.city_name,
COUNT(cc.customer_id) as Current_Customer
FROM city as c
JOIN customers as cc ON c.city_id = cc.city_id
GROUP BY c.city_name)
SELECT cte.city_name, 
CONCAT(ROUND((city.population*0.25)/1000000,2),"   ", "Million") AS People_Consume_Cofee_in_Millions,
cte.Current_Customer
FROM city 
JOIN curr_cust as cte ON city.city_name = cte.city_name
ORDER BY 2 DESC;

-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
WITH ranking_cte AS (
SELECT c.city_name, p.product_name, count(s.sale_id) as Total_Salesby_Prod,
DENSE_RANK() OVER(partition by c.city_name ORDER BY count(s.sale_id) DESC) as ranks
FROM sales as s
JOIN products as p ON s.product_id = p.product_id
JOIN customers as cc ON cc.customer_id = s.customer_id
JOIN city as c ON cc.city_id = c.city_id
GROUP BY 1,2
ORDER BY c.city_name asc)

SELECT city_name, product_name,Total_Salesby_Prod, ranks
FROM ranking_cte
WHERE ranks <=3;

-- same solution with subquery
SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as ranks
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE ranks <= 3;

-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT cc.city_id, cc.city_name,count(DISTINCT s.customer_id) as TotalCustomer
FROM sales as s
JOIN customers as c ON s.customer_id = c.customer_id
JOIN city as cc ON cc.city_id = c.city_id
WHERE s.product_id <= 14
GROUP BY 1,2;

-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
WITH cityrent AS (
SELECT 
	ci.city_name,
    	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
			SUM(s.total)/
				COUNT(DISTINCT s.customer_id),2) as avg_sale_pr_cx
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC)
SELECT cr.city_name, cr.avg_sale_pr_cx, ROUND(c.estimated_rent/cr.total_cx,2) as Avg_rent
FROM city as c
JOIN cityrent as cr ON c.city_name = cr.city_name
ORDER BY 1,2 DESC;

-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
WITH monthsales AS (
SELECT 
ci.city_name as CityName, MONTH(s.sale_date) as SaleMonth, YEAR(s.sale_date) as SaleYear,
SUM(s.total) as TotalSales
FROM sales as s 
JOIN customers as c ON s.customer_id = c.customer_id
JOIN city as ci ON ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 1,3,2),
-- to find the growth ration we'll use LAG() function 
GrowthRatio AS (
SELECT CityName, SaleMonth, SaleYear, TotalSales AS CurrMonthSales,
LAG(TotalSales) OVER(partition by CityName ORDER BY SaleYear, SaleMonth) as LastMonthSales
FROM monthsales)
SELECT CityName, SaleMonth, SaleYear, CurrMonthSales, LastMonthSales,
ROUND((CurrMonthSales-LastMonthSales)/LastMonthSales*100,2) AS Growth_Rate
FROM GrowthRatio  -- HERE IS OUR GROWTH RATIO, to filter nulls use where
WHERE LastMonthSales IS NOT NULL

-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
