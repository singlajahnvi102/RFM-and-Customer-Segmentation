### Section 4: Segmentation
-- 1. Which are Champions,Loyal, Potential Loyalists, At Risk, and Lost?
USE global_electronics;

DROP VIEW IF EXISTS Customer_segmentation;

CREATE VIEW Customer_segmentation AS

SELECT
    c.customerkey,
    r.recency_days_score,
    r.frequency_score,
    r.monetary_score,

    CASE

        -- Customers with no purchase history
        WHEN r.customerkey IS NULL
            THEN 'Never_Purchased'

        -- Champions
        WHEN r.recency_days_score >= 4
             AND r.frequency_score >= 4
            THEN 'Champions'

        -- Loyal
        WHEN r.recency_days_score >= 3
             AND r.frequency_score >= 3
            THEN 'Loyal'

        -- Potential Loyalists
        WHEN r.recency_days_score >= 3
            THEN 'Potential_Loyalist'

        -- At Risk
        WHEN r.recency_days_score <= 2
             AND r.frequency_score >= 3
            THEN 'At_Risk'

        -- Lost
        ELSE 'Lost'

    END AS customer_segmentation

FROM customers c

LEFT JOIN rfm_score r
    ON c.customerkey = r.customerkey;
    
-- The CASE conditions run from the top and the first true one wins, so their order matters.
-- Monetary score is kept as a second layer to prioritise who gets personal outreach.
-- The logic is saved as a view (customer_segmentation) so every later question reuses it.
-- NOTE: NTILE splits customers with equal values arbitrarily, so a few customers near a score border could land in a neighbouring segment.
-- This does not change the overall picture.


-- 2. How many customers fall in each segment? (Include a separate "Never purchased" group.)
    SELECT 
        CASE
            WHEN
                r.recency_days_score IS NULL
                    AND r.frequency_score IS NULL
            THEN
                'Never_Purchased'
            WHEN
                r.recency_days_score >= 4
                    AND r.frequency_score >= 4
            THEN
                'Champions'
            WHEN
                r.recency_days_score >= 3
                    AND r.frequency_score >= 3
            THEN
                'Loyal'
            WHEN
                r.recency_days_score >= 3
                    AND r.frequency_score >= 1
            THEN
                'Potential_Loyalist'
            WHEN
                r.recency_days_score <= 2
                    AND r.frequency_score >= 3
            THEN
                'At_Risk'
            ELSE 'Lost'
        END customer_segmentation,
        COUNT(CASE
            WHEN
                r.recency_days_score IS NULL
                    AND r.frequency_score IS NULL
            THEN
                'Never_Purchased'
            WHEN
                r.recency_days_score >= 4
                    AND r.frequency_score >= 4
            THEN
                'Champions'
            WHEN
                r.recency_days_score >= 3
                    AND r.frequency_score >= 3
            THEN
                'Loyal'
            WHEN
                r.recency_days_score >= 3
                    AND r.frequency_score >= 1
            THEN
                'Potential_Loyalist'
            WHEN
                r.recency_days_score <= 2
                    AND r.frequency_score >= 3
            THEN
                'At_Risk'
            ELSE 'Lost'
        END) customers
    FROM
        rfm_scored r
            RIGHT JOIN
        customers c ON c.customerkey = r.customerkey
    GROUP BY CASE
        WHEN
            r.recency_days_score IS NULL
                AND r.frequency_score IS NULL
        THEN
            'Never_Purchased'
        WHEN
            r.recency_days_score >= 4
                AND r.frequency_score >= 4
        THEN
            'Champions'
        WHEN
            r.recency_days_score >= 3
                AND r.frequency_score >= 3
        THEN
            'Loyal'
        WHEN
            r.recency_days_score >= 3
                AND r.frequency_score >= 1
        THEN
            'Potential_Loyalist'
        WHEN
            r.recency_days_score <= 2
                AND r.frequency_score >= 3
        THEN
            'At_Risk'
        ELSE 'Lost'
    END
    ORDER BY customers desc;
    
-- Of 15,266 customers, 3,379 (22%) have never bought, so they are outside the RFM scores.
-- Among the 11,887 buyers: Lost 4,104 , Potential Loyalist 3,921
-- Loyal 1,912 , Champions 1,298 , At Risk 652 .
-- Only about 1 buyer in 10 is a Champion, and about 1 in 3 is already Lost.
-- ACTION: protect the Champions, push the Potential Loyalists toward a second and third order,
-- and stop spending on low-value Lost customers.
-- LIMITATION: the data does not say why the 3,379 never bought, so a first-purchase offer for them should be tested on a small group first.
