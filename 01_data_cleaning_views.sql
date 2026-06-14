-- ==============================================================================
-- Script Name: 01_data_cleaning_views.sql
-- Description: Creates clean views for orders and payments to handle nulls, 
--              calculate delivery durations, and aggregate payment installments.
-- Database:    ecom_analytics (MySQL)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. Create orders_clean View
-- Purpose: Calculates delivery metrics and formats dates for cohort analysis.
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW orders_clean AS
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_status, 
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    
    -- Calculate actual delivery duration in days
    DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,
    
    -- Flag deliveries as 'On Time' or 'Late' based on estimated dates
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'On Time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'Unknown'
    END AS delivery_status,
    
    -- Truncate purchase timestamp to the 1st of the month for Cohort Matrix
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS purchase_month
    
FROM orders o
WHERE o.order_id IS NOT NULL;


-- ------------------------------------------------------------------------------
-- 2. Create payments_clean View
-- Purpose: Consolidates multiple payment installments into a single order total.
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW payments_clean AS
SELECT 
    order_id, 
    SUM(payment_value) AS total_payment,
    COUNT(*) AS payment_records,
    
    -- Concatenate all payment methods used for a single order
    GROUP_CONCAT(payment_type SEPARATOR ', ') AS payment_types
FROM payments
GROUP BY order_id;