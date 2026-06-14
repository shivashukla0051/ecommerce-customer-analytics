-- ==============================================================================
-- Script Name: 02_funnel_analysis.sql
-- Description: Analyzes the e-commerce order funnel to identify drop-off points
--              from order placement to final delivery. Highlights logistics bottlenecks.
-- Database:    ecom_analytics (MySQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Overall Funnel Conversion Rates
-- Purpose: Calculates the volume and conversion percentage at each stage of the 
--          order lifecycle to find where the business is losing revenue.
-- ------------------------------------------------------------------------------
WITH funnel_stages AS (
    SELECT 
        -- Stage 1: All orders placed in the system
        COUNT(*) AS s1_placed,
        
        -- Stage 2: Orders approved (payment succeeded, not cancelled immediately)
        COUNT(CASE WHEN order_status NOT IN ('created', 'cancelled') THEN 1 END) AS s2_approved,
        
        -- Stage 3: Orders successfully sent to logistics/carrier
        COUNT(CASE WHEN order_status IN ('shipped', 'delivered') THEN 1 END) AS s3_shipped,
        
        -- Stage 4: Orders successfully delivered to the customer
        COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS s4_delivered
    FROM orders
)
SELECT 
    s1_placed,
    s2_approved,
    s3_shipped,
    s4_delivered,
    ROUND((s2_approved / s1_placed) * 100, 2) AS placed_to_approved_pct,
    ROUND((s3_shipped / s2_approved) * 100, 2) AS approved_to_shipped_pct,
    ROUND((s4_delivered / s3_shipped) * 100, 2) AS shipped_to_delivered_pct,
    ROUND((s4_delivered / s1_placed) * 100, 2) AS overall_conversion_pct
FROM funnel_stages;


-- ------------------------------------------------------------------------------
-- 2. Logistics Bottleneck Deep-Dive (State-wise Failure Rate)
-- Purpose: Since the biggest drop-off is usually in last-mile delivery, 
--          this query identifies which states have the highest delivery failure rates.
-- ------------------------------------------------------------------------------
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END) AS delivered_orders,
    
    -- Calculating the percentage of orders that FAILED to deliver
    ROUND(((COUNT(o.order_id) - COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END)) / COUNT(o.order_id)) * 100, 2) AS failure_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING total_orders > 100  -- Filtering out states with too few orders for statistical relevance
ORDER BY failure_rate_pct DESC
LIMIT 10;