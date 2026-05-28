-- Project: E-commerce SQL Analysis
-- File: 05_product_seller_analysis.sql
-- Dataset: Brazilian E-Commerce Public Dataset by Olist
-- Author: Mukhammed Yesmukhanbet
-- Goal: Analyze product categories, best-selling products, seller performance, and seller geography.


-- 01. Top 10 product categories by revenue
-- Shows which categories generated the highest total revenue.

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


-- 02. Top 10 product categories by number of items sold
-- Shows which categories had the highest sales volume.

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY product_category
ORDER BY total_items_sold DESC
LIMIT 10;


-- 03. Average item price by category
-- Shows which product categories have the highest average item price.

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY product_category
HAVING COUNT(oi.order_item_id) >= 50
ORDER BY avg_item_price DESC
LIMIT 10;


-- 04. Top 10 sellers by revenue
-- Shows the highest-performing sellers by total revenue.

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- 05. Top 10 sellers by number of orders
-- Shows sellers with the highest order volume.

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY total_orders DESC
LIMIT 10;


-- 06. Seller performance by state
-- Shows which seller states generated the most revenue.

SELECT
    s.seller_state,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC;


-- 07. Monthly seller ranking by revenue
-- Uses window function to rank sellers by revenue within each month.

WITH seller_monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
        oi.seller_id,
        s.seller_city,
        s.seller_state,
        ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_orders_dataset o
        ON oi.order_id = o.order_id
    JOIN olist_sellers_dataset s
        ON oi.seller_id = s.seller_id
    GROUP BY order_month, oi.seller_id, s.seller_city, s.seller_state
),

ranked_sellers AS (
    SELECT
        order_month,
        seller_id,
        seller_city,
        seller_state,
        total_revenue,
        RANK() OVER (
            PARTITION BY order_month
            ORDER BY total_revenue DESC
        ) AS seller_rank
    FROM seller_monthly_revenue
)

SELECT
    order_month,
    seller_rank,
    seller_id,
    seller_city,
    seller_state,
    total_revenue
FROM ranked_sellers
WHERE seller_rank <= 3
ORDER BY order_month, seller_rank;


-- 08. Product category and delivery performance
-- Shows late delivery rate by product category.

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
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
    ) AS late_delivery_percentage,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date <> ''
GROUP BY product_category
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY late_delivery_percentage DESC;


-- 09. Product dimensions and freight value
-- Checks whether heavier/larger products tend to have higher freight costs.

SELECT
    ROUND(AVG(p.product_weight_g)::numeric, 2) AS avg_product_weight_g,
    ROUND(AVG(p.product_length_cm * p.product_height_cm * p.product_width_cm)::numeric, 2) AS avg_product_volume_cm3,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight_value
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE p.product_weight_g IS NOT NULL
  AND p.product_length_cm IS NOT NULL
  AND p.product_height_cm IS NOT NULL
  AND p.product_width_cm IS NOT NULL;


-- 10. Freight value by product category
-- Shows categories with the highest average freight cost.

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS product_category,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(AVG(oi.freight_value)::numeric, 2) AS avg_freight_value,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
GROUP BY product_category
HAVING COUNT(oi.order_item_id) >= 50
ORDER BY avg_freight_value DESC
LIMIT 10;