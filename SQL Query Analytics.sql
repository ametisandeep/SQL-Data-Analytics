-- top 10 highest revenue generating products

SELECT TOP 10 product_id, SUM(sale_price) AS Sales
FROM df_orders
GROUP BY product_id
ORDER BY Sales DESC

-- top 5 highest selling products in each region

WITH cte AS (
SELECT region, product_id, SUM(sale_price) AS Sales
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM(
SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY Sales DESC) AS rn
FROM cte) AS rnn
WHERE rn <=5

-- month over month growth comparison 2022 vs 2023

WITH CTE AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month, 
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month


-- Category wise - highest month/year sales

WITH CTE AS (
SELECT category, FORMAT(order_date, 'yyyyMM') AS order_year_month,
SUM(sale_price) AS sales
FROM df_orders
GROUP BY category, FORMAT(order_date, 'yyyyMM')
)
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM CTE) AS rnn
WHERE rn = 1


-- sub-category that has highest growth

WITH CTE AS (
    SELECT sub_category,
        YEAR(order_date) AS order_year, 
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
CTE2 AS (
SELECT 
    sub_category, 
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY sub_category)
SELECT TOP 1 *, (sales_2023 - sales_2022)*100/sales_2022 AS percent_growth
FROM CTE2
ORDER BY (sales_2023 - sales_2022)*100/sales_2022 DESC