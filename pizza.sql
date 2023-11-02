USE projects;
SELECT * FROM projects.pizza;

-- KPIs

-- Total revenue
SELECT sum(total_price) AS total_revenue
FROM pizza;

-- Avg order value
SELECT sum(total_price)/ COUNT(DISTINCT order_id) AS avg_order_value
FROM pizza;

-- Total Pizzas Sold
SELECT sum(quantity) AS total_pizza_sold
FROM pizza;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM pizza;

-- Avg Pizzas Per Order
SELECT CAST(CAST(sum(quantity) AS DECIMAL (10,2)) /
CAST(COUNT(DISTINCT order_id) AS DECIMAL (10,2)) AS DECIMAL (10,2))
AS avg_pizzas_per_order
FROM pizza;

-- CHARTS

-- DAILY TRENDS
SELECT * 
FROM pizza 
WHERE STR_TO_DATE(order_date, '%d-%m-%Y') IS NULL;

set sql_safe_updates=0;

UPDATE pizza
SET order_date = CASE
WHEN order_date LIKE '%/%' THEN date_format(str_to_date(order_date, '%m/%d/%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE pizza
MODIFY COLUMN order_date date;

SELECT DAYNAME(order_date) AS order_day, 
COUNT(DISTINCT order_id) AS total_orders 
FROM pizza
GROUP BY DAYNAME(order_date);

-- HOURLY TREND
SELECT HOUR(order_time) AS order_hour, 
COUNT(DISTINCT order_time) AS total_orders 
FROM pizza
GROUP BY HOUR (order_time)
ORDER BY HOUR (order_time);

-- Percentage of Sales by Pizza Category 
SELECT pizza_category , (SUM(total_price)) as total_price, (SUM(total_price) * 100 / 
(SELECT SUM(total_price) FROM pizza WHERE quarter(order_date) =1))
AS percentage
FROM pizza
WHERE month(order_date) = 1
GROUP BY pizza_category;

-- Percentage of Sales by Pizza Size
SELECT pizza_size , CAST(SUM(total_price) AS DECIMAL(10,2)) AS total_sales, CAST(SUM(total_price) * 100 / 
(SELECT SUM(total_price) FROM pizza WHERE quarter(order_date)=1) AS DECIMAL (10,2)) 
AS percentage
FROM pizza
WHERE quarter(order_date) = 1
GROUP BY pizza_size
ORDER BY Percentage DESC;

-- Total pizza sold by pizza category
SELECT pizza_category, sum(quantity) as total_pizzas_sold
FROM pizza
GROUP BY pizza_category;

-- Top 5 best sellers
SELECT pizza_name, sum(quantity) as total_pizzas_sold
FROM pizza
GROUP BY pizza_name
ORDER BY SUM(quantity) DESC LIMIT 5;

-- Bottom 5 worst sellers
SELECT pizza_name, sum(quantity) as total_pizzas_sold
FROM pizza
WHERE month(order_date)= 8
GROUP BY pizza_name
ORDER BY SUM(quantity) ASC LIMIT 5;

