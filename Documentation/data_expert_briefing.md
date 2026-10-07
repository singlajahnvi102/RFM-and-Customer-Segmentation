# Global Electronics: Data Expert Briefing

**Project:** Customer Segmentation and RFM Analytics (SQL + Power BI)
**Dataset:** Maven Analytics Global Electronics Retailer
**Method:** I asked Claude to act as the company's data expert. Claude read all six CSV files and briefed me on every column and every data issue before I started work.

---

## My Prompt

> You are the data expert from the company. Now explain each column in business terms, flag anything unusual. Whatever I need to know before I start working.

---

## Data Expert Response

I've finished checking all six files, so here is the briefing.

### Sales (62,884 lines, 26,326 orders)
- **Order Number:** one order, one customer. Count distinct values for Frequency.
- **Line Item:** the position of a product within an order, not a product ID.
- **Order Date / Delivery Date:** when the order was placed and when it arrived.
- **CustomerKey, StoreKey, ProductKey:** the links to the other tables.
- **Quantity:** units bought, from 1 to 10.
- **Currency Code:** the currency the customer paid in.

### Customers (15,266)
- Name, gender, city, state, zip, country, continent, and birthday. Ages range from 19 to 86 as of the last order date.

### Products (2,517)
- Brand, color, subcategory, and category (8 categories), plus **Unit Cost USD** (production cost) and **Unit Price USD** (list price).

### Stores (67)
- Country, state, size in square meters, and open date.

### Exchange Rates
- Daily rates for USD, EUR, GBP, CAD, and AUD.

---

## What to Know Before Starting

1. **Prices are already in USD.** Revenue is `Quantity × Unit Price USD` with no conversion needed. The exchange rates only matter if you want local-currency amounts.
2. **There is no revenue column in Sales.** You must join to Products.
3. **Price and cost are stored as text** with `$` and commas. Clean them before doing any math.
4. **Data runs from 1 Jan 2016 to 20 Feb 2021.** Use 21 Feb 2021 as the recency reference date. 2021 is only about 7 weeks, so never compare it with a full year. Sales also fell in 2020 versus 2019, and the data can't explain why.
5. **StoreKey 0 is the Online store,** about 21% of lines. Delivery Date is filled only for online orders, so blank does not mean undelivered.
6. **3,379 customers (22%) never bought.** They can't get RFM scores, so they need a separate "Never purchased" group.
7. **38.8% of buyers ordered only once,** and the maximum is 14 orders. Frequency has many ties, so `NTILE(5)` will split identical values arbitrarily. Consider fixed thresholds instead.
8. **Margin looks unrealistically high** at about 59% (price minus production cost). There are no discounts in the data, so a discount analysis is not possible.
9. **Currency follows the customer's country,** and every sale has a matching exchange rate.
10. **Ten Napoli customers show a blank State Code.** It is very likely the code "NA" being read as null by the import tool.
11. **148 customer names repeat** under different keys. Do not deduplicate by name.
12. **File encodings are mixed** (Stores is UTF-8, and at least one other file is not). If accented names look garbled, re-import as Windows-1252.

Everything else was clean: no duplicate order lines, no orphaned keys, and no delivery before order date.
