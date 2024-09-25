-- SELLER ANALYSIS

--Q1: Who are the sellers that deliver orders to customers the fastest? Provide the top 5.

--To answer this question, it is first necessary to examine the concept of fast sellers. 
--In measuring the performance of fast sellers, not only the speed of delivering the order to the customer but also the information on how many orders the seller has received is important. 
--Because, to truly claim that a seller is fast, it would be a more accurate approach to check whether this speed is demonstrated in other orders as well

--1st Part— Analysis of Sellers' Order Counts and Speeds
--The query below displays the orders received by sellers, the average time it takes to deliver these orders to customers, and the number of orders along with total comments and rating scores. 
--However, in the 2nd Part, a better analysis will be provided with a different perspective
with seller_order_date
as
(
SELECT 
	s.seller_id as seller_id,
	o.order_id as order_id,
EXTRACT('day' from (order_delivered_customer_date-order_approved_at)) as date_difference
FROM orders as o
INNER JOIN order_items as oi
on o.order_id=oi.order_id
INNER JOIN sellers as s 
on oi.seller_id=s.seller_id
WHERE
	order_delivered_customer_date is not null
	and
	order_approved_at is not null 
GROUP BY 1,2
)
SELECT
	so.seller_id,
	COUNT(distinct so.order_id) as total_count,
	AVG(date_difference)::integer avg_date,
	AVG(review_score) as average_score,
	COUNT(distinct review_comment_message) as comment_count
FROM seller_order_date as so
JOIN order_items as oi
on oi.seller_id=so.seller_id
JOIN reviews as r
on r.order_id=oi.order_id
GROUP BY 1
ORDER BY 2 asc
--When examining the data from this output, it is observed that there are a significant number of sellers who have received one or just a few orders.
--To make the order distribution in the data more understandable, the histogram chart displayed above filters out the first 3 orders and those with over 500 orders, while the chart for sellers with 500 or more orders is shown below. 
--Based on these charts, it can be concluded that the data does not follow a normal distribution and that there are sellers with very different order counts within the dataset.
--Additionally, it can be inferred that the number of sellers receiving a high volume of orders is quite low and that many sellers in the dataset are new.
--It would not be correct to evaluate these two different categories—sellers with high order counts and new sellers—on the same scale. 
--However, the new sellers can be evaluated among themselves. Yet, even if there are many new sellers, an objective perspective suggests that a threshold for the number of orders should be established for both new and experienced sellers.
--For these new sellers, an average value of 30 could be used, while for those with high order counts, it could be 500

--2nd Part— Final Outputs of Sellers by Entering Threshold Values:
with seller_order_date
as
(
SELECT 
	s.seller_id,
	o.order_id,
	EXTRACT('day' from (order_delivered_customer_date-order_approved_at)) as date_difference
FROM orders as o
INNER JOIN order_items as oi
on o.order_id=oi.order_id
INNER JOIN sellers as s 
on oi.seller_id=s.seller_id
WHERE
	order_delivered_customer_date is not null
	and
	order_approved_at is not null 
GROUP BY 1,2
),
seller_performance
as
(
select
	so.seller_id,
	count(distinct so.order_id) as total_count,
	round(avg(date_difference)::decimal,2) as avg_date,
	round(avg(review_score)::decimal,2) as average_score,
	count(distinct review_comment_message) as comment_count
FROM seller_order_date as so
JOIN order_items as oi
on oi.seller_id=so.seller_id
JOIN reviews as r
on r.order_id=oi.order_id
GROUP BY 1
ORDER BY 3 asc
)
SELECT * from seller_performance 
WHERE total_count>=30       -- and the filter of >= 500 has also been applied.
ORDER BY 3 asc
Limit 5

--Q2: Which sellers have sales of products belonging to more categories? Do sellers with a large number of categories also have a high number of orders?"
--SQL Query:
SELECT 
	s.seller_id,
	COUNT(distinct product_category_name) as total_category,
	COUNT(distinct oi.order_id) as total_order
	FROM sellers as s
LEFT JOIN order_items as oi
on s.seller_id=oi.seller_id
LEFT JOIN orders as o
on o.order_id=oi.order_id
LEFT JOIN products as p
on oi.product_id=p.product_id
GROUP BY s.seller_id
ORDER BY 2 desc







