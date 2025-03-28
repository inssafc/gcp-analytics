WITH user_months AS (
  SELECT
    full_visitor_id AS user_id,
    FORMAT_DATE('%Y-%m', date) AS activity_month
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales`
  GROUP BY
    user_id, activity_month
),

monthly_users AS (
  SELECT
    activity_month,
    COUNT(DISTINCT user_id) AS active_users
  FROM
    user_months
  GROUP BY
    activity_month
),

churn_calculation AS (
  SELECT
    curr.activity_month AS month,
    COUNT(DISTINCT curr.user_id) AS users_in_month,
    COUNT(DISTINCT next.user_id) AS users_retained_next_month,
    COUNT(DISTINCT curr.user_id) - COUNT(DISTINCT next.user_id) AS churned_users,
    ROUND(
      SAFE_DIVIDE(COUNT(DISTINCT curr.user_id) - COUNT(DISTINCT next.user_id), COUNT(DISTINCT curr.user_id)),
      4
    ) AS churn_rate
  FROM
    user_months curr
  LEFT JOIN
    user_months next
  ON
    curr.user_id = next.user_id
    AND DATE_TRUNC(PARSE_DATE('%Y-%m', next.activity_month), MONTH) =
        DATE_ADD(DATE_TRUNC(PARSE_DATE('%Y-%m', curr.activity_month), MONTH), INTERVAL 1 MONTH)
  GROUP BY
    curr.activity_month
  ORDER BY
    curr.activity_month
)

SELECT
  month,
  users_in_month,
  users_retained_next_month,
  churned_users,
  churn_rate
FROM
  churn_calculation;
