/*=================================================================
===================================================================
                    Sample Analysis Questions
===================================================================
===================================================================*/
/*=================================================================
                    Sales Analysis

What are our best-selling products by revenue and by unit?
Which product categories have the highest profit margins?
What is our month-over-month sales growth trend?
How does seasonality affect our sales?
What is the average order value by customer segment? 
===================================================================*/


-- What are our best-selling products by revenue and by unit?
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(oi.line_total),2) AS total_revenue,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC, units_sold DESC


-- Which product categories have the highest profit margins?
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS total_revenue,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total - (oi.quantity * p.cost_price)), 2) AS total_profit,
    ROUND(SUM(oi.line_total - (oi.quantity * p.cost_price)) * 100.0 / NULLIF(SUM(oi.line_total),0), 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY profit_margin_pct DESC;

--What is our month-over-month sales growth trend?
WITH monthly_sales AS (
    SELECT
        FORMAT(order_date,'MM-yyyy') AS order_month,
        SUM(total_amount) AS sales,
        MIN(order_date) AS month_start_date
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY FORMAT(order_date,'MM-yyyy')
)
SELECT
    order_month,
    sales,
    LAG(sales) OVER (ORDER BY month_start_date) AS prev_month_sales,
    ROUND((sales 
    - LAG(sales) OVER (ORDER BY month_start_date)) 
    * 100.0 /NULLIF(LAG(sales) OVER (ORDER BY month_start_date),0), 2) AS mom_trend
FROM monthly_sales
ORDER BY month_start_date;


-- How does seasonality affect our sales?
WITH seasonal_orders AS (
    SELECT
        o.order_id,
        CASE 
            WHEN MONTH(o.order_date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(o.order_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(o.order_date) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END AS season
    FROM orders o
    WHERE o.order_status = 'Delivered'
)
SELECT
    so.season,
    COUNT(so.order_id) AS total_orders,
    ROUND(SUM(o.total_amount),2) AS total_revenue
FROM seasonal_orders so
JOIN orders o ON so.order_id = o.order_id
GROUP BY so.season
ORDER BY total_revenue DESC;

-- What is the average order value by customer segment? 
SELECT
    c.customer_segment,
    ROUND(AVG(o.total_amount),2) AS avg_order_value
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Delivered'
GROUP BY c.customer_segment
ORDER BY avg_order_value DESC;


/*=================================================================
                        Customer Analysis

What is our customer acquisition cost by channel?
Which customer segment has the highest lifetime value?
What is our customer retention rate?
How many customers make repeat purchases?
What is the geographic distribution of our high-value customers?
===================================================================*/

-- What is our customer acquisition cost by channel?
SELECT
    mc.channel,
    COUNT(DISTINCT cr.customer_id) AS new_customers_acquired,
    ROUND(SUM(mc.actual_spend),2) AS total_spend,
    ROUND(SUM(mc.actual_spend) / NULLIF(COUNT(DISTINCT cr.customer_id),0),2) AS cac_per_customer, -- Customer acquisition cost
    COUNT(o.order_id) AS orders_count,
    ROUND(SUM(o.total_amount),2) AS total_revenue
FROM marketing_campaigns mc
JOIN campaign_responses cr 
    ON mc.campaign_id = cr.campaign_id
JOIN orders o 
    ON cr.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY mc.channel
ORDER BY cac_per_customer;

-- Which customer segment has the highest lifetime value?
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(o.total_amount),2) AS total_revenue,
    ROUND(SUM(o.total_amount) / NULLIF(COUNT(DISTINCT c.customer_id),0),2) AS avg_lifetime_value
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_segment
ORDER BY avg_lifetime_value DESC;


-- What is our customer retention rate?
WITH first_year_customers AS (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE YEAR(order_date) = 2023
      AND order_status = 'Delivered'
),
returning_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN first_year_customers f
      ON o.customer_id = f.customer_id
    WHERE YEAR(o.order_date) = 2024
      AND o.order_status = 'Delivered'
)
SELECT
    (SELECT COUNT(*) FROM first_year_customers) AS initial_customers,
    COUNT(*) AS returning_customers,
    ROUND(CAST(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM first_year_customers),0) AS DECIMAL(5,2)), 2) AS retention_rate_pct
