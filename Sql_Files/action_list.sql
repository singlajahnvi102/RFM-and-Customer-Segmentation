### Section 7: Action list
###1. Which At Risk customers had high past spend? (Win-back targets)
SELECT 
    c.customerkey,
    c.customer_segmentation,
    c.recency_days_score,
    c.frequency_score,
    c.monetary_score,
    SUM(p.unit_price_usd * s.quantity) total_spent
FROM
    sales s
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
        JOIN
    products p ON p.productkey = s.productkey
WHERE
    c.customer_segmentation = 'At_risk'
GROUP BY c.customerkey , c.customer_segmentation , c.monetary_score , c.recency_days_score , c.frequency_score
HAVING c.monetary_score >= 4
ORDER BY total_spent DESC;

SELECT 
    c.customer_segmentation,
    COUNT(DISTINCT c.customerkey) AS at_risk_customers,
    COUNT(DISTINCT CASE
            WHEN c.monetary_score IN (4 , 5) THEN c.customerkey
        END) high_spend_customers,
    SUM(CASE
        WHEN c.monetary_score IN (4 , 5) THEN p.unit_price_usd * s.quantity
    END) high_risk_total_spent,
    SUM(p.unit_price_usd * s.quantity) total_spent,
    ROUND(SUM(CASE
                WHEN c.monetary_score IN (4 , 5) THEN p.unit_price_usd * s.quantity
            END) * 100 / SUM(p.unit_price_usd * s.quantity),
            2) AS high_spend_revenue_pct
FROM
    sales s
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
        JOIN
    products p ON p.productkey = s.productkey
WHERE
    c.customer_segmentation = 'At_risk'
GROUP BY c.customer_segmentation;

###"We have 652 At Risk customers, and 439 of them are high spenders. 
### These 439 customers account for 88.65% of the revenue in the At Risk group, about 4.16 million, which is roughly 7.5% of our total revenue. 
###I recommend a personal outreach (a call or an invitation) for these 439 customers, and a lighter message for the other 213."





###2. Which Lost customers should be removed from campaigns?
SELECT 
    c.customerkey,
    c.customer_segmentation,
    c.recency_days_score,
    c.frequency_score,
    c.monetary_score,
    SUM(p.unit_price_usd * s.quantity) total_spent
FROM
    sales s
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
        JOIN
    products p ON p.productkey = s.productkey
WHERE
    c.customer_segmentation = 'Lost'
GROUP BY c.customerkey , c.customer_segmentation , c.monetary_score , c.recency_days_score , c.frequency_score
HAVING c.monetary_score <=2
ORDER BY total_spent DESC;

SELECT 
    c.customer_segmentation,
    COUNT(DISTINCT c.customerkey) AS Lost_customers,
    COUNT(DISTINCT CASE
            WHEN c.monetary_score IN (1 , 2) THEN c.customerkey
        END) low_spend_customers,
    SUM(CASE
        WHEN c.monetary_score IN (1 , 2) THEN p.unit_price_usd * s.quantity
    END) low_spend_lost_revenue,
    SUM(p.unit_price_usd * s.quantity) lost_segment_revenue,
    ROUND(SUM(CASE
                WHEN c.monetary_score IN (1 ,2) THEN p.unit_price_usd * s.quantity
            END) * 100 / SUM(p.unit_price_usd * s.quantity),
            2) AS lost_spend_revenue_pct
FROM
    sales s
        JOIN
    customer_segmentation c ON s.customerkey = c.customerkey
        JOIN
    products p ON p.productkey = s.productkey
WHERE
    c.customer_segmentation = 'lost'
GROUP BY c.customer_segmentation;

-- "We have 4,104 Lost customers. 2,336 of them are low spenders, who together spent about 2.0million, only 3.6% of our total revenue. 
--  I recommend removing them from paid campaigns, which saves budget for customers who can actually respond. 
--  The other 1,768 Lost customers spent more, so they could get one low-cost reactivation message."