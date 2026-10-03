/*==============================================================
 Project     : E-Commerce Sales & Revenue Performance Analysis
 File        : 03_product_performance.sql
 Module      : Product Performance Analysis
 Purpose     : Analyze product-level sales, revenue,
               profitability, and contribution
 Sales Rule  : Delivered orders are treated as realized sales
 Output      : Product-level performance and ranking analysis
==============================================================*/



/*==============================================================
  1. PRODUCT PERFORMANCE VIEW
==============================================================*/

CREATE OR REPLACE VIEW analytics.product_performance AS
SELECT p.product_id,
	   p.product_name,
	   cat.category_name AS category,
	   scat.subcategory_name AS subcategory,
	   SUM(oi.quantity) AS units,
	   COUNT(DISTINCT oi.order_id) AS orders,
	   SUM(oi.item_revenue) AS revenue,
	   SUM(oi.item_cost) AS cost,
	   SUM(oi.gross_profit) AS gross_profit,
	   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
			, 2) AS gross_margin
FROM master.products p
JOIN sales.order_items oi
	ON p.product_id = oi.product_id
JOIN sales.orders o
	ON oi.order_id = o.order_id
JOIN master.categories cat
	ON cat.category_id = p.category_id
JOIN master.subcategories scat
	ON scat.subcategory_id = p.subcategory_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id,
		 p.product_name,
		 cat.category_name,
		 scat.subcategory_name
;



/*==============================================================
  2. PRODUCT PERFORMANCE DATASET
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   units,
	   orders,
	   revenue,
	   cost,
	   gross_profit,
	   gross_margin,
	   ROUND(revenue / (SELECT SUM(oi.item_revenue) FROM sales.orders o
	   					JOIN sales.order_items oi ON o.order_id = oi.order_id
	   			  		WHERE o.order_status = 'Delivered') * 100
					 	, 3) AS revenue_contribution
FROM analytics.product_performance;



/*==============================================================
  3. TOP 10 PRODUCTS BY REVENUE
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   revenue,
	   RANK()
	   		OVER(ORDER BY revenue DESC)
	   		AS revenue_rank,
	   units,
	   gross_profit,
	   gross_margin
FROM analytics.product_performance
ORDER BY revenue_rank
LIMIT 10;



/*==============================================================
  4. TOP 10 PRODUCTS BY UNITS SOLD
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   units,
	   DENSE_RANK()
	   		OVER(ORDER BY units DESC)
	   		AS units_rank
FROM analytics.product_performance
ORDER BY units_rank
LIMIT 10;



/*==============================================================
  5. TOP 10 PRODUCTS BY GROSS PROFIT
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   revenue,
	   cost,
	   gross_profit,
	   gross_margin,
	   ROW_NUMBER()
	   		OVER(ORDER BY gross_profit DESC)
	   		AS profit_rank
FROM analytics.product_performance
ORDER BY profit_rank
LIMIT 10;



/*==============================================================
  6. BOTTOM 10 PRODUCTS BY REVENUE
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   revenue,
	   RANK()
	   		OVER(ORDER BY revenue)
	   		AS revenue_rank,
	   units,
	   gross_profit,
	   gross_margin
FROM analytics.product_performance
ORDER BY revenue_rank
LIMIT 10;



/*==============================================================
  7. BOTTOM 10 PRODUCTS BY GROSS PROFIT
==============================================================*/

SELECT product_id,
	   product_name,
	   category,
	   subcategory,
	   revenue,
	   cost,
	   gross_profit,
	   gross_margin,
	   ROW_NUMBER()
	   		OVER(ORDER BY gross_profit)
	   		AS profit_rank
FROM analytics.product_performance
ORDER BY profit_rank
LIMIT 10;



/*==============================================================
  8. HIGH REVENUE & LOW MARGIN PRODUCTS
==============================================================*/
SELECT product_id,
	   product_name,
	   category,
 	   subcategory,
	   revenue,
	   ROUND(revenue / (SELECT SUM(oi.item_revenue) FROM sales.orders o
	   					JOIN sales.order_items oi ON o.order_id = oi.order_id
	   			  		WHERE o.order_status = 'Delivered') * 100
					 	, 3) AS revenue_contribution,
	   gross_profit,
	   gross_margin,
	   DENSE_RANK()
	   		OVER(ORDER BY revenue DESC) AS revenue_rank,
	   DENSE_RANK()
	   		OVER(ORDER BY gross_margin DESC) AS margin_rank
FROM analytics.product_performance
WHERE revenue > (SELECT AVG(revenue) FROM analytics.product_performance)
	AND gross_margin < (SELECT AVG(gross_margin) FROM analytics.product_performance);



/*==============================================================
 PRODUCT PERFORMANCE ANALYSIS COMPLETE
 Output: Product-level sales, profitability, contribution,
         and ranking analysis.
==============================================================*/
