--- conversion rates over time per traffic source

WITH sessions_by_month AS (
  SELECT
    traffic_source,
    FORMAT_DATE('%Y-%m', date) AS month,
    COUNT(DISTINCT CONCAT(full_visitor_id, CAST(visit_id AS STRING))) AS total_sessions,
    COUNTIF(transaction_revenue > 0) AS converting_sessions
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales`
  WHERE
    date BETWEEN '2017-03-01' AND '2017-08-31'
    AND traffic_source IS NOT NULL
  GROUP BY
    traffic_source, month
)

SELECT
  traffic_source,
  month,
  total_sessions,
  converting_sessions,
  ROUND(SAFE_DIVIDE(converting_sessions, total_sessions), 4) AS conversion_rate
FROM
  sessions_by_month
ORDER BY
  traffic_source, month;