FROM returning_customers;

-- How many customers make repeat purchases?

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS subq;

-- What is the geographic distribution of our high-value customers?

WITH customer_spend AS (
    SELECT
        o.customer_id,
        SUM(o.total_amount) AS total_spent
    FROM orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
),
high_value_customers AS (
    SELECT TOP 20 PERCENT
        customer_id,
        total_spent
    FROM customer_spend
    ORDER BY total_spent DESC
)
SELECT
    c.country,
    c.state,
    c.city,
    COUNT(hv.customer_id) AS high_value_customers,
    ROUND(SUM(hv.total_spent),2) AS total_revenue
FROM high_value_customers hv
JOIN customers c ON hv.customer_id = c.customer_id
GROUP BY c.country, c.state, c.city
ORDER BY total_revenue DESC;

/*=================================================================
                        Marketing Analysis

Which marketing campaigns have the best ROI?
What is our cost per acquisition by channel?
How do different traffic sources convert?
What is the effectiveness of email marketing vs social media?
Which campaign types generate the most revenue?
===================================================================*/

-- Which marketing campaigns have the best ROI?
SELECT
    mc.campaign_id,
    ROUND(mc.actual_spend,2) AS spend,
    ROUND(ISNULL(SUM(o.total_amount),0),2) AS revenue_generated,
    ROUND((ISNULL(SUM(o.total_amount),0) - mc.actual_spend)/NULLIF(mc.actual_spend,0) * 100,2) AS roi_percent
FROM marketing_campaigns mc
LEFT JOIN campaign_responses cr ON mc.campaign_id = cr.campaign_id
LEFT JOIN orders o 
    ON cr.order_id = o.order_id AND o.order_status = 'Delivered'
GROUP BY mc.campaign_id, mc.actual_spend
ORDER BY roi_percent DESC;

-- What is our cost per acquisition by channel?
SELECT
    mc.channel,
    COUNT(DISTINCT cr.customer_id) AS new_customers_acquired,
    ROUND(SUM(mc.actual_spend),2) AS total_spend,
    ROUND(SUM(mc.actual_spend) / NULLIF(COUNT(DISTINCT cr.customer_id),0),2) AS cost_per_acquisition
FROM marketing_campaigns mc
LEFT JOIN campaign_responses cr 
    ON mc.campaign_id = cr.campaign_id
LEFT JOIN orders o 
    ON cr.order_id = o.order_id AND o.order_status = 'Delivered'
GROUP BY mc.channel
ORDER BY cost_per_acquisition ASC;

-- How do different traffic sources convert?
SELECT
    traffic_source,
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS converted_sessions,
    CAST(ROUND(SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DECIMAL(5,2)) AS conversion_rate_pct
FROM website_traffic
GROUP BY traffic_source
ORDER BY conversion_rate_pct DESC;

-- What is the effectiveness of email marketing vs social media?
SELECT
    CASE 
        WHEN mc.channel = 'Email' THEN 'Email'
        WHEN mc.channel IN ('Facebook','Instagram','LinkedIn','Twitter') THEN 'Social Media'
        ELSE 'Other'
    END AS channel_group,
    COUNT(DISTINCT cr.customer_id) AS new_customers_acquired,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(mc.actual_spend),2) AS total_spend,
    ROUND(SUM(mc.actual_spend) / NULLIF(COUNT(DISTINCT cr.customer_id),0),2) AS cost_per_acquisition,
    ROUND(ISNULL(SUM(o.total_amount),0),2) AS total_revenue,
    ROUND((ISNULL(SUM(o.total_amount),0) - SUM(mc.actual_spend)) / NULLIF(SUM(mc.actual_spend),0) * 100,2) AS roi_percent
