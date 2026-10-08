use global_electronics;
### Section 2: Build the RFM base
#1. What is each customer's last order date?
select customerkey,max(order_date) from sales
group by customerkey;

-- #2. How many distinct orders has each customer placed?
select customerkey,count(distinct order_number)
from sales 
group by customerkey;

#3. What is each customer's total spend in USD? (`Quantity × Unit Price USD`, after cleaning the text price column)
select s.customerkey,sum(s.quantity*p.unit_price_usd) as  total_spend from sales s join products p on s.productkey=p.productkey
group by s.customerkey;

#4. What reference date should be used for recency? (21 Feb 2021, the day after the last order)

CREATE TABLE rfm_base AS

WITH last_purchase AS (
    SELECT
        customerkey,
        MAX(order_date) AS last_order_date
    FROM sales
    GROUP BY customerkey
),

frequency AS (
    SELECT
        customerkey,
        COUNT(DISTINCT order_number) AS frequency
    FROM sales
    GROUP BY customerkey
),

monetary AS (
    SELECT
        s.customerkey,
        SUM(s.quantity * p.unit_price_usd) AS monetary
    FROM sales s
    JOIN products p
        ON s.productkey = p.productkey
    GROUP BY s.customerkey
)

SELECT
    lp.customerkey,
    lp.last_order_date,
    f.frequency,
    ROUND(m.monetary, 2) AS monetary,
    DATEDIFF('2021-02-21', lp.last_order_date) AS recency_days

FROM last_purchase lp

JOIN frequency f
    ON lp.customerkey = f.customerkey

JOIN monetary m
    ON lp.customerkey = m.customerkey;


SELECT 
    MAX(frequency),
    MIN(frequency),
    AVG(frequency),
    MAX(monetary),
    MIN(monetary),
    AVG(monetary),
    MAX(recency_days),
    MIN(recency_days),
    AVG(recency_days)
FROM
    rfm_base;
  
-- PURPOSE: turn raw sales lines into three measures for every buying customer.
-- METHOD: three CTEs, one for each measure, joined on customerkey:
--   last_purchase -> MAX(order_date), the customer's most recent order
--   frequency     -> COUNT(DISTINCT order_number), the number of orders (not the number of lines)
--   monetary      -> SUM(quantity x unit_price_usd), total spend in USD
-- RECENCY = days between the reference date and last_order_date.
-- REFERENCE DATE: 21 Feb 2021, the day after the last order in the data (20 Feb 2021).
-- Today's date is not used, because the data ends in 2021 and every customer would look inactive.
-- A customer who bought on the last day gets recency = 1.
-- RESULT: 11,887 customers. The 3,379 customers who never bought are not in this table.
-- VALIDATION: total orders 26,326, total spend 55,755,479.59, maximum orders 14, minimum recency 1.

-- Profiling rfm_base (MIN, MAX and AVG of frequency, monetary and recency)
-- PURPOSE: understand the data before choosing score thresholds.
-- FINDINGS:
--   Frequency: 1 to 14 orders, average 2.21. Most customers order only once or twice.
--   Monetary: 1.99 to 61,871.70, average 4,690. A few very large spenders pull the average up,
--   so the average is not a fair cut-off for scoring.
--   Recency: 1 to 1,878 days, average 615 days.
-- DECISION: Recency and Monetary use NTILE(5) to make five equal groups. Frequency uses fixed  values (1, 2, 3, 4, 5 or more orders),
-- because 38.8% of buyers have exactly one order, and
-- NTILE would split identical customers into different scores.
    
    
