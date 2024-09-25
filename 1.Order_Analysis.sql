-- 1.ANALYSIS: ORDER ANAYSIS

---Q1: Analyze the distribution of orders on a monthly basis. The 'order_approved_at' field should be used for the date data
SELECT 
	TO_CHAR(DATE_TRUNC('month',ORDER_APPROVED_AT)::date,'MM-YYYY') AS ORDER_MONTH,
	COUNT(ORDER_ID) AS COUNT_MONTH
FROM ORDERS
WHERE ORDER_APPROVED_AT IS NOT NULL
GROUP BY 1
ORDER BY 2
---Q2: Analyze the number of orders based on order status on a monthly basis
select 
	to_char(date_trunc('month',order_approved_at)::date,'mm-yyyy') as order_month,
	order_status,
	count(order_id) as siparis_sayisi
from orders
where order_approved_at is not null
group by 1,2
order by 1,2

----Q3: Analyze the number of orders based on product categories. What are the prominent categories during special occasions, such as New Year's, Valentine's Day, etc.?
WITH special_days AS 
(	
    SELECT 
        o.order_id,
        order_status,
        CASE 
              WHEN order_approved_at::date BETWEEN '2018-02-01' AND '2018-02-14' THEN '2018-RioCarnaval&ValentinesDay'
              WHEN order_approved_at::date BETWEEN '2017-02-07' AND '2017-02-14' THEN '2017-ValentinesDay'
              WHEN order_approved_at::date BETWEEN '2016-10-05' AND '2016-10-12' THEN '2016-KidsDay'
              WHEN order_approved_at::date BETWEEN '2017-10-05' AND '2017-10-12' THEN '2017-KidsDay'
              WHEN order_approved_at::date BETWEEN '2017-02-21' AND '2017-03-05' THEN '2017-RioCarnaval'
              WHEN order_approved_at::date BETWEEN '2017-11-18' AND '2017-11-24' THEN '2017-BlackFriday'
              WHEN order_approved_at::date BETWEEN '2017-12-19' AND '2017-12-25' THEN '2017-Christmas'
            ELSE 'Other_Days'
        END AS specialdays,
        order_approved_at,
        p.product_id,
        product_category_name
    FROM 
        orders AS o
        INNER JOIN order_items AS oi ON oi.order_id = o.order_id
        INNER JOIN products AS p ON oi.product_id = p.product_id
    WHERE  order_approved_at IS NOT NULL
),
specialday_top_produdcts
as
(
SELECT 
    specialdays,
    product_category_name,
    COUNT( distinct order_id) AS count_order,
    ROW_NUMBER() over (partition by specialdays order by count(distinct order_id) desc) as top_products
FROM 
    special_days
WHERE 
    product_category_name IS NOT NULL AND specialdays <> 'Other_Days'
GROUP BY   1, 2
ORDER BY   1 DESC, 3 DESC
)
SELECT 
    specialdays,
    product_category_name,
    count_order,
    top_products
FROM specialday_top_produdcts
WHERE top_products BETWEEN 1 AND 10
ORDER BY 
specialdays DESC, count_order DESC;

----Q4: Analyze the number of orders based on days of the week (Monday, Thursday, etc.) and days of the month (1st, 2nd of the month, etc.).
--Step 1:Retrieve the number of orders based on the days of the week
SELECT
    CASE 
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 0 THEN 'Sunday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 1 THEN 'Monday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 2 THEN 'Tuesday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 3 THEN 'Wednesday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 4 THEN 'Thursday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 5 THEN 'Friday'
        WHEN EXTRACT(dow FROM order_purchase_timestamp) = 6 THEN 'Saturday'
    END AS days_of_week,
    COUNT(order_id) AS count_week
FROM 
    orders
WHERE 
    order_approved_at IS NOT NULL
GROUP BY 
    1
ORDER BY 
    count_week DESC;
--Step 2:Retrieve the number of orders based on the days of the month
SELECT
    EXTRACT('day' FROM order_purchase_timestamp) AS day_of_month,
    COUNT(order_id) AS count_dayofmonth
FROM 
    orders
WHERE 
    order_approved_at IS NOT NULL
GROUP BY 
    1
ORDER BY 
    1;
