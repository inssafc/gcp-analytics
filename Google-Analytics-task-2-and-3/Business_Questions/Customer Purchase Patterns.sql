WITH top_customers AS (
  SELECT
    full_visitor_id
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales`
  WHERE
    transaction_revenue IS NOT NULL
  GROUP BY
    full_visitor_id
  ORDER BY
    SUM(transaction_revenue) DESC
  LIMIT 5
),

monthly_trends AS (
  SELECT
    fs.full_visitor_id,
    FORMAT_DATE('%Y-%m', fs.date) AS month,
    ROUND(SUM(fs.transaction_revenue), 2) AS monthly_revenue
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales` fs
  JOIN
    top_customers tc
  ON
    fs.full_visitor_id = tc.full_visitor_id
  WHERE
    fs.transaction_revenue IS NOT NULL
  GROUP BY
    fs.full_visitor_id,
    month
)

SELECT
  *
FROM
  monthly_trends
ORDER BY
  full_visitor_id,
  month;
