-- ==============================================================================
-- Script Name: 03_cohort_analysis.sql
-- Description: Generates a customer cohort retention matrix. Tracks the percentage 
--              of customers who return in subsequent months after their first purchase.
-- Database:    ecom_analytics (MySQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Step 1: Find each customer's FIRST order month (Their Cohort)
-- ------------------------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        -- Round down to the 1st of the month to group all users acquired that month
        MIN(DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01')) AS cohort_month
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),

-- ------------------------------------------------------------------------------
-- Step 2: For every order, compute how many months after the cohort it occurred
-- ------------------------------------------------------------------------------
orders_with_cohort AS (
    SELECT 
        o.customer_id,
        cc.cohort_month,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month,
        -- Calculate the exact month difference between first purchase and this purchase
        TIMESTAMPDIFF(
            MONTH, 
            cc.cohort_month, 
            DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01')
        ) AS months_since_cohort
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
    WHERE o.order_status = 'delivered'
),

-- ------------------------------------------------------------------------------
-- Step 3: Count unique active customers per cohort per month elapsed
-- ------------------------------------------------------------------------------
cohort_retention AS (
    SELECT 
        cohort_month,
        months_since_cohort,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders_with_cohort
    GROUP BY cohort_month, months_since_cohort
),

-- ------------------------------------------------------------------------------
-- Step 4: Get the initial cohort size (Month 0 = when they first bought)
-- ------------------------------------------------------------------------------
cohort_sizes AS (
    SELECT 
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_retention
    WHERE months_since_cohort = 0
)

-- ------------------------------------------------------------------------------
-- Final Output: Calculate retention rate as a percentage of the original cohort
-- ------------------------------------------------------------------------------
SELECT 
    cr.cohort_month,
    cr.months_since_cohort,
    cr.active_customers,
    cs.cohort_size,
    -- Retention rate: What % of Month-0 customers are still active?
    ROUND((cr.active_customers / cs.cohort_size) * 100, 2) AS retention_rate_pct
FROM cohort_retention cr
JOIN cohort_sizes cs ON cr.cohort_month = cs.cohort_month
ORDER BY cr.cohort_month, cr.months_since_cohort;