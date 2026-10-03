/*==============================================================
Project     : E-Commerce Sales & Revenue Performance Analysis
File        : 07_target_vs_actual.sql
Module      : Target vs Actual Analysis
Purpose     : Compare sales targets with actual realized sales
              across monthly, regional, and category dimensions
Sales Rule  : Delivered orders are treated as realized sales
Output      : Target, actual, variance, achievement percentage,
              and achievement ranking
Analysis Note: Basic target vs actual analysis only; detailed
              target analysis is covered in Project 16
==============================================================*/



/*==============================================================
  1. MONTHLY TARGET VS ACTUAL
==============================================================*/

WITH target AS (
		SELECT target_month,
			   SUM(sales_target) AS target
		FROM sales.sales_targets
		GROUP BY target_month),
		
	actual AS (
		SELECT DATE_TRUNC('month', order_date)::DATE AS month,
			   SUM(subtotal) AS actual
		FROM sales.orders
		WHERE order_status = 'Delivered'
		GROUP BY month)
		
SELECT t.target_month AS period,
	   t.target,
	   a.actual,
	   (a.actual - t.target) AS variance,
	   ROUND(a.actual / t.target * 100, 2) AS achievement_percentage
FROM target t
JOIN actual a
	ON t.target_month = a.month;


			   
/*==============================================================
  2. REGION TARGET VS ACTUAL
==============================================================*/

WITH target AS (
		SELECT region,
			   SUM(sales_target) AS target
		FROM sales.sales_targets
		GROUP BY region),

	actual AS (
		SELECT c.region,
			   SUM(o.subtotal) AS actual
		FROM master.customers c
		JOIN sales.orders o
			ON c.customer_id = o.customer_id
	    WHERE o.order_status = 'Delivered'
		GROUP BY c.region)

SELECT t.region,
	   t.target,
	   a.actual,
	   (a.actual - t.target) AS variance,
	   ROUND(a.actual / t.target * 100, 2) AS achievement_percentage
FROM target t
JOIN actual a
	ON t.region = a.region;



/*==============================================================
  3. CATEGORY TARGET VS ACTUAL
==============================================================*/

WITH target AS (
		SELECT category_id,
			   SUM(sales_target) AS target
		FROM sales.sales_targets
		GROUP BY category_id),

	actual AS (
		SELECT cat.category_id,
			   cat.category_name,
			   COALESCE(SUM(
    						CASE
        						WHEN o.order_status = 'Delivered'
        						THEN oi.item_revenue
        						ELSE 0
    						END), 0) AS actual
		FROM master.categories cat
		LEFT JOIN master.products p
			ON cat.category_id = p.category_id
		LEFT JOIN sales.order_items oi
			ON p.product_id = oi.product_id
		LEFT JOIN sales.orders o
			ON oi.order_id = o.order_id
		GROUP BY cat.category_id,
				 cat.category_name)

SELECT a.category_name AS category,
	   t.target,
	   a.actual,
	   a.actual - t.target AS variance,
	   ROUND(a.actual / t.target * 100, 2) AS achievement_percentage
FROM target t
JOIN actual a
	ON t.category_id = a.category_id;



/*==============================================================
  4. ACHIEVEMENT RANKING
==============================================================*/

WITH target AS (
		SELECT region,
			   SUM(sales_target) AS target
		FROM sales.sales_targets
		GROUP BY region),

	actual AS (
		SELECT c.region,
			   SUM(o.subtotal) AS actual
		FROM master.customers c
		JOIN sales.orders o
			ON c.customer_id = o.customer_id
	    WHERE o.order_status = 'Delivered'
		GROUP BY c.region),

	region_matrix AS (
		SELECT t.region,
			   t.target,
			   a.actual,
			   (a.actual - t.target) AS variance,
			   ROUND(a.actual / t.target * 100, 2) AS achievement_percentage
		FROM target t
		JOIN actual a
			ON t.region = a.region)

SELECT *,
	   RANK()
	   		OVER(ORDER BY achievement_percentage DESC)
			   AS achievement_rank
FROM region_matrix
ORDER BY achievement_rank;



/*==============================================================
 TARGET VS ACTUAL ANALYSIS COMPLETE
 Output: Monthly, regional, and category target vs actual
         performance, variance, achievement percentage,
         and basic achievement ranking.
 Analysis Note: Basic target vs actual analysis only; detailed
                target analysis is covered in Project 16.
==============================================================*/
