select * from brands_py;
select * from categories_py;
select * from customers_py;
select * from order_items_py;
select * from orders_py;
select * from products_py;
select * from staffs_py;
select * from stocks_py;
select * from stores_py;

#QUESTION NO 1 :- List all customers who have placed orders, including their names and total order quantities.
SELECT c.customer_id, c.first_name, c.last_name, sum(ot.quantity) as Total_order_quantity
from customers_py as c left join orders_py as o on c.customer_id = o.customer_id
left join order_items_py as ot on o.order_id = ot.order_id
group by c.customer_id,c.first_name, c.last_name;

#QUESTION NO 2:-  Calculate the total number of orders placed for each product and display the product name along with the order count.
SELECT ot.product_id, p.product_name, count(ot.order_id) as Total_orders from order_items_py as ot
left join products_py as p on ot.product_id = p.product_id
group by ot.product_id, p.product_name

#QUESTION NO 3:- Find all products along with their respective brand names and category names.
SELECT p.product_id, p.product_name, b.brand_name, c.category_name from products_py as p
left join brands_py as b on p.brand_id = b.brand_id
left join categories_py as c on p.category_id = c.category_id

#QUESTION NO 4:- Compute the average list price of products for each category and sort the results by category name.
SELECT p.product_id, c.category_name, avg(p.list_price) as Avg_list_price from products_py as p
left join categories_py as c on p.category_id = c.category_id
group by p.product_id, c.category_name
order by c.category_name asc;

#QUESTION NO 5:- Retrieve all orders that have a discount greater than 10%.
select order_id, discount from order_items_py
where discount > 0.1;  

#QUESTION NO 6:- List all customers along with the total amount they have spent on orders, sorted by total amount spent in descending order.
SELECT c.customer_id, c.first_name, sum(ot.list_price) from customers_py as c
right join orders_py as o on c.customer_id = o.customer_id
left join order_items_py as ot on o.order_id = ot.order_id
group by c.customer_id, c.first_name
order by sum(ot.list_price) desc;

#QUESTIONS NO 7 :- Identify all products that belong to the 'Electronics' category and were listed after the year 2020.
SELECT p.product_id, p.model_year, c.category_name from products_py as p
left join categories_py as c on p.category_id = c.category_id
where category_name = 'Electric Bikes' and  model_year = '2016'

#QUESTION NO 8:- Find the details of stores managed by staff members whose phone numbers end with '1234', including staff names and store names.
select stf.first_name, stf.last_name, st.store_id, st.store_name, st.phone from staffs_py as stf
left join stores_py as st on stf.store_id = st.store_id
where st.phone like '%4321%'

#QUESTION NO 9:- List all products and their stock quantities in each store, and sort the results by store name and product name.
SELECT p.product_name, s.store_name, sum(st.quantity) from products_py as p
left join stocks_py as st on p.product_id = st.product_id
left join stores_py as s on st.store_id = s.store_id
group by p.product_name, s.store_name
order by p.product_name, s.store_name

#QUESTION NO 10:- Determine the total number of active staff members in each store and sort the results by the number of active staff in descending order.
SELECT stf.store_id, st.store_name, sum(stf.active) from staffs_py as stf
join stores_py as st on stf.store_id = st.store_id
group by stf.store_id, st.store_name