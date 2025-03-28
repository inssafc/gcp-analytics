WITH user_segments AS (
  SELECT
    full_visitor_id AS user_id,
    SUM(IFNULL(hits, 0)) AS total_hits,
    SUM(IFNULL(pageviews, 0)) AS total_pageviews,
    SUM(IFNULL(transaction_revenue, 0)) AS total_revenue,
    CASE
      WHEN SUM(IFNULL(hits, 0)) < 100 OR SUM(IFNULL(pageviews, 0)) < 100 THEN 'Low'
      WHEN SUM(IFNULL(hits, 0)) > 1500 AND SUM(IFNULL(pageviews, 0)) > 1500 THEN 'High'
      ELSE 'Medium'
    END AS engagement_segment
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales`
  GROUP BY
    user_id
)

SELECT
  engagement_segment,
  ROUND(SUM(total_revenue), 2) AS total_revenue,
  ROUND(AVG(total_revenue), 2) AS avg_revenue_per_user
FROM
  user_segments
GROUP BY
  engagement_segment
ORDER BY
  total_revenue DESC;
