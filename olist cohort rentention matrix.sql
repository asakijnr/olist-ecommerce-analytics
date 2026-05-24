--Cohort retention matrix
WITH first_purchase AS (
  SELECT
    c.customer_unique_id,
    DATE_TRUNC('month', MIN(o.purchase_timestamp)) AS cohort_month
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  WHERE o.status = 'delivered'
  GROUP BY c.customer_unique_id
),
all_orders AS (
  SELECT
    c.customer_unique_id,
    DATE_TRUNC('month', o.purchase_timestamp) AS order_month
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  WHERE o.status = 'delivered'
),
cohort_data AS (
  SELECT
    fp.cohort_month,
    ao.order_month,
    EXTRACT(YEAR FROM AGE(ao.order_month, fp.cohort_month)) * 12
    + EXTRACT(MONTH FROM AGE(ao.order_month, fp.cohort_month)) AS period_number,
    COUNT(DISTINCT ao.customer_unique_id) AS retained_customers
  FROM first_purchase fp
  JOIN all_orders ao ON fp.customer_unique_id = ao.customer_unique_id
  GROUP BY 1,2,3
),
cohort_size AS (
  SELECT cohort_month, COUNT(*) AS cohort_customers
  FROM first_purchase
  GROUP BY cohort_month
)
SELECT
  cd.cohort_month,
  cs.cohort_customers,
  cd.period_number,
  cd.retained_customers,
  ROUND(cd.retained_customers * 100.0 / cs.cohort_customers, 1) AS retention_rate
FROM cohort_data cd
JOIN cohort_size cs ON cd.cohort_month = cs.cohort_month
WHERE cd.period_number BETWEEN 0 AND 11
ORDER BY cd.cohort_month, cd.period_number;