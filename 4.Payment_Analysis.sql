-- PAYMENT ANALYSIS

--Q1: In which region do users who use a higher number of installments for payments live the most?
--Step 1—Finding out what high installments mean for customers (What is considered a high installment for customers?)
--SQL Query:
SELECT 
	c.customer_unique_id,
	payment_installments,
	count(distinct o.order_id) as order_count	
FROM customers as c
LEFT JOIN orders as o
on c.customer_id=o.customer_id
LEFT JOIN payments as p
on o.order_id=p.order_id
WHERE payment_installments>1
GROUP BY 1,2	
ORDER BY 2 desc,1 
	
--When examining the results of this output, the counterpart of high installments may vary according to the defined criteria. When the output results are visualized in a graph, the area where the installments are concentrated is analyzed, and it can be said that customers with more than 5 installments are using high installments, while customers using 10 or more installments are using significantly higher installments. 
--Based on this result, we proceed to the second part of the analysis:
--Step 2—Querying how much customers with high installments have spent in which states and aggregating the results by states along with customer and order counts.
--SQL Query
with high_credit_customer
as
(
SELECT 
	customer_unique_id,
	c.customer_state,
	payment_installments,
	count(distinct o.order_id) as order_count,
	sum(payment_value) as payment_amount
FROM customers as c
INNER JOIN orders as o
on c.customer_id=o.customer_id
INNER JOIN payments as p
ON p.order_id=o.order_id
WHERE payment_installments>5
GROUP BY 1,2,3
ORDER BY 3 desc
)
SELECT 
	customer_state,
	count(distinct customer_unique_id) as customer_count,
	sum(order_count) as total_order,
	round(sum(payment_amount)::decimal,2) as total_amount
FROM high_credit_customer
GROUP BY 1
ORDER BY 2 desc

--Q2: Calculate the number of successful orders and the total successful payment amount by payment type. Sort them from the most used payment type to the least.
--SQL Query:
SELECT 
	payment_type,
	count(distinct p.order_id) as count_payment,
	round(sum(payment_value)::decimal,2) as total_payment
FROM payments as p
JOIN orders as o
on p.order_id=o.order_id
WHERE order_status='delivered'
GROUP BY payment_type
ORDER BY 2 desc

--Q3: Perform a category-based analysis of orders paid in a single payment and by installments. In which categories is installment payment used the most?
--Part 1:
--SQL query for category-based analysis of orders paid in a single payment.
SELECT 
	product_category_name,
	count(distinct py.order_id) as order_count,
	round(avg(payment_value)::decimal,2) as avg_payment_amount
FROM payments as py
JOIN orders as o 
on o.order_id=py.order_id
JOIN order_items as oi
on py.order_id=oi.order_id
JOIN products as pr
on pr.product_id=oi.product_id
WHERE payment_installments<=1 and product_category_name is not null
GROUP BY 1
ORDER BY 2 desc
--Part 2:
--SQL query for category-based analysis of orders paid by installments.
SELECT 
	product_category_name,
	count(distinct py.order_id) as order_count,
	round(avg(payment_value)::decimal,2) as avg_payment_amount
FROM payments as py
JOIN orders as o 
on o.order_id=py.order_id
JOIN order_items as oi
on py.order_id=oi.order_id
JOIN products as pr
on pr.product_id=oi.product_id
WHERE payment_installments>1 and product_category_name is not null
GROUP BY 1
ORDER BY 2 desc
