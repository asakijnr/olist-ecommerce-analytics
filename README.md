# Brazilian E-Commerce Analytics — Olist Dataset

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-1D9E75?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-1D9E75?style=flat)

A full end-to-end analytics project on 100,000 real Brazilian e-commerce orders from Olist (2016–2018). Built entirely from scratch — raw CSV ingestion, PostgreSQL data modeling, advanced SQL analysis, and a 6-page executive Power BI dashboard.

---

## Business Context

Olist is a Brazilian marketplace aggregator connecting small merchants to major e-commerce platforms. This dataset covers ~100,000 orders across 27 Brazilian states, with data on customers, sellers, products, payments, reviews, and logistics.

**Core business questions this project answers:**

- Where is revenue growing and what is driving it?
- Which customers are most valuable and which are at risk of leaving?
- Which product categories dominate, and which are underperforming?
- Which sellers are hurting the platform through late deliveries and poor reviews?
- How does geography impact delivery performance and customer satisfaction?

---

## Project Architecture

```
Raw CSV Files (Kaggle)
        │
        ▼
PostgreSQL 18 (olist database)
        │
        ├── 9 normalized tables
        ├── RFM segmentation views
        ├── Cohort retention analysis
        ├── CLV modeling
        ├── Seller performance views
        └── Fact + dimension views
                │
                ▼
        Power BI Desktop
                │
                └── 6-page executive dashboard
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Database | PostgreSQL 18 |
| Query Interface | pgAdmin 4 |
| Data Modeling | Star schema (fact + 4 dimensions) |
| Analysis | Advanced SQL (CTEs, window functions, NTILE, DATEDIFF) |
| Visualization | Power BI Desktop |
| DAX | 15+ custom measures |

---

## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle

| Table | Rows | Description |
|---|---|---|
| orders | 99,441 | Order lifecycle and timestamps |
| order_items | 112,650 | Line items per order |
| order_payments | 103,886 | Payment method and installments |
| order_reviews | 99,224 | Customer review scores |
| customers | 99,441 | Customer location data |
| sellers | 3,095 | Seller location data |
| products | 32,951 | Product attributes and categories |
| category_translation | 71 | Portuguese → English category names |
| geolocation | 1,000,163 | ZIP code coordinates |

---

## SQL Analysis — Key Techniques Used

### RFM Customer Segmentation
```sql
WITH rfm_scores AS (
  SELECT
    customer_unique_id,
    DATE '2018-10-01' - MAX(o.order_purchase_timestamp)::date AS recency_days,
    COUNT(DISTINCT o.order_id)                                 AS frequency,
    ROUND(SUM(oi.price + oi.freight_value), 2)                AS monetary,
    NTILE(5) OVER (ORDER BY MAX(o.order_purchase_timestamp) DESC) AS r_score,
    NTILE(5) OVER (ORDER BY COUNT(DISTINCT o.order_id) ASC)       AS f_score,
    NTILE(5) OVER (ORDER BY SUM(oi.price + oi.freight_value) ASC) AS m_score
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT *,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND m_score >= 4 THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
    WHEN r_score <= 2 AND f_score >= 2 THEN 'Cannot Lose Them'
    WHEN r_score <= 2               THEN 'Lost'
    ELSE 'Needs Attention'
  END AS segment
FROM rfm_scores;
```

### Cohort Retention Matrix
Groups customers by first purchase month and tracks return rates across 12 subsequent months using date arithmetic and window aggregation.

### Seller Performance Scorecard
Cross-joins seller data with delivery timestamps and review scores to compute late delivery rates, average delivery days, and review quality per seller — filterable by state.

### Delivery vs. Review Correlation
Calculates average actual delivery days against average estimated delivery days per review score band, quantifying the operational cost of late deliveries in customer satisfaction points.

---

## Key Findings

### Revenue
- **Total GMV:** BRL 15.86M across 99,441 orders (2017–2018)
- **AOV:** BRL 160.80 — consistent with Brazilian installment buying culture
- **79.7%** of payments made by credit card, averaging **3.7 installments**
- **November 2017** Black Friday spike: +94% MoM GMV
- Top category: **health_beauty** — highest revenue and order volume

### Customer Intelligence
- **Champions segment** generates **28.09%** of total revenue from a small % of customers — textbook 80/20
- **35,000+ customers** fall in the "Cannot Lose Them" segment — bought once, never returned
- Cohort retention drops below **5% by month 2** across all cohorts — platform-wide re-engagement opportunity
- **São Paulo** dominates volume; **Rio de Janeiro** and **Brasília** show higher revenue per customer

### Operations & Logistics
- **Overall on-time delivery rate: 92%**
- **Average delivery time: 12.41 days** nationally
- **Amazonas (AM) sellers: 70% late delivery rate** — northern logistics infrastructure is the core operational risk
- Northern states (AM, RR, AP) average **28–35 day** delivery times vs. 7–10 days for SP
- Every **1 day past estimated delivery** correlates with measurable review score decline

### Seller Performance
- Top seller by GMV: **BRL 226.99K** — single seller accounting for disproportionate platform revenue
- Sellers with >10% late rate average **0.8 points lower** review score
- SP-based sellers dominate volume but AM/MA sellers have the highest late rates

---

## Dashboard — 6 Pages

### Page 1 — Executive Command Center
KPI cards (GMV, Orders, Customers, Avg Review), revenue trend line, order status donut, month/year slicers.

### Page 2 — Revenue Intelligence
Monthly GMV column chart, revenue by category treemap, payment type breakdown, AOV and freight ratio cards, installments analysis.

### Page 3 — Customer Intelligence
RFM segment bar chart, RFM scatter plot (recency vs monetary, colored by segment), CLV by state, Champions Revenue Share card (28.09%), cohort retention matrix.

### Page 4 — Product Performance
Top 15 categories by revenue, orders by price bucket distribution, revenue by category treemap with English labels.

### Page 5 — Seller Performance
Seller scorecard table (GMV, orders, avg price, avg review), late rate by seller state, delivery days vs review score scatter, Top Seller GMV card.

### Page 6 — Operations & Logistics
On-Time Rate card (92%), Avg Delivery Days card (12.41), delivery days by customer state, on-time rate trend over time.

---

## Repository Structure

```
olist-ecommerce-analytics/
│
├── sql/
│   ├── 01_schema.sql              # All CREATE TABLE statements
│   ├── 02_views.sql               # Analytical views (RFM, cohort, seller, fact)
│   ├── 03_rfm_segmentation.sql    # Full RFM scoring and labeling
│   ├── 04_cohort_retention.sql    # Monthly cohort retention matrix
│   ├── 05_clv_analysis.sql        # Customer lifetime value by state
│   ├── 06_seller_performance.sql  # Seller scorecard queries
│   └── 07_delivery_ops.sql        # Logistics and on-time delivery analysis
│
├── dashboard/
│   └── olist_dashboard.pbix       # Power BI file
│
├── screenshots/
│   ├── 01_executive.png
│   ├── 02_revenue.png
│   ├── 03_customer_intelligence.png
│   ├── 04_product_performance.png
│   ├── 05_seller_performance.png
│   └── 06_operations.png
│
└── README.md
```

---

## How to Run This Project

### Prerequisites
- PostgreSQL 14–16 (recommended) or PostgreSQL 18
- pgAdmin 4
- Power BI Desktop (Windows)
- [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) downloaded from Kaggle

### Setup

**1. Create the database**
```sql
CREATE DATABASE olist;
```

**2. Run the schema**
```bash
psql -U postgres -d olist -f sql/01_schema.sql
```

**3. Load the CSV files**
```sql
\COPY customers FROM '/your/path/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY sellers FROM '/your/path/olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY products FROM '/your/path/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY category_name_translation FROM '/your/path/product_category_name_translation.csv' DELIMITER ',' CSV HEADER;
\COPY orders FROM '/your/path/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY order_items FROM '/your/path/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY order_payments FROM '/your/path/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;
\COPY order_reviews FROM '/your/path/olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;
```

**4. Create analytical views**
```bash
psql -U postgres -d olist -f sql/02_views.sql
```

**5. Open Power BI**
- Open `dashboard/olist_dashboard.pbix`
- Update the data source connection to your PostgreSQL instance
- Refresh the data

---

## About

Built by **Ezekiel Mbuk* — Founder, Codex Analytics

Data Analytics · ML/AI Automation · Data Engineering

[LinkedIn](https://www.linkedin.com/in/ezekiel-effiong-0175322a0/) ·
---

*Dataset credit: Olist Store and André Sionek via Kaggle (CC BY-NC-SA 4.0)*

