use global_electronics;
-- 1. How many rows are in each table? *(Sales 62,884, Customers 15,266, Products 2,517, Stores 67)*
SELECT 
    COUNT(*)
FROM
    Sales;
SELECT 
    COUNT(*)
FROM
    products;
SELECT 
    COUNT(*)
FROM
    customers;
SELECT 
    COUNT(*)
FROM
    stores;


-- 2. How many distinct orders are there? *(26,326)*
SELECT 
    COUNT(DISTINCT order_number) AS distinct_order_number
FROM
    sales;

-- 3. What are the first and last order dates? *(1 Jan 2016 to 20 Feb 2021)*
SELECT 
    MAX(order_date) AS last_date, MIN(order_date) AS first_date
FROM
    sales;

-- 4. Are there duplicate `Order Number` + `Line Item` pairs? *(0)*
SELECT 
    COUNT(*) duplicate_odr_no_Line_item
FROM
    sales
GROUP BY order_number , line_item
HAVING COUNT(*) > 1;

-- 5. Does every `CustomerKey`, `ProductKey`, and `StoreKey` in Sales exist in its own table? *(Yes, no orphans)*
SELECT 
    s.Order_Number
FROM
    Sales s
        LEFT JOIN
    Customers c ON s.CustomerKey = c.CustomerKey
        LEFT JOIN
    Products p ON s.ProductKey = p.ProductKey
        LEFT JOIN
    Stores st ON s.StoreKey = st.StoreKey
WHERE
    c.CustomerKey IS NULL
        OR p.ProductKey IS NULL
        OR st.StoreKey IS NULL;

-- 6. How many customers have never placed an order? *(3,379)*
SELECT 
    COUNT(c.customerkey) AS customerkey
FROM
    customers c
        LEFT JOIN
    sales s ON c.customerkey = s.customerkey
WHERE
    s.customerkey IS NULL;

-- 7. How many customers ordered exactly once, as a percentage of buyers? *(about 38.8%)*
with orders_per_customer as(select customerkey,count(distinct order_number) as orders
from sales 
group by customerkey)
select count(case when orders = 1 then 1 end) as one_time_customers,
count(*) as total_buyers,
Round(count(case when orders = 1 then 1 end)*100/count(*),2) as pct_of_buyers from orders_per_customer;

 -- 8. What does `StoreKey = 0` represent, and what share of sales lines does it have? *(Online store, about 21%)*
SELECT 
    ROUND(SUM(storekey = 0) * 100 / COUNT(*), 2) AS sales_line
FROM
    sales;

-- 9. Is `Delivery Date` blank for every non-online order? *(Yes)*
SELECT 
    COUNT(delivery_date) AS delivery_date
FROM
    sales s
        JOIN
    stores st ON st.storekey = s.storekey
WHERE
    country != 'online'
        AND delivery_date IS NULL;
 

-- -- 10. Are there any orders with more than one customer, store, or date? *(0)*
SELECT 
    COUNT(DISTINCT customerkey) AS customerkey,
    COUNT(DISTINCT storekey) AS storekey,
    COUNT(DISTINCT order_date) AS order_date
FROM
    sales s
GROUP BY order_number
HAVING COUNT(DISTINCT customerkey) > 1
    OR COUNT(DISTINCT storekey) > 1
    OR COUNT(DISTINCT order_date) > 1;

-- -- 11. Does every sale have a matching exchange rate for its currency and date? *(Yes, 0 missing)*
SELECT 
    s.order_number, s.order_date
FROM
    sales s
        LEFT JOIN
    exchange_rate e ON s.currencycode = e.currency
        AND s.order_date = e.date
WHERE
    e.exchange IS NULL;


-- -- 12. Does each customer country map to a single currency? *(Yes)*
SELECT 
    c.country, COUNT(DISTINCT e.currency)
FROM
    customers c
        JOIN
    sales s ON c.customerkey = s.customerkey
        JOIN
    exchange_rate e ON s.currencycode = e.currency
GROUP BY c.country
HAVING COUNT(DISTINCT e.currency) > 1;

-- -- 13. Are there any products where price is less than or equal to cost? *(0)*
SELECT 
    COUNT(productkey) AS productkey
FROM
    products
WHERE
    unit_price_usd <= unit_cost_usd;


-- -- 14. What is the average profit margin across products? *(about 59%, unusually high)*
SELECT 
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) * 100 / SUM(s.quantity * p.unit_price_usd),
            2) AS weighted_margin_pct
FROM
    products p
        JOIN
    sales s ON p.productkey = s.productkey;

-- -- 15. How many customers have a na `State Code`, and where are they from? *(10, all Napoli, Italy)*
SELECT 
    customerkey, country
FROM
    customers
WHERE
    state_code = 'na';

-- -- 16. How many customer names appear more than once? *(148, so never dedupe by name)*
SELECT 
    COUNT(*) - COUNT(DISTINCT name) AS customer_sharing_names2
FROM
    customers;
-- The ans is different from claude due to different accents

SELECT 
    YEAR(s.order_date) AS order_year,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS revenue,
    ROUND(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)),
            2) AS profit
FROM
    products p
        JOIN
    sales s ON p.productkey = s.productkey
WHERE
    YEAR(s.order_date) <> 2021
GROUP BY YEAR(s.order_date)
ORDER BY order_year;
