### Section 3: Scoring
#1. How do you split each of R, F, and M into scores of 1 to 5? (`NTILE(5)` or fixed thresholds, since Frequency has many ties)
create table rfm_scored as with m_score as(select customerkey,monetary,ntile(5) over(order by monetary )
 as monetary_score from rfm_base),
r_score as(select customerkey,recency_days,ntile(5) over(order by recency_days desc ) as  recency_days_score  from rfm_base order by recency_days_score desc),
f_score as(select customerkey,case when frequency>=5 Then (5)
 when frequency=4 Then (4)
 when frequency=3 Then (3) 
 when frequency=2 Then (2)
 else (1) end frequency_score from rfm_base)
 select m.customerkey,r.recency_days_score,m.monetary_score,f.frequency_score
 from m_score m
 join r_score r
 on m.customerkey=r.customerkey
 join f_score f 
 on m.customerkey=f.customerkey;
 
#2. What is the combined RFM score for each customer, like 555 or 211?
with m_score as(select customerkey,monetary,ntile(5) over(order by monetary ) as monetary_score from rfm_base),
r_score as(select customerkey,recency_days,ntile(5) over(order by recency_days desc ) as  recency_days_score  from rfm_base),
f_score as(select customerkey,case when frequency>=5 Then (5)
 when frequency=4 Then (4)
 when frequency=3 Then (3) 
 when frequency=2 Then (2)
 else (1) end frequency_score from rfm_base)
 select m.customerkey,concat(r.recency_days_score,f.frequency_score,m.monetary_score) as rfm_score
 from m_score m
 join r_score r
 on m.customerkey=r.customerkey
 join f_score f 
 on m.customerkey=f.customerkey;