--Historical CLV by customer
SELECT
  c.customer_unique_id,
  COUNT(DISTINCT o.order_id)                   AS total_orders,
  ROUND(SUM(oi.price), 2)                      AS historical_clv,
  ROUND(SUM(oi.freight_value), 2)              AS freight_paid,
  ROUND(AVG(oi.price), 2)                      AS avg_item_price,
  MIN(o.purchase_timestamp)::date               AS first_purchase,
  MAX(o.purchase_timestamp)::date               AS last_purchase,
  (MAX(o.purchase_timestamp) -
   MIN(o.purchase_timestamp))::int / 30         AS customer_lifespan_months
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY historical_clv DESC;

--CLV × RFM segment join (Power BI input)
SELECT
  rfm.customer_unique_id,
  rfm.segment,
  rfm.r_score, rfm.f_score, rfm.m_score,
  rfm.recency_days,
  rfm.frequency,
  rfm.monetary                         AS historical_clv,
  c.state                              AS customer_state
FROM v_rfm_segments rfm
JOIN customers c
  ON rfm.customer_unique_id = c.customer_unique_id
ORDER BY historical_clv DESC;