FROM marketing_campaigns mc
LEFT JOIN campaign_responses cr ON mc.campaign_id = cr.campaign_id
LEFT JOIN orders o 
    ON cr.order_id = o.order_id AND o.order_status = 'Delivered'
GROUP BY
    CASE 
        WHEN mc.channel = 'Email' THEN 'Email'
        WHEN mc.channel IN ('Facebook','Instagram','LinkedIn','Twitter') THEN 'Social Media'
        ELSE 'Other'
    END
ORDER BY roi_percent DESC;

-- Which campaign types generate the most revenue?
WITH revenue_per_campaign AS (
    SELECT
        mc.campaign_id,
        mc.campaign_type,
        SUM(ISNULL(o.total_amount,0)) AS total_revenue
    FROM marketing_campaigns mc
    LEFT JOIN campaign_responses cr 
        ON mc.campaign_id = cr.campaign_id
    LEFT JOIN orders o 
        ON cr.order_id = o.order_id AND o.order_status = 'Delivered'
    GROUP BY mc.campaign_id, mc.campaign_type
)
SELECT
    mc.campaign_type,
    COUNT(DISTINCT mc.campaign_id) AS campaigns_count,
    ROUND(SUM(rpc.total_revenue),2) AS total_revenue,
    ROUND(SUM(mc.actual_spend),2) AS total_spend,
    ROUND((SUM(rpc.total_revenue) - SUM(mc.actual_spend)) / NULLIF(SUM(mc.actual_spend),0) * 100,2) AS roi_percent
FROM marketing_campaigns mc
LEFT JOIN revenue_per_campaign rpc 
    ON mc.campaign_id = rpc.campaign_id
GROUP BY mc.campaign_type
ORDER BY roi_percent DESC;


/*=================================================================
                        Operations Analysis

What is our average order fulfillment time?
Which products need restocking?
What is our order cancellation rate?
Which suppliers deliver the best value?
How does inventory turnover vary by category?
===================================================================*/

-- What is our average order fulfillment time?
SELECT
    ROUND(AVG(DATEDIFF(DAY, order_date, ship_date)),2) AS avg_days_to_ship,
    ROUND(AVG(DATEDIFF(DAY, ship_date, delivery_date)),2) AS avg_days_to_delivery,
    ROUND(AVG(DATEDIFF(DAY, order_date, delivery_date)),2) AS avg_total_fulfillment_days
FROM orders
WHERE order_status='Delivered';

--Which products need restocking?
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    p.reorder_level,
    s.supplier_name
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.stock_quantity <= p.reorder_level
ORDER BY p.stock_quantity ASC;

-- What is our order cancellation rate?
SELECT 
    CAST(COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) * 100.0/ COUNT(*) AS DECIMAL(5,2)) AS cancellation_rate_pct
FROM orders;


-- Which suppliers deliver the best value?
SELECT
    s.supplier_name,
    SUM(oi.line_total) AS total_revenue,
    SUM(p.cost_price * oi.quantity) AS total_cost,
    SUM(oi.line_total) - SUM(p.cost_price * oi.quantity) AS total_profit,
    ROUND((SUM(oi.line_total) - SUM(p.cost_price * oi.quantity)) * 100.0 / NULLIF(SUM(p.cost_price * oi.quantity),0),2) AS profit_margin_pct
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY s.supplier_name
ORDER BY profit_margin_pct DESC;


-- How does inventory turnover vary by category?
SELECT
    cogs.category,
    cogs.total_cogs,
    inv.avg_inventory,
    ROUND(cogs.total_cogs / NULLIF(inv.avg_inventory,0),2) AS inventory_turnover_ratio
FROM
(
    SELECT
        p.category,
        ROUND(SUM(oi.quantity * p.cost_price),2) AS total_cogs
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category
) AS cogs
JOIN
(
    SELECT
        category,
        AVG(stock_quantity) AS avg_inventory
    FROM products
    GROUP BY category
) AS inv
ON cogs.category = inv.category
ORDER BY inventory_turnover_ratio DESC;
