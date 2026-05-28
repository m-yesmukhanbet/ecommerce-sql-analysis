-- Project: E-commerce SQL Analysis
-- File: 01_data_quality_check.sql
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Mukhammed Yesmukhanbet
-- Goal: Check imported tables, row counts, date range, duplicates, and missing values before analysis.


-- 01. Row counts for all imported tables
-- Confirms that all CSV files were imported correctly.

SELECT 'orders' AS table_name, COUNT(*) AS rows_count FROM olist_orders_dataset
UNION ALL
SELECT 'customers', COUNT(*) FROM olist_customers_dataset
UNION ALL
SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'products', COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset
UNION ALL
SELECT 'category_translation', COUNT(*) FROM product_category_name_translation;


-- 02. Orders date range
-- Shows the first and last purchase dates in the orders table.

SELECT
    MIN(order_purchase_timestamp::timestamp) AS first_order_date,
    MAX(order_purchase_timestamp::timestamp) AS last_order_date
FROM olist_orders_dataset;


-- 03. Order status distribution
-- Checks how many orders belong to each order status.

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- 04. Check duplicate order IDs in orders table
-- Each order_id should appear only once in olist_orders_dataset.

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 05. Check duplicate customer IDs in customers table
-- Each customer_id should appear only once in olist_customers_dataset.

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- 06. Missing values check in orders table
-- Counts missing values in important order columns.

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_status IS NULL OR order_status = '' THEN 1 ELSE 0 END) AS missing_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL OR order_purchase_timestamp = '' THEN 1 ELSE 0 END) AS missing_purchase_timestamp,
    SUM(CASE WHEN order_delivered_customer_date IS NULL OR order_delivered_customer_date = '' THEN 1 ELSE 0 END) AS missing_delivered_customer_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL OR order_estimated_delivery_date = '' THEN 1 ELSE 0 END) AS missing_estimated_delivery_date
FROM olist_orders_dataset;


-- 07. Missing values check in order items table
-- Counts missing values in important order item columns.

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL OR order_id = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN product_id IS NULL OR product_id = '' THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) AS missing_seller_id,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS missing_freight_value
FROM olist_order_items_dataset;


-- 08. Check for negative or zero prices
-- Prices should usually be positive.

SELECT
    COUNT(*) AS invalid_price_rows
FROM olist_order_items_dataset
WHERE price <= 0;


-- 09. Check for negative freight values
-- Freight value should not be negative.

SELECT
    COUNT(*) AS invalid_freight_rows
FROM olist_order_items_dataset
WHERE freight_value < 0;


-- 10. Basic order item price statistics
-- Gives a quick overview of price and freight distributions.

SELECT
    ROUND(MIN(price)::numeric, 2) AS min_price,
    ROUND(AVG(price)::numeric, 2) AS avg_price,
    ROUND(MAX(price)::numeric, 2) AS max_price,
    ROUND(MIN(freight_value)::numeric, 2) AS min_freight,
    ROUND(AVG(freight_value)::numeric, 2) AS avg_freight,
    ROUND(MAX(freight_value)::numeric, 2) AS max_freight
FROM olist_order_items_dataset;