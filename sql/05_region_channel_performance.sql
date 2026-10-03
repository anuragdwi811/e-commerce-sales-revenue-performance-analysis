/*==============================================================
Project     : E-Commerce Sales & Revenue Performance Analysis
File        : 05_region_channel_performance.sql
Module      : Region & Sales Channel Performance Analysis
Purpose     : Analyze regional and sales channel performance,
              profitability, contribution, and growth
Sales Rule  : Delivered orders are treated as realized sales
Output      : Region, channel, and region-channel performance
==============================================================*/



/*==============================================================
  1. REGION PERFORMANCE VIEW
==============================================================*/

CREATE OR REPLACE VIEW analytics.region_performance AS
SELECT c.region,
	   SUM(oi.item_revenue) AS revenue,
	   COUNT(DISTINCT o.order_id) AS orders,
	   SUM(oi.quantity) AS units,
	   SUM(oi.item_cost) AS cost,
	   SUM(oi.gross_profit) AS gross_profit,
	   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
	   		, 2) AS gross_margin,
	   ROUND(SUM(oi.item_revenue) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM master.customers c
JOIN sales.orders o
	ON c.customer_id = o.customer_id
JOIN sales.order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.region;



/*==============================================================
  2. REGION PERFORMANCE DATASET
==============================================================*/

SELECT region,
	   revenue,
	   orders,
	   units,
	   cost,
	   gross_profit,
	   gross_margin,
	   aov,
	   ROUND(revenue / SUM(revenue) OVER() * 100
	   		, 2) AS revenue_contribution
FROM analytics.region_performance;



/*==============================================================
  3. REGION RANKING
==============================================================*/

SELECT region,
	   revenue,
	   RANK()
	   		OVER(ORDER BY revenue DESC)
			   AS revenue_rank,
	   units,
	   orders,
	   gross_profit,
	   gross_margin,
	   aov
FROM analytics.region_performance
ORDER BY revenue_rank,
		 revenue DESC;



/*==============================================================
  4. REGION GROWTH ANALYSIS
==============================================================*/

WITH region_growth_analysis AS (
		SELECT c.region,
			   EXTRACT(YEAR FROM o.order_date) AS year,
			   EXTRACT(MONTH FROM o.order_date) AS month,
			   SUM(oi.item_revenue) AS revenue,
			   COUNT(DISTINCT o.order_id) AS orders,
			   SUM(oi.quantity) AS units,
			   SUM(oi.gross_profit) AS gross_profit,
			   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
			   		, 2) AS gross_margin,
			   ROUND(SUM(oi.item_revenue) / COUNT(DISTINCT o.order_id), 2) AS aov
		FROM master.customers c
		JOIN sales.orders o
			ON c.customer_id = o.customer_id
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY c.region,
				 year,
				 month)

SELECT region,
	   year,
	   month,
	   revenue,
	   orders,
	   units,
	   gross_profit,
	   gross_margin,
	   aov,
	   LAG(revenue)
	   		OVER(PARTITION BY region
			     ORDER BY year, month)
			   AS previous_month_revenue,
	   ROUND(
	   (revenue - LAG(revenue) OVER(PARTITION BY region
	   				ORDER BY year, month))
	   	/ LAG(revenue) OVER(PARTITION BY region ORDER BY year, month) * 100
		   		, 2) AS mom_growth_percentage
FROM region_growth_analysis
ORDER BY region,
		 year,
		 month;


		 
/*==============================================================
  5. CHANNEL PERFORMANCE VIEW
==============================================================*/

CREATE OR REPLACE VIEW analytics.channel_performance AS
SELECT o.sales_channel,
	   SUM(oi.quantity) AS units,
	   COUNT(DISTINCT o.order_id) AS orders,
	   SUM(oi.item_revenue) AS revenue,
	   SUM(oi.item_cost) AS cost,
	   SUM(oi.gross_profit) AS gross_profit,
	   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
	   		, 2) AS gross_margin,
	   ROUND(SUM(oi.item_revenue) / COUNT(DISTINCT o.order_id)
	   		, 2) AS aov
FROM sales.orders o
JOIN sales.order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.sales_channel;



/*==============================================================
  6. CHANNEL PERFORMANCE DATASET
==============================================================*/

SELECT sales_channel,
	   units,
	   orders,
	   revenue,
	   cost,
	   gross_profit,
	   gross_margin,
	   aov,
	   ROUND(revenue / SUM(revenue) OVER() * 100
	   		, 2) AS revenue_contribution
FROM analytics.channel_performance;



/*==============================================================
  7. CHANNEL RANKING
==============================================================*/

SELECT sales_channel,
	   revenue,
	   RANK()
	   		OVER(ORDER BY revenue DESC)
			   AS revenue_rank,
	   units,
	   orders,
	   gross_profit,
	   gross_margin,
	   aov
FROM analytics.channel_performance
ORDER BY revenue_rank,
		 revenue DESC;



/*==============================================================
  8. CHANNEL GROWTH ANALYSIS
==============================================================*/

WITH channel_growth_analysis AS (
		SELECT o.sales_channel,
			   EXTRACT(YEAR FROM o.order_date) AS year,
			   EXTRACT(MONTH FROM o.order_date) AS month,
			   SUM(oi.item_revenue) AS revenue,
			   COUNT(DISTINCT o.order_id) AS orders,
			   SUM(oi.quantity) AS units,
			   SUM(oi.gross_profit) AS gross_profit,
			   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
			   		, 2) AS gross_margin,
			   ROUND(SUM(oi.item_revenue) / COUNT(DISTINCT o.order_id), 2) AS aov			   
		FROM sales.orders o
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY o.sales_channel,
				 year,
				 month)

SELECT sales_channel,
	   year,
	   month,
	   revenue,
	   orders,
	   units,
	   gross_profit,
	   gross_margin,
	   aov,
	   LAG(revenue)
	   		OVER(PARTITION BY sales_channel
			     ORDER BY year, month)
			   AS previous_month_revenue,
	   ROUND(
	   (revenue - LAG(revenue) OVER(PARTITION BY sales_channel
	   								ORDER BY year, month))
	   	/ LAG(revenue) OVER(PARTITION BY sales_channel ORDER BY year, month)
		   		* 100, 2) AS mom_growth_percentage	   
FROM channel_growth_analysis
ORDER BY sales_channel,
		 year,
		 month;



/*==============================================================
  9. REGION vs CHANNEL PERFORMANCE
==============================================================*/

SELECT c.region,
	   o.sales_channel,
	   SUM(oi.item_revenue) AS revenue,
	   COUNT(DISTINCT o.order_id) AS orders,
	   SUM(oi.quantity) AS units,
	   SUM(oi.gross_profit) AS gross_profit,
	   ROUND(SUM(oi.gross_profit) / SUM(oi.item_revenue) * 100
			, 2) AS gross_margin,
	   ROUND(SUM(oi.item_revenue) / COUNT(DISTINCT o.order_id), 2) AS aov	   
FROM master.customers c
JOIN sales.orders o
	ON c.customer_id = o.customer_id
JOIN sales.order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.region,
		 o.sales_channel;



/*==============================================================
 REGION & CHANNEL PERFORMANCE ANALYSIS COMPLETE
 Output: Regional and sales channel performance, contribution,
         growth, and cross-dimensional analysis.
==============================================================*/
