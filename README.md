## 🛍️ E-Commerce Analytics

![SQL](https://img.shields.io/badge/SQL-Server-blue?style=for-the-badge&logo=Microsoft-SQL-Server)
![Project](https://img.shields.io/badge/Project-pink?style=for-the-badge)

## 📊 Database Overview

**Total Records: 60,215**

This database simulates a real e-commerce business with 2+ years of transactional data (2023-2025), including customers, orders, products, marketing campaigns, and website analytics.
<details>
<summary>🗂️ Database Schema (click to expand)</summary>

<small>

| Table | Records | Purpose | Key Columns |
|-------|--------|---------|-------------|
| **suppliers** | 50 | Supplier info for product sourcing | `supplier_id`, `supplier_name`, `contact_person`, `email`, `phone`, `country`, `city`, `rating`, `contract_start_date` |
| **products** | 496 | Product catalog with pricing & inventory | `product_id`, `product_name`, `category`, `sub_category`, `brand`, `unit_price`, `cost_price`, `stock_quantity`, `reorder_level`, `supplier_id`, `launch_date`, `is_active` |
| **customers** | 2,000 | Customer info and segmentation | `customer_id`, `first_name`, `last_name`, `email`, `phone`, `date_of_birth`, `gender`, `customer_segment`, `registration_date`, `country`, `state`, `city`, `postal_code`, `loyalty_points` |
| **orders** | 8,000 | Order transactions | `order_id`, `customer_id`, `order_date`, `ship_date`, `delivery_date`, `order_status`, `payment_method`, `shipping_cost`, `discount_amount`, `tax_amount`, `total_amount`, `shipping_address_city`, `shipping_address_state`, `shipping_address_country` |
| **order_items** | 16,639 | Line items per order | `order_item_id`, `order_id`, `product_id`, `quantity`, `unit_price`, `discount_percent`, `line_total` |
| **product_reviews** | 3,000 | Customer reviews for products | `review_id`, `product_id`, `customer_id`, `order_id`, `rating`, `review_title`, `review_text`, `review_date`, `verified_purchase`, `helpful_count` |
| **marketing_campaigns** | 30 | Marketing campaign tracking | `campaign_id`, `campaign_name`, `campaign_type`, `start_date`, `end_date`, `budget`, `actual_spend`, `impressions`, `clicks`, `conversions`, `channel` |
| **campaign_responses** | 5,000 | Customer interactions with campaigns | `response_id`, `campaign_id`, `customer_id`, `response_date`, `response_type`, `order_id` |
| **website_traffic** | 15,000 | Website session data | `traffic_id`, `visit_date`, `customer_id`, `session_id`, `page_views`, `session_duration_minutes`, `traffic_source`, `device_type`, `converted`, `order_id` |
| **inventory_movements** | 10,000 | Product stock movements | `movement_id`, `product_id`, `movement_type`, `quantity`, `movement_date`, `reference_id`, `warehouse_location`, `notes` |

</small>
</details>

## 📌 Project Overview

This project provides a comprehensive SQL-based analysis of a retail business dataset, covering sales, customer behavior, marketing campaigns, and operational metrics. 

## 🔍 Analysis & Queries

### PART 1 - basic_queries - E-Commerce Basic Analysis

This section contains introductory SQL queries for exploring an e-commerce database. Perfect for beginners or quick data checks, these queries focus on customers, products, orders, and revenue.

Key Queries Included:

🔹 Customer Insights: Find all customers who registered in 2024

🔹 Product Inventory: Top 5 products by stock, products under $50

🔹 Revenue Analysis: Total revenue by payment method

🔹 Order Overview: Count orders by status

Techniques Used: Simple `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, aggregation (`SUM`, `COUNT`), and rounding for clean results.


### PART 2 - intermediate_queries - E-Commerce Intermediate Analysis

This section contains intermediate-level SQL queries to analyze an e-commerce business beyond the basics.
These queries introduce window functions, CTEs, aggregations, and retention metrics to provide deeper insights into sales, products, customers, and operations.

Key Queries Included:

🔹 Sales Trends: 7-day moving average of daily sales

🔹 Product Quality: Products with average ratings below 3 stars

🔹 Geographic Performance: Sales, revenue, and average order value by country

🔹 Customer Retention: Repeat purchase rate by customer segment

🔹 Monthly Order Performance: Delivered vs cancelled orders, delivery rate, and average delivery time

Techniques Used: WITH `CTE`s, WINDOW FUNCTIONS (`AVG() OVER()), GROUP BY`, conditional aggregation (`CASE WHEN`), and rounding for precise metrics.

### PART 3 - dashboard_views - SQL E-Commerce Dashboard Views

This section contains pre-built SQL views designed for dashboard integration in Power BI/Tableau.
These views consolidate raw e-commerce data into aggregations quick visualization

Key Views Included:

🔹 Daily Business Summary: Orders, customers, and revenue per day

🔹 Website Traffic: Sessions, engagement levels, and conversion rates by traffic source

🔹 Customer Lifetime Value: Total orders and lifetime value per customer, segmented

🔹 Product Profitability: Units sold, revenue, cost, and profit per product

🔹 Product Reviews: Review count, average rating, and helpful votes per product

Techniques Used: `CREATE VIEW`, `LEFT JOIN`, `GROUP BY`, aggregation (`SUM`, `COUNT`, `AVG`), conditional logic (`CASE`) and type casting for clean, consistent output.


### PART 4 - sample_questions - SQL E-Commerce Analytics

A ready-to-run collection of SQL queries for analyzing e-commerce performance across sales, customers, marketing, and operations. Perfect for building dashboards or doing ad-hoc analytics.

Key Insights Covered:

🔹 Sales: Best-selling products, top categories by profit, monthly growth, seasonality, average order value

🔹 Customers: Acquisition cost, lifetime value, retention rate, repeat purchases, high-value customer locations

🔹 Marketing: Campaign ROI, cost per acquisition, traffic conversion rates, email vs social media effectiveness

🔹 Operations: Fulfillment times, products needing restocking, cancellation rates, supplier performance, inventory turnover

Techniques Used: `JOIN`s, aggregations, `CTEs`, window functions, `CASE` statements, and rounding for clean metrics.

## 🛠️ Tools & Technologies

- **SQL Server / SQL Server Express** – Database hosting  
- **SSMS/Visual Studio Code** – SQL development and management  
- **Notion** – Project planning and documentation  

## 🛡️ License
This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## 🌟 About Me
Hi there! I am Miruna, an aspiring data analyst with experience in reporting, process optimization and transforming numbers into narratives 📖.

## ☕ Connect:
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/miruna-ghi%C8%9B%C4%83/)

