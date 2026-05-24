--RFM scoring (NTILE 5)
WITH rfm_base AS (
  SELECT
    c.customer_unique_id,
    MAX(o.purchase_timestamp)::date                      AS last_purchase,
    COUNT(DISTINCT o.order_id)                           AS frequency,
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS monetary
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status = 'delivered'
  GROUP BY c.customer_unique_id
),
rfm_scores AS (
  SELECT
    customer_unique_id,
    last_purchase,
    frequency,
    monetary,
    DATE '2018-10-01' - last_purchase                   AS recency_days,
    NTILE(5) OVER (ORDER BY last_purchase DESC)         AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC)             AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC)              AS m_score
  FROM rfm_base
),
rfm_labeled AS (
  SELECT *,
    CONCAT(r_score, f_score, m_score)  AS rfm_cell,
    (r_score + f_score + m_score)       AS rfm_total,
    CASE
      WHEN r_score >= 4 AND f_score >= 4              THEN 'Champions'
      WHEN r_score >= 3 AND m_score >= 4              THEN 'Loyal Customers'
      WHEN r_score >= 4 AND f_score <= 2              THEN 'New Customers'
      WHEN r_score >= 3 AND f_score <= 3 AND m_score >= 3
                                                         THEN 'Potential Loyalists'
      WHEN r_score = 3 AND f_score <= 3              THEN 'At Risk'
      WHEN r_score <= 2 AND f_score >= 2              THEN 'Cannot Lose Them'
      WHEN r_score <= 2                                  THEN 'Lost'
      ELSE                                                      'Needs Attention'
    END AS segment
  FROM rfm_scores
)
SELECT * FROM rfm_labeled
ORDER BY rfm_total DESC;

--Segment summary (save as view)
CREATE VIEW v_rfm_segments AS
-- (paste full rfm_labeled CTE above here)
;

-- Segment-level summary
SELECT
  segment,
  COUNT(*)                              AS customers,
  ROUND(AVG(monetary), 2)              AS avg_spend,
  ROUND(AVG(frequency), 1)             AS avg_orders,
  ROUND(AVG(recency_days), 0)           AS avg_recency_days,
  ROUND(SUM(monetary), 2)              AS segment_revenue
FROM v_rfm_segments
GROUP BY segment
ORDER BY avg_spend DESC;