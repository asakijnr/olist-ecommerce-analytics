-- Date range + order volume
SELECT
  MIN(purchase_timestamp)::date   AS first_order,
  MAX(purchase_timestamp)::date   AS last_order,
  COUNT(*)                         AS total_orders,
  COUNT(DISTINCT customer_id)     AS unique_customers
FROM orders;

-- Order status distribution
SELECT
  status,
  COUNT(*)                              AS orders,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- NULL audit (check critical fields)
SELECT
  COUNT(*) FILTER (WHERE delivered_customer_date IS NULL) AS no_delivery_date,
  COUNT(*) FILTER (WHERE approved_at            IS NULL) AS no_approval,
  COUNT(*) FILTER (WHERE customer_id            IS NULL) AS no_customer
FROM orders;