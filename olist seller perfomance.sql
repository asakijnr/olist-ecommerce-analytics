--Seller scorecard
SELECT
  s.seller_id,
  s.city                                        AS seller_city,
  s.state                                       AS seller_state,
  COUNT(DISTINCT oi.order_id)                 AS total_orders,
  ROUND(SUM(oi.price), 2)                    AS gmv,
  ROUND(AVG(oi.price), 2)                    AS avg_item_price,
  ROUND(AVG(r.review_score), 2)              AS avg_rating,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (o.delivered_customer_date - o.purchase_timestamp))
    / 86400), 1)                               AS avg_delivery_days,
  COUNT(*) FILTER (WHERE
    o.delivered_customer_date > o.estimated_delivery_date) AS late_deliveries,
  ROUND(COUNT(*) FILTER (WHERE
    o.delivered_customer_date > o.estimated_delivery_date) * 100.0
    / COUNT(*), 1)                             AS late_rate_pct
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.status = 'delivered'
  AND o.delivered_customer_date IS NOT NULL
GROUP BY s.seller_id, s.city, s.state
HAVING COUNT(DISTINCT oi.order_id) >= 10
ORDER BY gmv DESC;


--Review score vs delivery time correlation
SELECT
  r.review_score,
  COUNT(*)                                      AS orders,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (o.delivered_customer_date - o.purchase_timestamp))
    / 86400), 1)                               AS avg_delivery_days,
  ROUND(AVG(
    EXTRACT(EPOCH FROM
      (o.delivered_customer_date - o.estimated_delivery_date))
    / 86400), 1)                               AS avg_days_vs_estimate
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE o.status = 'delivered'
  AND o.delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;