select * from brands_py;
select * from categories_py;
select * from customers_py;
select * from order_items_py;
select * from orders_py;
select * from products_py;
select * from staffs_py;
select * from stocks_py;
select * from stores_py;

#QUESTION NO 1:- List the names and email addresses of all customers.
SELECT first_name, last_name, email from customers_py;
#QUESTION NO 2:- Identify the unique states and the number of customers in each state.
SELECT DISTINCT state, count(customer_id) from customers_py group by state;

#QUESTION NO :- 3 Determine the total number of distinct products available in each category.
SELECT category_id, count(product_id) as count_of_products from products_py
group by category_id;

#QUESTION NO 4 :- Retrieve all products with a list price greater than $100 and sort them by product name.
select product_name, list_price from products_py
where list_price > 100
order by product_name asc;

#question no 5:- Find all customers living in the state of 'California' and sort them by last name.
select first_name, last_name, state from customers_py
where state = 'CA'
order by last_name asc;

#QUESTION NO 6:- List all distinct cities where the company's stores are located, along with the count of stores in each city.
SELECT distinct city, count(store_id) from stores_py
group by city;

#QUESTION NO 7:- Display the product names and list prices for all products sorted by their list price in descending order.
select product_name, list_price from products_py
order by list_price desc;

#question no 8:- Retrieve the details of the first 10 customers who have an email address.
SELECT * FROM customers_py 
order by email limit 10;

#QUESTION NO 9:- Calculate the total quantity of items ordered and the total revenue generated from these orders.
SELECT SUM(quantity) as Total_orders, SUM(list_price) as Total_revenue from order_items_py;

#QUESTION NO 10:- Find the maximum, minimum, and average list price among all products.
SELECT min(list_price), max(list_price), avg(list_price) from products_py;
SELECT min(list_price), max(list_price), avg(list_price) from order_items_py