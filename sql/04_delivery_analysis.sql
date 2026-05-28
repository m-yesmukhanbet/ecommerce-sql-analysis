-- Project: E-commerce SQL Analysis
-- File: 04_delivery_analysis.sql
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Mukhammed Yesmukhanbet
-- Goal: Analyze delivery performance, delivery delays, and delivery time by state.


-- 01. Delivered vs non-delivered orders
-- Shows how many orders were delivered and how many were not.

SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL OR order_delivered_customer_date = ''
            THEN 'Not delivered / missing delivery date'
        ELSE 'Delivered'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- 02. Order status distribution
-- Helps explain why some orders have missing delivery dates.

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- 03. Average delivery time for delivered orders
-- Delivery time = delivered customer date - purchase date.

SELECT
    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp
                )
            )
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> '';


-- 04. Late delivery rate
-- Late delivery = delivered date after estimated delivery date.

SELECT
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
    ) AS late_orders,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
            )::numeric / COUNT(*) * 100
        ),
        2
    ) AS late_delivery_percentage
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> '';


-- 05. Delivery performance by customer state
-- Shows which states have the highest late delivery rates.

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp
    ) AS late_orders,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp
            )::numeric / COUNT(*) * 100
        ),
        2
    ) AS late_delivery_percentage,
    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    o.order_delivered_customer_date::timestamp - o.order_purchase_timestamp::timestamp
                )
            )
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date <> ''
GROUP BY c.customer_state
ORDER BY late_delivery_percentage DESC;


-- 06. Top 10 states by average delivery time
-- Shows where delivery takes the longest on average.

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    o.order_delivered_customer_date::timestamp - o.order_purchase_timestamp::timestamp
                )
            )
        )::numeric,
        2
    ) AS avg_delivery_days
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date <> ''
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC
LIMIT 10;


-- 07. Monthly late delivery trend
-- Shows how the late delivery rate changed over time.

SELECT
    DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS order_month,
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
    ) AS late_orders,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp
            )::numeric / COUNT(*) * 100
        ),
        2
    ) AS late_delivery_percentage
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> ''
GROUP BY order_month
ORDER BY order_month;


-- 08. Delivery delay in days
-- Shows how many days late orders were delayed on average.

SELECT
    ROUND(
        AVG(
            EXTRACT(
                DAY FROM (
                    order_delivered_customer_date::timestamp - order_estimated_delivery_date::timestamp
                )
            )
        )::numeric,
        2
    ) AS avg_delay_days_for_late_orders
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> ''
  AND order_delivered_customer_date::timestamp > order_estimated_delivery_date::timestamp;


-- 09. Orders delivered earlier than estimated date
-- Shows how many orders arrived earlier or on time.

SELECT
    COUNT(*) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date::timestamp <= order_estimated_delivery_date::timestamp
    ) AS on_time_or_early_orders,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE order_delivered_customer_date::timestamp <= order_estimated_delivery_date::timestamp
            )::numeric / COUNT(*) * 100
        ),
        2
    ) AS on_time_or_early_percentage
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> '';


-- 10. Delivery and revenue by state
-- Combines revenue and delivery performance to identify business-critical regions.

SELECT
    c.customer_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) FILTER (
        WHERE o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp
    ) AS late_orders,
    ROUND(
        (
            COUNT(DISTINCT oi.order_id) FILTER (
                WHERE o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp
            )::numeric / COUNT(DISTINCT oi.order_id) * 100
        ),
        2
    ) AS late_delivery_percentage
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date <> ''
GROUP BY c.customer_state
ORDER BY total_revenue DESC;