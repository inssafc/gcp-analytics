-- product sales by month for the last quarter
WITH last_quarter_data AS (
  SELECT
    product_sku,
    product_name,
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    SUM(quantity) AS total_quantity
  FROM
    `nomadic-freedom-454920-v8.google_analytics_model.fact_sales`
  WHERE
    date BETWEEN '2017-06-01' AND '2017-08-31'
    AND product_sku IS NOT NULL
  GROUP BY
    product_sku, product_name, year, month
),


top_10_products AS (
  SELECT
    product_sku,
    product_name,
    SUM(total_quantity) AS total_units
  FROM
    last_quarter_data
  GROUP BY
    product_sku, product_name
  ORDER BY
    total_units DESC
  LIMIT 10
),

monthly_sales AS (
  SELECT
    lqd.product_sku,
    lqd.product_name,
    lqd.year,
    lqd.month,
    lqd.total_quantity
  FROM
    last_quarter_data lqd
  JOIN
    top_10_products top
  ON
    lqd.product_sku = top.product_sku
),

-- MoM growth per product
final_with_growth AS (
  SELECT
    ms.product_sku,
    ms.product_name,
    ms.year,
    ms.month,
    ms.total_quantity,
    ROUND(
      SAFE_DIVIDE(
        (ms.total_quantity - LAG(ms.total_quantity) OVER (PARTITION BY ms.product_sku ORDER BY ms.year, ms.month)),
        LAG(ms.total_quantity) OVER (PARTITION BY ms.product_sku ORDER BY ms.year, ms.month)
      ), 2
    ) AS mom_growth_rate
  FROM
    monthly_sales ms
)


SELECT *
FROM final_with_growth
ORDER BY product_sku, year, month;
