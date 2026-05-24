--monthly GMV trend
SELECT
  DATE_TRUNC('month', o.purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id)               AS orders,
  COUNT(DISTINCT o.customer_id)            AS unique_customers,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
  ROUND(AVG(oi.price + oi.freight_value), 2) AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
  AND o.purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY 1
ORDER BY 1;

--payment method breakdown
SELECT
  payment_type,
  COUNT(*)                                           AS transactions,
  ROUND(SUM(payment_value), 2)                      AS total_value,
  ROUND(AVG(payment_value), 2)                      AS avg_value,
  ROUND(AVG(payment_installments), 1)              AS avg_installments,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_share
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;


--day of the week purchase pattern
SELECT
  DATE_TRUNC('month', o.purchase_timestamp) AS month,
  COUNT(DISTINCT o.order_id)               AS orders,
  COUNT(DISTINCT o.customer_id)            AS unique_customers,
  ROUND(SUM(oi.price + oi.freight_value), 2) AS gmv,
  ROUND(AVG(oi.price + oi.freight_value), 2) AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
  AND o.purchase_timestamp BETWEEN '2017-01-01' AND '2018-08-31'
GROUP BY 1
ORDER BY 1;