--- dim date
CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.dim_date` AS
SELECT DISTINCT
  PARSE_DATE('%Y%m%d', date) AS date,
  EXTRACT(DAY FROM PARSE_DATE('%Y%m%d', date)) AS day,
  EXTRACT(MONTH FROM PARSE_DATE('%Y%m%d', date)) AS month,
  EXTRACT(YEAR FROM PARSE_DATE('%Y%m%d', date)) AS year,
  EXTRACT(WEEK FROM PARSE_DATE('%Y%m%d', date)) AS week,
  EXTRACT(QUARTER FROM PARSE_DATE('%Y%m%d', date)) AS quarter,
  EXTRACT(DAYOFWEEK FROM PARSE_DATE('%Y%m%d', date)) AS day_of_week
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`;

--- dim customer 

CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.dim_customer` AS
SELECT DISTINCT
  fullVisitorId AS full_visitor_id,
  geoNetwork.country AS geo_country,
  device.deviceCategory,
  IFNULL(totals.newVisits, 0) AS new_visit_flag
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`;

--- dim product

CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.dim_product` AS
SELECT DISTINCT
  p.productSKU AS product_sku,
  p.v2ProductName AS product_name,
  p.v2ProductCategory AS product_category,
  SAFE_DIVIDE(SUM(p.productRevenue), SUM(p.productQuantity)) / 1e6 AS avg_unit_price
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS h,
  UNNEST(h.product) AS p
WHERE
  p.productSKU IS NOT NULL
GROUP BY
  product_sku, product_name, product_category;

  
--- dim traffic source

CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.dim_traffic_source` AS
SELECT DISTINCT
  trafficSource.source,
  trafficSource.medium,
  trafficSource.campaign
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`;

--- dim device

CREATE OR REPLACE TABLE `nomadic-freedom-454920-v8.google_analytics_model.dim_device` AS
SELECT DISTINCT
  device.deviceCategory,
  device.browser,
  device.operatingSystem
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`;
