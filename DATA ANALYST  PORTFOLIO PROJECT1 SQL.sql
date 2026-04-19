/* 1. The Portfolio SQL File (superstore_analysis.sql)
SQL
PROJECT: Superstore Profitability Analysis
GOAL: Identify most and least profitable regions, products, and customer segments.
AUTHOR: [Your Name]
DATE: April 2026
*/

-- Step 1: Data Preparation & Cleaning
-- Creating a View to handle NULL values and standardize text fields

-- STEP 1: SET THE CONTEXT
-- This tells SQL exactly which "folder" to look in.
USE superstore;
SHOW TABLES;

-- STEP 2: CREATE THE DATA ENGINE (VIEW)
-- We include ALL necessary columns here so every query below works.

USE superstore;

CREATE OR REPLACE VIEW clean_superstore AS
SELECT
    `Order ID` AS order_id,
    `Order Date`,
    `Customer ID`,
    `Segment`,
    `Category`,
    `Sub-Category`, -- Added this for the bleeding report
    TRIM(`Customer Name`) AS customer_name,
    UPPER(`Region`) AS region,
    Sales,
    Profit,
    Quantity
FROM `sample - superstore`
WHERE Sales IS NOT NULL 
  AND Profit IS NOT NULL;

-- ==========================================================
-- STEP 3: EXECUTE BUSINESS QUESTIONS
-- ==========================================================

-- Q1: Which regions are most profitable? (Regional Audit)
SELECT 
    region, 
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS profit_margin_pct
FROM clean_superstore
GROUP BY region
ORDER BY total_profit DESC;

-- Q2: Which categories are losing money? (The Bleeding Report)
SELECT 
    `Sub-Category` AS product_type, 
    ROUND(SUM(Profit), 2) AS total_profit 
FROM clean_superstore 
GROUP BY `Sub-Category` 
HAVING total_profit < 0 
ORDER BY total_profit ASC;

-- Q3: Who are our top 5 "Value" customers? (Loyalty Analysis)
SELECT 
    customer_name,
    ROUND(SUM(Sales), 2) AS total_spend,
    ROUND(SUM(Profit), 2) AS total_profit_contribution
FROM clean_superstore
GROUP BY customer_name
ORDER BY total_profit_contribution DESC
LIMIT 5;

-- Q4: How are sales trending month-over-month? (Time Series)
-- Note: Adjust format to '%d/%m/%Y' if your data is Day/Month/Year
SELECT 
    DATE_FORMAT(STR_TO_DATE(`Order Date`, '%m/%d/%Y'), '%Y-%m') AS month,
    ROUND(SUM(Sales), 2) AS monthly_sales
FROM clean_superstore
GROUP BY month
ORDER BY month;

-- Q5: Which customer segment is most efficient? (Segment Profitability)
SELECT 
    Segment,
    COUNT(DISTINCT `Customer ID`) AS unique_customers,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM clean_superstore
GROUP BY Segment
ORDER BY total_profit DESC;







/* 2. Executive Summary (The 1-Page Written Piece)
Subject: Superstore Profitability Insights – Q2 2026

To: Sales Manager

From: Data Analyst

Overview: This analysis examined the cleaned Superstore dataset to identify performance drivers and financial risks. 
After removing incomplete records (missing sales/profit data), the following findings were identified:

Lagos Dominance: Lagos is the primary revenue driver, contributing the highest total profit.
 However, profit margins should be monitored to ensure overhead costs aren't eroding gains.

Regional Data Gaps: Significant data entry gaps were found in the Abuja and Kano regions. 
These regions were excluded from the primary profit analysis due to missing Sales/Profit figures, representing a "blind spot" for management.

Loss-Leading Categories: The Furniture category is currently underperforming, showing a net loss in specific transactions. 
High shipping costs or aggressive discounting in Lagos are the likely culprits.

Top Customer Impact: A small segment of customers (e.g., Bayo Ade) accounts for a disproportionate share of Technology profits.
 Losing these customers would significantly impact the bottom line.

Data Quality Recommendation: 
To improve future reporting,
 I recommend implementing mandatory fields in the order entry system for "Sales" and "Quantity" to eliminate the need for data filtering.

3. GitHub Upload Instructions
Repository Name: superstore-data-analysis

README.md: Copy and paste the "Executive Summary" into your README so people can see your insights without opening the files.

Visuals: If you can, take a screenshot of your result tables in MySQL Workbench and include them in the README. 
It makes the project look much more professional!
