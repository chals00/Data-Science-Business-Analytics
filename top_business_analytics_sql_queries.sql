/* ==============================================================================
   PRACTICAL BUSINESS ANALYTICS & DATA SCIENCE SQL TOOLKIT (2026)
   Curated by: SpectraOne Solutions (https://spectraonesolutions.com)
   Description: Standard SQL snippets for KPI tracking, cohort analysis, and window functions.
   ============================================================================== */

-- 1. CALCULATING MONTH-OVER-MONTH (MoM) REVENUE GROWTH
WITH MonthlyRevenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS order_month,
        SUM(order_amount) AS current_month_revenue
    FROM sales_orders
    WHERE status = 'Completed'
    GROUP BY 1
)
SELECT 
    order_month,
    current_month_revenue,
    LAG(current_month_revenue, 1) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        (current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY order_month)) 
        / LAG(current_month_revenue, 1) OVER (ORDER BY order_month) * 100, 
        2
    ) AS mom_growth_percentage
FROM MonthlyRevenue;


-- 2. IDENTIFYING TOP 3 HIGH-VALUE CUSTOMERS PER REGION (DENSE_RANK)
WITH RankedCustomers AS (
    SELECT 
        region_id,
        customer_id,
        SUM(total_spend) AS total_customer_spend,
        DENSE_RANK() OVER (PARTITION BY region_id ORDER BY SUM(total_spend) DESC) AS rank_in_region
    FROM customer_transactions
    GROUP BY region_id, customer_id
)
SELECT 
    region_id,
    customer_id,
    total_customer_spend,
    rank_in_region
FROM RankedCustomers
WHERE rank_in_region <= 3;


-- 3. CUSTOMER RETENTION & COHORT ACTIVITY
WITH FirstPurchase AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
UserActivities AS (
    SELECT 
        o.customer_id,
        fp.cohort_month,
        (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM fp.cohort_month)) * 12 +
        (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM fp.cohort_month)) AS month_number
    FROM orders o
    JOIN FirstPurchase fp ON o.customer_id = fp.customer_id
)
SELECT 
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_id) AS active_retained_users
FROM UserActivities
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;


-- 4. 7-DAY ROLLING AVERAGE OF DAILY ACTIVE USERS (DAU)
SELECT 
    activity_date,
    active_users,
    ROUND(
        AVG(active_users) OVER (
            ORDER BY activity_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7_day_avg_users
FROM daily_app_metrics;
