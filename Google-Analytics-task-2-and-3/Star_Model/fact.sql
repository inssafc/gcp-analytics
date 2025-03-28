CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.fact_sales` AS
SELECT
  fullVisitorId AS full_visitor_id,
  visitId AS visit_id,
  PARSE_DATE('%Y%m%d', date) AS date,
  h.transaction.transactionId AS transaction_id,
  p.productSKU AS product_sku,
  p.v2ProductName AS product_name,
  p.v2ProductCategory AS product_category,
  totals.bounces AS bounces,                  
  totals.hits AS hits,                        
  totals.pageviews AS pageviews, 
  p.productQuantity AS quantity,
  p.productRevenue / 1e6 AS item_revenue,
  totals.transactionRevenue / 1e6 AS transaction_revenue,
  trafficSource.source AS traffic_source,
  trafficSource.medium AS medium,
  device.deviceCategory
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS h
  LEFT JOIN UNNEST(h.product) AS p
WHERE
  h.transaction.transactionId IS NOT NULL;
