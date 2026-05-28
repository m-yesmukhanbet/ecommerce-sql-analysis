# E-commerce SQL Analysis

## Project Overview

This project analyzes the **Brazilian E-Commerce Public Dataset by Olist** using **SQL** and **PostgreSQL**.

The goal of the project is to explore key business areas of an e-commerce marketplace, including revenue performance, customer behavior, delivery efficiency, product categories, and seller performance.

The analysis is designed to answer practical business questions that a junior data analyst could investigate in a real e-commerce company.

## Tools Used

- SQL
- PostgreSQL
- DBeaver
- GitHub

## Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The dataset contains information about customer orders, order items, products, sellers, payments, delivery dates, customer locations, and product categories.

Main tables used in this project:

- `olist_orders_dataset`
- `olist_order_items_dataset`
- `olist_customers_dataset`
- `olist_products_dataset`
- `olist_sellers_dataset`
- `olist_order_payments_dataset`
- `product_category_name_translation`

## Project Structure

```text
ecommerce-sql-analysis/
├── README.md
└── sql/
    ├── 01_data_quality_check.sql
    ├── 02_revenue_analysis.sql
    ├── 03_customer_analysis.sql
    ├── 04_delivery_analysis.sql
    └── 05_product_seller_analysis.sql
```

## Business Questions

This project answers the following business questions:

- What is the total revenue of the marketplace?
- What is the average order value?
- Which months generated the highest revenue?
- How did revenue change month over month?
- Which product categories generated the most revenue?
- Which Brazilian states have the highest customer and revenue concentration?
- What percentage of customers placed more than one order?
- Which customers generated the highest revenue?
- What percentage of delivered orders arrived late?
- Which states had the highest late delivery rate?
- Which sellers generated the most revenue?
- Which product categories had the highest delivery delay rate?

## Analysis Sections

### 1. Data Quality Check

**File:** `sql/01_data_quality_check.sql`

This section checks whether the imported data is reliable enough for analysis.

Main checks included:

- Row counts for all imported tables
- Order date range
- Order status distribution
- Duplicate order IDs
- Duplicate customer IDs
- Missing values in key columns
- Invalid prices
- Invalid freight values
- Basic price and freight statistics

### 2. Revenue Analysis

**File:** `sql/02_revenue_analysis.sql`

This section analyzes marketplace revenue and sales performance.

Main metrics included:

- Total revenue
- Product revenue
- Freight revenue
- Average order value
- Monthly revenue trend
- Top revenue months
- Month-over-month revenue growth
- Revenue by product category

Revenue was calculated as: `price + freight_value`

### 3. Customer Analysis

**File:** `sql/03_customer_analysis.sql`

This section analyzes customer distribution, customer value, and order frequency.

Main metrics included:

- Total unique customers
- Customers by state
- Top customer cities
- Orders by customer state
- Revenue by customer state
- Customer order frequency
- Repeat customer percentage
- Top customers by revenue
- Customer revenue segmentation

### 4. Delivery Analysis

**File:** `sql/04_delivery_analysis.sql`

This section analyzes delivery efficiency and late delivery risk.

Main metrics included:

- Delivered vs non-delivered orders
- Order status distribution
- Average delivery time
- Late delivery rate
- Delivery performance by customer state
- Monthly late delivery trend
- Average delay days for late orders
- On-time or early delivery percentage
- Delivery performance combined with revenue by state

### 5. Product and Seller Analysis

**File:** `sql/05_product_seller_analysis.sql`

This section analyzes product category performance and seller performance.

Main metrics included:

- Top product categories by revenue
- Top product categories by number of items sold
- Average item price by category
- Top sellers by revenue
- Top sellers by order volume
- Seller performance by state
- Monthly seller ranking using window functions
- Late delivery rate by product category
- Freight value by product category

## SQL Skills Demonstrated

- Data quality checks
- Filtering and sorting
- Aggregations
- `GROUP BY`
- `HAVING`
- Joins across multiple tables
- Common Table Expressions
- Window functions
- `RANK()`
- `LAG()`
- Conditional aggregation with `FILTER`
- Customer segmentation
- Business KPI calculation
- Revenue analysis
- Delivery performance analysis
- Seller performance analysis

## Key Notes

The orders table contains missing delivered customer dates for some records. These rows are mainly related to orders that were not delivered, cancelled, unavailable, or still in non-delivered statuses.

For revenue analysis, the project uses only orders available in the order items table because revenue is calculated from item price and freight value.

## Portfolio Summary

This project demonstrates my ability to use SQL for business analysis, data quality checking, KPI calculation, customer analysis, revenue analysis, delivery performance analysis, and seller performance analysis in an e-commerce context.