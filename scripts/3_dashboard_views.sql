
/*===============================================
            DASHBOARD READY VIEWs
=================================================*/

-- Daily business summary

CREATE VIEW vw_daily_business_summary AS
SELECT
    CAST(o.order_date AS DATE) AS order_date,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    SUM(o.total_amount) AS revenue
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY CAST(o.order_date AS DATE);

-- Traffic

CREATE VIEW vw_base_website_traffic AS
SELECT
    traffic_id,
    visit_date,
    CAST(customer_id AS INT) AS customer_id,
    session_id,
    page_views,
    session_duration_minutes,
    traffic_source,
    device_type,
    CAST(converted AS INT) AS converted,
    CAST(order_id AS INT) AS order_id
FROM website_traffic;

CREATE VIEW vw_session_metrics AS
SELECT
    visit_date,
    session_id,
    traffic_source,
    device_type,
    converted,
    CASE
        WHEN page_views < 3 OR session_duration_minutes < 5 THEN 'Low'
        WHEN page_views BETWEEN 3 AND 7
         AND session_duration_minutes BETWEEN 5 AND 15 THEN 'Medium'
        ELSE 'High'
    END AS engagement_level
FROM vw_base_website_traffic;

CREATE VIEW vw_conversion_by_source AS
SELECT
    traffic_source,
    COUNT(DISTINCT session_id) AS sessions,
    SUM(converted) AS conversions,
    CAST(SUM(converted) * 100.0 / NULLIF(COUNT(DISTINCT session_id),0)
         AS DECIMAL(5,2)) AS conversion_rate_pct
FROM vw_session_metrics
GROUP BY traffic_source;

-- Customer data 

CREATE VIEW vw_customer_ltv AS
SELECT
    c.customer_id,
    c.customer_segment,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_segment;

-- Product data

CREATE VIEW vw_product_profitability AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue,
    SUM(oi.quantity * p.cost_price) AS cost,
    SUM(oi.line_total) - SUM(oi.quantity * p.cost_price) AS profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category;


CREATE VIEW vw_product_review_summary AS
SELECT
    product_id,
    COUNT(review_id) AS review_count,
    AVG(rating * 1.0) AS avg_rating,
    SUM(helpful_count) AS helpful_votes
FROM product_reviews
GROUP BY product_id;

