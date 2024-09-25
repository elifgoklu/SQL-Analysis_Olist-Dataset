-- CUSTOMER ANAYSIS

--Question: In which cities do customers shop the most? Determine the customer's city based on the city with the highest number of orders and conduct the analysis accordingly.

--Selecting the cities where customers shop the most and transferring the total orders to those cities.
--SQL Query:
--Querying the number of orders placed by customers based on cities and assigning a row number according to the order counts for the cities
with order_city_customer 
as 
(
SELECT
	customer_unique_id as customer_number,
	customer_city,
	count(distinct order_id) as count_order,
	count(customer_city) over (partition by customer_unique_id) as total_city,
	row_number() over (partition by customer_unique_id order by count(distinct order_id) desc) as city_number
FROM customers as c
JOIN orders as o
on c.customer_id=o.customer_id
GROUP BY 1,2
ORDER BY 4 desc,1
),
----Filtering the city determined for the customer based on the row number equal to 1 among the cities identified above.
first_city_customer as
(
SELECT 
	customer_number as customer_no,
	customer_city as selected_city,
	count_order,
	total_city,
	city_number
FROM order_city_customer 
WHERE city_number=1
) ,
----Transferring the total purchases made by customers to the selected cities (the reason for reusing the JOIN operation here is to ensure that not only the orders in the relevant city are considered, but also the total orders made by customers can be transferred to these selected cities. Otherwise, the order count would be limited to just the selected city).
selected_city_customer 
as
(
SELECT 
	customer_no,
	selected_city,
	sum(oc.count_order) over (partition by oc.customer_number) as total_order,
	fc.total_city,
	fc.city_number
FROM first_city_customer as fc
JOIN order_city_customer as oc
on fc.customer_no=oc.customer_number
),
----Eliminating duplicate rows due to the selected city, which replaces multiple cities, and transforming the result into a table format.
first_part_table
as
(
SELECT 
	customer_no,
	selected_city,
	total_order
FROM selected_city_customer
GROUP BY 1,2,3
)----Writing the query for the total orders based on the final selected cities.
SELECT
	selected_city,
	sum(total_order) as city_order_count,
	count(customer_no) as city_customer_count
FROM first_part_table
GROUP BY 1
ORDER BY 2 desc
