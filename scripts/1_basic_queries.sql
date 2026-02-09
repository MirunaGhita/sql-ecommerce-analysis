/* ============================================
                PART 1 - BASIC
=========================================== */

--   1. Find all customers who registered in 2024
SELECT * 
FROM customers
WHERE YEAR(registration_date) = 2024

-- 2. List top 5 products by stock quantity
SELECT TOP 5
product_id,
product_name,
category,
sub_category,
stock_quantity
FROM products
ORDER BY stock_quantity DESC;

--   3. Calculate total revenue by payment method
SELECT
payment_method,
ROUND(SUM(total_amount),2) total_revenue
FROM orders
GROUP BY payment_method
ORDER BY total_revenue DESC

-- 4. Count orders by status
SELECT
order_status,
COUNT(order_id) total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC

--   5. Find all products under $50
SELECT
product_name,
ROUND(cost_price,2) cost_price
FROM products
WHERE cost_price < 50
ORDER BY cost_price DESC
