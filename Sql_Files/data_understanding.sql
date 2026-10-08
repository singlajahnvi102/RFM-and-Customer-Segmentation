Use global_electronics;
### Section 1: Data understanding
#1. How many customers are there, and how many have at least one order?
SELECT 
    COUNT(DISTINCT c.customerkey) AS total_customers,
    COUNT(DISTINCT s.customerkey) AS customers_with_orders
FROM customers c
left JOIN sales s
    ON c.customerkey = s.customerkey;
    
-- There are 15,266 customers and 11887 customers with orders.It means 3,379 didnt buy.

#2. What is the date range of the orders?
SELECT 
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM
    sales;
 --    First order date is 2016-01-01 and last date is 2021-02-20
#3. Are there duplicate orders or missing customer keys?
select order_number,Line_Item,count(*) as duplicate_orders
from sales 
group by order_number,Line_Item
having count(*)>1;
-- No missing order_id

select customerkey from sales
where customerkey is null;

 --  No missing customerkeys

