select * from df_orders

--find top 10 generating products(not including quantity)

SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

--find top 5 highest selling products in each region

WITH cte AS (
SELECT region,product_id,SUM(sale_price) AS sales
FROM df_orders
GROUP BY region,product_id)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn<=5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH CTE AS (
    SELECT EXTRACT(YEAR FROM order_date) AS order_year,
           EXTRACT(MONTH FROM order_date) AS order_month,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month;


--for each category which month had highest sales 
WITH CTE AS (
    SELECT category,
           TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM CTE
) a
WHERE rn = 1;




--which sub category had highest growth by profit in 2023 compare to 2022
WITH CTE AS (
    SELECT sub_category,
           EXTRACT(YEAR FROM order_date) AS order_year,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
),
CTE2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM CTE
    GROUP BY sub_category
)
SELECT *,
       (sales_2023 - sales_2022) AS growth
FROM CTE2
ORDER BY growth DESC
LIMIT 1;
