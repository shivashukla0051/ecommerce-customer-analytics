# ecommerce-customer-analytics
End-to-end E-Commerce Data Analytics project featuring RFM Segmentation, Cohort Retention, and Funnel Analysis using SQL and Tableau
# 🛒 E-Commerce Customer & Operations Analytics 
<img width="2838" height="1354" alt="Dashboard 1" src="https://github.com/user-attachments/assets/c2f4a9b6-c953-41c2-9e9a-89e0c61fc5b2" />


## 📌 Project Overview
This project is an end-to-end data analytics and business intelligence solution designed to extract actionable insights from a real-world Brazilian e-commerce dataset (Olist). The primary goal is to bridge the gap between customer behavior and supply chain logistics by optimizing marketing strategies through advanced segmentation, and tracking delivery performance across different regions.

🔗 **(https://public.tableau.com/views/Ecommerce_Customer_Analytics/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

## 🛠️ Tech Stack & Skills
* **Database & Querying:** SQL (MySQL / PostgreSQL) – *Complex Joins, Window Functions, CTEs, Data Aggregation.*
* **Data Visualization & BI:** Tableau – *Interactive Executive Dashboards, Parameter Actions, Calculated Fields.*
* **Analytical Frameworks:** RFM Segmentation, Cohort Analysis, Conversion Funnel Mapping.

## 📊 Key Analytical Workstreams
1. **RFM Segmentation:** Categorized customers into distinct behavioral segments (Champions, At Risk, Loyal, etc.) based on Recency, Frequency, and Monetary value to drive targeted CRM strategies and optimize customer acquisition cost (CAC).
2. **Cohort Retention Heatmap:** Tracked month-over-month customer retention tracking to evaluate long-term brand loyalty and pinpoint exactly when users churn.
3. **Conversion Funnel Analysis:** Mapped the end-to-end user journey from order creation to final delivery, identifying operational bottleneck stages.
4. **Logistics & Delivery Tracking:** Analyzed delivery failure rates and lead times across different geographic states to pinpoint supply chain inefficiencies.

## 💡 Top Business Insights & Recommendations
* **The Pareto Principle in Action (RFM):** The "Champions" and "Loyal Customers" segments comprise only a small fraction of the user base (~11%) but drive approximately 38% of the total revenue. 
  * *Recommendation:* Implement a 'Champions Protection Programme' with VIP perks and zero-cost shipping to secure and nurture this high-value revenue stream.
* **Supply Chain Bottlenecks (Logistics):** Funnel and state-wise delivery analysis revealed that certain remote states experience a 12-15% higher delivery delay/failure rate compared to metropolitan areas, directly correlating with lower customer satisfaction.
  * *Recommendation:* Optimize regional warehouse routing or partner with localized 3PL (Third-Party Logistics) providers for specific high-failure states to reduce order processing times.
* **Month-1 Retention Drop-off (Cohort):** The cohort retention heatmap indicates a steep drop-off after the initial purchase month, with the return rate plummeting below 3%.
  * *Recommendation:* Trigger automated, personalized email campaigns offering targeted discounts around Day 25 post-purchase to incentivize second orders and improve Month-2 retention metrics.

## 📂 Repository Structure
* `/sql_queries` - Contains structured SQL scripts for data cleaning, table joins, and aggregated metric generation (Funnel, RFM, Cohorts).
* `/tableau` - Contains the exported Tableau workbook (`.twbx`) and dashboard visual assets.
* `/data` - Contains references to the processed raw datasets used for visualization.
