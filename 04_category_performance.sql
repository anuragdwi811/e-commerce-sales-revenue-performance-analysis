/*==============================================================
Project     : E-Commerce Sales & Revenue Performance Analysis
File        : 04_category_performance.sql
Module      : Category Performance Analysis
Purpose     : Analyze category and subcategory sales,
              revenue, profitability, and contribution
Sales Rule  : Delivered orders are treated as realized sales
Output      : Category and subcategory performance analysis
==============================================================*/



/*==============================================================
  1. CATEGORY PERFORMANCE VIEW
==============================================================*/

CREATE OR REPLACE VIEW analytics.category_performance AS
SELECT cat.category_id,
	   cat.category_name AS category,
	   SUM(oi.quantity) AS units,
	   COUNT(DISTINCT oi.order_id) AS orders,
	   SUM(oi.item_revenue) AS revenue,
	   SUM(oi.item_cost) AS cost,
	   SUM(oi.gross_profit) AS gross_profit,
	   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue)
	   		* 100, 2) AS gross_margin
FROM master.categories cat
JOIN master.products p
	ON cat.category_id = p.category_id
JOIN sales.order_items oi
	ON p.product_id = oi.product_id
JOIN sales.orders o
	ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY cat.category_id,
		 cat.category_name;



/*==============================================================
  2. CATEGORY PERFORMANCE DATASET
==============================================================*/

SELECT category_id,
	   category,
	   units,
	   orders,
	   revenue,
	   cost,
	   gross_profit,
	   gross_margin,
	   ROUND(
	   (revenue / SUM(revenue) OVER () * 100)
	   		, 2)AS revenue_contribution
FROM analytics.category_performance;



/*==============================================================
  3. CATEGORY RANKING
==============================================================*/

SELECT category,
	   revenue,
	   RANK()
	   		OVER(ORDER BY revenue DESC)
			   AS revenue_rank,
	   units,
	   DENSE_RANK()
	   		OVER(ORDER BY units DESC)
			   AS units_rank,
	   gross_profit,
	   ROW_NUMBER()
	   		OVER(ORDER BY gross_profit DESC)
			   AS profit_rank,
	   gross_margin
FROM analytics.category_performance;



/*==============================================================
  4. TOP & BOTTOM CATEGORIES
==============================================================*/

-- Top Category
WITH top_category AS (
		SELECT category,
			   revenue,
			   ROUND(
			   (revenue / SUM(revenue) OVER () * 100)
			   		, 2)AS revenue_contribution,
			   units,
			   orders,
			   gross_profit,
			   gross_margin,
			   RANK()
			   		OVER(ORDER BY revenue DESC)
					   AS revenue_rank
		FROM analytics.category_performance)
SELECT * FROM top_category
WHERE revenue_rank = 1;



-- Bottom Category
WITH bottom_category AS (
		SELECT category,
			   revenue,
			   ROUND(
			   (revenue / SUM(revenue) OVER () * 100)
			   		, 2)AS revenue_contribution,
			   units,
			   orders,
			   gross_profit,
			   gross_margin,
			   RANK()
			   		OVER(ORDER BY revenue)
					   AS revenue_rank
		FROM analytics.category_performance)
SELECT * FROM bottom_category
WHERE revenue_rank = 1;



/*==============================================================
  5. CATEGORY REVENUE CONTRIBUTION
==============================================================*/

SELECT category,
	   revenue,
	   ROUND(
	   (revenue / SUM(revenue) OVER () * 100)
			, 2)AS revenue_contribution
FROM analytics.category_performance
ORDER BY revenue_contribution DESC;



/*==============================================================
  6. SUBCATEGORY PERFORMANCE
==============================================================*/

WITH subcategory_performance AS (
		SELECT scat.subcategory_id,
			   scat.subcategory_name AS subcategory,
			   cat.category_name AS category,
			   SUM(oi.quantity) AS units,
			   COUNT(DISTINCT oi.order_id) AS orders,
			   SUM(oi.item_revenue) AS revenue,
			   SUM(oi.gross_profit) AS gross_profit,
			   ROUND((SUM(oi.gross_profit) / SUM(oi.item_revenue))
			   		* 100, 2) AS gross_margin
		FROM master.subcategories scat
		JOIN master.categories cat
			ON cat.category_id = scat.category_id
		JOIN master.products p
			ON scat.subcategory_id = p.subcategory_id
		JOIN sales.order_items oi
			ON p.product_id = oi.product_id
		JOIN sales.orders o
			ON oi.order_id = o.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY scat.subcategory_id,
				 scat.subcategory_name,
				 cat.category_name)
SELECT subcategory_id,
	   subcategory,
	   category,
   	   units,
	   orders,
	   revenue,
	   gross_profit,
	   gross_margin,
	   ROUND((revenue / SUM(revenue) OVER() *100)
	   		, 2) AS revenue_contribution,
	   RANK()
	   		OVER(ORDER BY revenue DESC)
			   AS revenue_rank
FROM subcategory_performance
ORDER BY revenue_rank;
	 
	 

/*==============================================================
 CATEGORY PERFORMANCE ANALYSIS COMPLETE
 Output: Category and subcategory sales, profitability,
         contribution, and ranking analysis.
==============================================================*/