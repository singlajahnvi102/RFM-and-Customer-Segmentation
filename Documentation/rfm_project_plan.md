# Customer Segmentation and RFM Analytics: Global Electronics Retailer

**Tools:** SQL (MySQL) and Power BI
**Dataset:** Maven Analytics Global Electronics Retailer (Sales, Customers, Products, Stores, Exchange Rates)
**Data period:** 1 Jan 2016 to 20 Feb 2021

---

## 1. My Prompt

> Act as a client from the global electronics industry .I am a data analyst. Bring me one realistic business problem your company is facing that I could solve using data analysis. Explain the problem the way a real stakeholder would. Then let me ask you questions about it.
> I am thinking about making a project using SQL, Power BI.

---

## 2. Business Problem (from the client)

*Rohan, Head of Retail Operations at a global electronics retailer:*

> We spend a lot on marketing, but we send the same offers to everyone. Our marketing manager thinks that's wasting money. She says some customers buy often and would buy anyway, while others haven't bought in years and we keep emailing them.
>
> Next quarter we have a limited campaign budget. I need to know who our best customers are, who is slipping away, and who we should stop spending on. I'd like to give the marketing team a simple list of customer groups and a clear action for each one.
>
> I have the customer and sales data in one place. Ask me anything you need.

**Goal:** Segment customers using RFM (Recency, Frequency, Monetary), measure how much revenue and profit each segment brings, and recommend one clear action per segment.

---

## 3. Data Briefing

I also asked Claude to act as the company's data expert and explain every column and every data issue. See `data_expert_briefing.md`.

---

## 4. SQL Questions

### Section 0: Data validation (expected results in brackets)
1. How many rows are in each table? *(Sales 62,884, Customers 15,266, Products 2,517, Stores 67)*
2. How many distinct orders are there? *(26,326)*
3. What are the first and last order dates? *(1 Jan 2016 to 20 Feb 2021)*
4. Are there duplicate `Order Number` + `Line Item` pairs? *(0)*
5. Does every `CustomerKey`, `ProductKey`, and `StoreKey` in Sales exist in its own table? *(Yes, no orphans)*
6. How many customers have never placed an order? *(3,379)*
7. How many customers ordered exactly once, as a percentage of buyers? *(about 38.8%)*
8. What does `StoreKey = 0` represent, and what share of sales lines does it have? *(Online store, about 21%)*
9. Is `Delivery Date` blank for every non-online order? *(Yes)*
10. Are there any orders with more than one customer, store, or date? *(0)*
11. Does every sale have a matching exchange rate for its currency and date? *(Yes, 0 missing)*
12. Does each customer country map to a single currency? *(Yes)*
13. Are there any products where price is less than or equal to cost? *(0)*
14. What is the average profit margin across products? *(about 59%, unusually high)*
15. How many customers have a na `State Code`, and where are they from? *(10, all Napoli, Italy)*
16. How many customer names appear more than once? *(148, so never dedupe by name)*
17. What are total revenue and profit by year? *(2021 is only about 7 weeks, so exclude it from year comparisons)*

### Section 1: Data understanding
1. How many customers are there, and how many have at least one order?
2. What is the date range of the orders?
3. Are there duplicate orders or missing customer keys?

### Section 2: Build the RFM base
1. What is each customer's last order date?
2. How many distinct orders has each customer placed?
3. What is each customer's total spend in USD? (`Quantity × Unit Price USD`, after cleaning the text price column)
4. What reference date should be used for recency? (21 Feb 2021, the day after the last order)

### Section 3: Scoring
1. How do you split each of R, F, and M into scores of 1 to 5? (`NTILE(5)` or fixed thresholds, since Frequency has many ties)
2. What is the combined RFM score for each customer, like 555 or 211?

### Section 4: Segmentation
1. Which are Loyal, Potential Loyalists, At Risk, and Lost?
2. How many customers fall in each segment? (Include a separate "Never purchased" group.)

### Section 5: Business impact
1. What percentage of total revenue comes from each segment?
2. What is the average order value per segment?
3. Which segment has the highest profit margin?
4. Do Champions buy different product categories than At Risk customers?

### Section 6: Geography and stores
1. Which countries or states have the most Champions?
2. Do online customers score differently from in-store customers?

### Section 7: Action list
1. Which At Risk customers had high past spend? (Win-back targets)
2. Which Lost customers should be removed from campaigns?

---

## 5. Power BI Plan
1. Segment overview
2. Revenue and profit by segment
3. Customer list with filters
4. Recommendations for the marketing team

---

## 6. Deliverables
- SQL scripts for every section
- Power BI dashboard (screenshots and `.pbix`)
- Final recommendations: one clear action per segment
