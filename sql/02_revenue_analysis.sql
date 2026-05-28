-- Project: E-commerce SQL Analysis
-- File: 02_revenue_analysis.sql
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Mukhammed Yesmukhanbet
-- Goal: Analyze revenue, average order value, and monthly sales trends.


-- 01. Total revenue based on order items
-- Revenue is calculated as product price + freight value.

SELECT
    ROUND(SUM(price + freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset;


-- 02. Revenue split: product revenue and freight revenue
-- This separates actual product sales from delivery fees.

SELECT
    ROUND(SUM(price)::numeric, 2) AS product_revenue,
    ROUND(SUM(freight_value)::numeric, 2) AS freight_revenue,
    ROUND(SUM(price + freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset;


-- 03. Average order value
-- AOV = total revenue divided by number of unique orders.

SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price + freight_value)::numeric, 2) AS total_revenue,
    ROUND((SUM(price + freight_value) / COUNT(DISTINCT order_id))::numeric, 2) AS average_order_value
FROM olist_order_items_dataset;


-- 04. Monthly revenue trend
-- Shows how revenue changed over time by order purchase month.

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue,
    ROUND((SUM(oi.price + oi.freight_value) / COUNT(DISTINCT oi.order_id))::numeric, 2) AS average_order_value
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
GROUP BY order_month
ORDER BY order_month;


-- 05. Top 5 months by total revenue
-- Identifies the strongest months by sales performance.

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue,
    ROUND((SUM(oi.price + oi.freight_value) / COUNT(DISTINCT oi.order_id))::numeric, 2) AS average_order_value
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
GROUP BY order_month
ORDER BY total_revenue DESC
LIMIT 5;


-- 06. Monthly revenue growth
-- Calculates month-over-month revenue change using LAG window function.

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
    GROUP BY order_month
)

SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_revenue) OVER (ORDER BY order_month), 0) * 100)::numeric,
        2
    ) AS revenue_growth_percentage
FROM monthly_revenue
ORDER BY order_month;


-- 07. Product category revenue
-- Shows which product categories generated the highest revenue.

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price)::numeric, 2) AS product_revenue,
    ROUND(SUM(oi.freight_value)::numeric, 2) AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 10;