-- Project: E-commerce SQL Analysis
-- File: 03_customer_analysis.sql
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Mukhammed Yesmukhanbet
-- Goal: Analyze customer geography, order frequency, repeat customers, and customer revenue.


-- 01. Total unique customers
-- Shows the number of unique customer IDs and unique customer unique IDs.
-- customer_id = ID for each order
-- customer_unique_id = real unique customer across orders

SELECT
    COUNT(DISTINCT customer_id) AS total_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM olist_customers_dataset;


-- 02. Customers by state
-- Shows which Brazilian states have the largest customer base.

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;


-- 03. Top 10 customer cities
-- Shows the cities with the highest number of unique customers.

SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_city, customer_state
ORDER BY total_customers DESC
LIMIT 10;


-- 04. Orders by customer state
-- Shows where orders are concentrated geographically.

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 05. Revenue by customer state
-- Shows which states generated the highest total revenue.

SELECT
    c.customer_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue,
    ROUND((SUM(oi.price + oi.freight_value) / COUNT(DISTINCT oi.order_id))::numeric, 2) AS average_order_value
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- 06. Top 10 states by revenue
-- Shorter version of the previous query for portfolio summary.

SELECT
    c.customer_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- 07. Customer order frequency
-- Shows how many customers ordered once, twice, three times, etc.

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    total_orders,
    COUNT(*) AS number_of_customers
FROM customer_orders
GROUP BY total_orders
ORDER BY total_orders;


-- 08. Repeat customers
-- Calculates how many customers placed more than one order.

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_unique_customers,
    COUNT(*) FILTER (WHERE total_orders = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,
    ROUND(
        (COUNT(*) FILTER (WHERE total_orders > 1)::numeric / COUNT(*) * 100),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- 09. Top 10 customers by revenue
-- Shows the highest-value customers by total spending.

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_revenue DESC
LIMIT 10;


-- 10. Customer revenue segmentation
-- Groups customers by total revenue generated.

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
    JOIN olist_customers_dataset c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_revenue < 50 THEN 'Low value: < 50'
        WHEN total_revenue >= 50 AND total_revenue < 150 THEN 'Medium value: 50-149'
        WHEN total_revenue >= 150 AND total_revenue < 500 THEN 'High value: 150-499'
        ELSE 'Very high value: 500+'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue)::numeric, 2) AS segment_revenue,
    ROUND(AVG(total_revenue)::numeric, 2) AS avg_customer_revenue
FROM customer_revenue
GROUP BY customer_segment
ORDER BY segment_revenue DESC;