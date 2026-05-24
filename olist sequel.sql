--On-time delivery rate overall
SELECT
  COUNT(*)                                                            AS delivered_orders,
  COUNT(*) FILTER (WHERE delivered_customer_date <= estimated_delivery_date)
                                                                      AS on_time,
  COUNT(*) FILTER (WHERE delivered_customer_date > estimated_delivery_date)
                                                                      AS late,
  ROUND(
    COUNT(*) FILTER (WHERE delivered_customer_date <= estimated_delivery_date)
    * 100.0 / COUNT(*), 1)                                         AS on_time_pct,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (delivered_customer_date - purchase_timestamp)) / 86400), 1)  AS avg_actual_days,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (estimated_delivery_date - purchase_timestamp)) / 86400), 1) AS avg_estimated_days
FROM orders
WHERE status = 'delivered'
  AND delivered_customer_date IS NOT NULL;


--Delivery performance by customer state
SELECT
  c.state,
  COUNT(*)                                                           AS orders,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (o.delivered_customer_date - o.purchase_timestamp)) / 86400), 1
  )                                                                   AS avg_delivery_days,
  ROUND(COUNT(*) FILTER (WHERE
    o.delivered_customer_date > o.estimated_delivery_date
  ) * 100.0 / COUNT(*), 1)                                       AS late_rate_pct,
  ROUND(AVG(r.review_score), 2)                                     AS avg_review
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.status = 'delivered'
  AND o.delivered_customer_date IS NOT NULL
GROUP BY c.state
ORDER BY avg_delivery_days DESC;

