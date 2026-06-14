-- ==============================================================================
-- Script Name: 04_rfm_segmentation.sql
-- Description: Scores customers on Recency, Frequency, and Monetary (RFM) metrics 
--              using NTILE window functions. Segments them into actionable CRM tiers.
-- Database:    ecom_analytics (MySQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Step 1: Calculate raw RFM values per customer
-- ------------------------------------------------------------------------------
WITH rfm_base AS (
    SELECT 
        o.customer_id,
        
        -- RECENCY: Days since last order (relative to the latest date in the dataset + 1 day)
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency_days,
        
        -- FREQUENCY: Number of distinct orders per customer
        COUNT(DISTINCT o.order_id) AS frequency,
        
        -- MONETARY: Total payment value contributed by the customer
        SUM(p.total_payment) AS monetary_value
        
    FROM orders o
    JOIN payments_clean p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
),

-- ------------------------------------------------------------------------------
-- Step 2: Score each metric 1 to 5 using NTILE() Window Functions
-- ------------------------------------------------------------------------------
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        
        -- RECENCY: Lower days is better. 
        -- NTILE(5) ASC gives 1 to the lowest days (most recent). 
        -- We subtract from 6 so that the most recent customers get a top score of 5.
        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        
        -- FREQUENCY: Higher frequency is better. Score 5 = highest frequency.
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        
        -- MONETARY: Higher spend is better. Score 5 = top spenders.
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS m_score
        
    FROM rfm_base
),

-- ------------------------------------------------------------------------------
-- Step 3: Combine scores and classify customers into business segments
-- ------------------------------------------------------------------------------
rfm_final AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        ROUND(monetary_value, 2) AS monetary_value,
        r_score,
        f_score,
        m_score,
        
        -- Segment classification based on CRM strategy
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
            WHEN r_score >= 3 AND f_score <= 2 AND m_score >= 3 THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'Cannot Lose Them'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost Customers'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scores
)

-- ------------------------------------------------------------------------------
-- Step 4: Output the Segment Summary for Executive Reporting
-- ------------------------------------------------------------------------------
SELECT 
    rfm_segment,
    COUNT(customer_id) AS customer_count,
    ROUND((COUNT(customer_id) / (SELECT COUNT(*) FROM rfm_final)) * 100, 2) AS pct_of_customers,
    ROUND(AVG(monetary_value), 2) AS avg_spend,
    ROUND(AVG(frequency), 2) AS avg_orders,
    ROUND(AVG(recency_days), 0) AS avg_days_since_purchase,
    ROUND(SUM(monetary_value), 2) AS total_revenue_contribution
FROM rfm_final
GROUP BY rfm_segment
ORDER BY total_revenue_contribution DESC;