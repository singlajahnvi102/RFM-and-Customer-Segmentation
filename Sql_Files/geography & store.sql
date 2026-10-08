### Section 6: Geography and stores
-- 1. Which countries or states have the most Champions?
select c.country,count(*) customers,count(case when cs.customer_segmentation='champions' then 1 end) as champions,
round(count(case when cs.customer_segmentation='champions' then 1 end)*100/count(*),2) as champion_rate_of_buyers
from customers c 
join customer_segmentation cs
on c.customerkey=cs.customerkey
group by c.country
order by champion_rate_of_buyers desc;

-- Rate is calculated among customers who made at least one purchase.

-- INSIGHT:
--   The United States has 869 of the 1,298 Champions (67%) and 48% of all buyers, so part of
--   this is size. It also has the highest rate: 15.23% of its buyers are Champions.
--   Germany (9.48%) and the United Kingdom (9.11%) come next, then Italy (6.98%),
--   Netherlands (6.93%) and Canada (6.19%). France (3.65%) and Australia (1.79%) are lowest.
--   Australia has 780 buyers, about as many as Canada has Champions per buyer, yet only 14
--   Champions, so size does not explain it.
-- ACTION: protect the US Champions with light rewards, and find out what the US does differently
-- (offers, stores, product mix) before running campaigns in the low-rate countries.
-- LIMITATION: the data shows where Champions are, not why. France (16 Champions) and the
-- Netherlands/Italy (37 each) are small, so their rates can change a lot with a few customers.



-- 2. Do online customers score differently from in-store customers?
with cte as(Select c.customerkey,count(distinct s.order_number) order_number,sum(p.unit_price_usd*s.quantity) revenue,
count(case when st.storekey=0 Then 1  end ) as online_orders ,
count(case when st.storekey<>0 Then 1 end) store_orders from sales s 
join products p 
on s.productkey=p.productkey 
join stores st 
on s.storekey=st.storekey
join customers c 
on c.customerkey=s.customerkey
group by c.customerkey),

ct as(select customerkey,customer_segmentation from customer_segmentation)

select case when c.online_orders>0  and c.store_orders>0 Then "Both"
when  c.online_orders>0  Then "Online_only" else "store_only" end channel_group,ct.customer_segmentation,
count(*) customers,round(avg(c.order_number),2) avg_orders,
round(avg(c.revenue),2) avg_revenue
from cte c 
join ct ct 
on ct.customerkey=c.customerkey
group by channel_group,ct.customer_segmentation;

