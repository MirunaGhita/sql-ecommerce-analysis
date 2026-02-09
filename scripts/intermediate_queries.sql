/* ============================================
                PART 2 - INTERMEDIATE
=========================================== */

-- 1)  Calculate moving average of daily sales (7-day window)

WITH DailySales AS (
    SELECT
        CAST(order_date AS DATE) AS sale_date,
        SUM(total_amount) AS daily_sales
    FROM orders
    WHERE order_status IN ('Delivered', 'Shipped')
    GROUP BY CAST(order_date AS DATE)
)
SELECT
    sale_date,
    ROUND(daily_sales, 2) AS daily_sales,
    ROUND(AVG(daily_sales) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS moving_avg_7d
FROM DailySales
ORDER BY sale_date;

-- 2) Find products with average ratings below 3 stars
SELECT 
    p.product_name,
    AVG(r.rating) AS avg_rating
FROM products p
LEFT JOIN product_reviews r ON p.product_id = r.product_id
GROUP BY p.product_name
HAVING AVG(r.rating) < 3
ORDER BY avg_rating;

-- 3) Geographic Sales Distribution
SELECT 
    shipping_address_country AS country,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered'
GROUP BY shipping_address_country
ORDER BY total_revenue DESC;

-- 4) Customer Retention (Repeat Purchase Rate)
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers
FROM (
    SELECT 
        c.customer_id,
        c.customer_segment,
        COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_segment
) customer_orders
GROUP BY customer_segment;

-- 5) Monthly order performance overview

SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    CAST(ROUND(SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id), 2) AS DECIMAL(5,2)) AS delivery_rate_pct,
    AVG(DATEDIFF(DAY, order_date, delivery_date)) AS avg_delivery_days
FROM orders
GROUP BY FORMAT(order_date, 'yyyy-MM'), YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date) DESC, MONTH(order_date) DESC;

