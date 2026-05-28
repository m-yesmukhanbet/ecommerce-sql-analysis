E-commerce SQL Analysis

Project Overview

This project analyzes the Brazilian E-Commerce Public Dataset by Olist using SQL. The goal is to explore order data, revenue performance, customer behavior, delivery efficiency, product categories, and seller performance.

The project focuses on practical business questions that a junior data analyst may investigate in an e-commerce company, such as revenue trends, average order value, repeat customers, late deliveries, top product categories, and top-performing sellers.

Tools Used

SQL
PostgreSQL
DBeaver

Dataset

Brazilian E-Commerce Public Dataset by Olist

The dataset includes information about orders, customers, products, sellers, payments, delivery dates, and product categories.

Main tables used:

olist_orders_dataset
olist_order_items_dataset
olist_customers_dataset
olist_products_dataset
olist_sellers_dataset
olist_order_payments_dataset
product_category_name_translation

Project Structure

sql/01_data_quality_check.sql
sql/02_revenue_analysis.sql
sql/03_customer_analysis.sql
sql/04_delivery_analysis.sql
sql/05_product_seller_analysis.sql

Analysis Sections

1. Data Quality Check

Checked row counts, date ranges, order status distribution, duplicate IDs, missing values, invalid prices, and basic price statistics.

2. Revenue Analysis

Calculated total revenue, product revenue, freight revenue, average order value, monthly revenue trends, top revenue months, month-over-month revenue growth, and revenue by product category.

3. Customer Analysis

Analyzed customer geography, top customer states and cities, revenue by state, customer order frequency, repeat customers, top customers by revenue, and customer value segments.

4. Delivery Analysis

Measured delivered and non-delivered orders, average delivery time, late delivery rate, delivery performance by state, monthly late delivery trends, and the relationship between delivery performance and revenue.

5. Product and Seller Analysis

Identified top product categories by revenue and sales volume, average item price by category, top sellers by revenue and order volume, seller performance by state, monthly seller ranking, late delivery by product category, and freight cost patterns.

Key Business Questions

Which months generated the highest revenue?
What is the average order value?
Which product categories generate the most revenue?
Which Brazilian states have the highest customer and revenue concentration?
What percentage of customers placed more than one order?
What percentage of delivered orders arrived late?
Which sellers generated the most revenue?
Which product categories have the highest delivery delay rate?

Main Skills Demonstrated

SQL joins
Aggregations
GROUP BY and HAVING
Common Table Expressions
Window functions
Data quality checks
Business KPI analysis
Customer segmentation
Revenue analysis
Delivery performance analysis
Seller and product analysis

Notes

Revenue was calculated as:

price + freight_value

The orders table contains missing delivered customer dates for some orders. These records are mainly related to orders that were not delivered, cancelled, unavailable, or still in non-delivered statuses.