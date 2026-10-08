### Section 5: Business impact
-- 1. What percentage of total revenue comes from each segment?

select c.customer_segmentation as segment,Round(sum(r.monetary),2) as revenue,Round(sum(r.monetary)*100/sum(sum(r.monetary)) over(),2) as revenue_pct
from rfm_base r 
join customer_segmentation c 
on r.customerkey=c.customerkey
group by c.customer_segmentation
order by revenue_pct desc;
-- Champions are only 1,298 customers (about 11% of buyers) but bring the highest share of revenue (24.16%).
-- Lost customers are still 21.60% of revenue, and
-- At Risk is the smallest segment at 8.42%. Revenue is spread across segments, so losing the Champions or the At Risk group would hurt but no single group carries it all.
-- NOTE: percentages are of revenue from customers who bought (Never_Purchased has no revenue).


-- 2. What is the average order value per segment?
SELECT 
    c.customer_segmentation AS segment,
    SUM(r.frequency) AS orders,
    SUM(r.monetary) AS revenue,
    ROUND(SUM(r.monetary) / SUM(r.frequency), 2) AS avg_order_value
FROM
    rfm_base r
        JOIN
    customer_segmentation c ON r.customerkey = c.customerkey
GROUP BY c.customer_segmentation;

-- AOV is almost the same in every segment (2,042 to 2,244).
--  Champions do not place bigger orders. They place MORE orders (6,351 orders from 1,298 customers, about 4.9 each)
--  Segment value is driven by purchase frequency, not order size.
-- ACTION: focus campaigns on repeat purchases, not on bigger baskets.

-- 3. Which segment has the highest profit margin?
SELECT 
    c.customer_segmentation AS segment,
    SUM(p.unit_price_usd * s.quantity) - SUM(p.unit_cost_usd * s.quantity) AS profit,
    ROUND((SUM(p.unit_price_usd * s.quantity) - SUM(p.unit_cost_usd * s.quantity)) * 100 / SUM(p.unit_price_usd * s.quantity),
            2) AS profit_margin
FROM
    sales s
        JOIN
    products p ON s.productkey = p.productkey
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
GROUP BY c.customer_segmentation
ORDER BY profit_margin DESC;

-- Margins are nearly identical (58.15% to 58.73%, a gap of under 0.6 points).
-- Potential Loyalist is highest and At Risk is lowest. 
-- Margin depends on the products bought, not on the customer group, so margin should not decide who gets campaign budget.
-- LIMITATION: the data has no discount information, so profit is at list price.


-- 4. Do Champions buy different product categories than At Risk customers?
select p.category,c.customer_segmentation,sum(p.unit_price_usd*s.quantity) 
as revenue,round(sum(p.unit_price_usd*s.quantity)*100/sum(sum(p.unit_price_usd*s.quantity))
over(partition by c.customer_segmentation),2) as product_category_pct FROM
    sales s
        JOIN
    products p ON s.productkey = p.productkey
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
where c.customer_segmentation in ('Champions','At_risk')
GROUP BY c.customer_segmentation,p.category;

-- Both groups spend most on Computers (Champions 35.60%, At Risk 31.52%), so their tastes are similar.
--  The clearest difference is Home Appliances: 24.94% of At Risk revenue
-- against a much lower share for Champions about 16.72%.
-- ACTION: a win-back offer for At Risk customers should feature Computers and Home Appliances.

































