/*==============================================================
Project     : E-Commerce Sales & Revenue Performance Analysis
File        : 06_discount_impact.sql
Module      : Discount Impact Analysis
Purpose     : Analyze sales performance across discount bands
              and compare discounted vs non-discounted orders
Sales Rule  : Delivered orders are treated as realized sales
Output      : Discount-band and discount-status performance
              analysis
Analysis Note: Descriptive analysis only; results do not
              establish that discounts caused performance changes
==============================================================*/



/*==============================================================
  1. DISCOUNT BAND PERFORMANCE
==============================================================*/

WITH delivered_orders AS (
		SELECT o.order_id,
			   SUM(oi.quantity) AS units,
			   o.subtotal,
			   o.discount_amount,
			   ROUND((o.discount_amount / o.subtotal)
			   		* 100, 2) AS discount_percentage,
			   SUM(oi.gross_profit) AS gross_profit
		FROM sales.orders o
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY o.order_id),

	discount_band_performance AS (
		SELECT order_id,
				CASE
					WHEN discount_percentage <= 0 THEN '0%'
					WHEN discount_percentage <= 5 THEN '1-5%'
					WHEN discount_percentage <= 10 THEN '5-10%'
					WHEN discount_percentage <= 20 THEN '10-20%'
					ELSE '>20%'
				END AS discount_band,
				units,
				subtotal,
				discount_amount,
				gross_profit
		FROM delivered_orders)
		
SELECT discount_band,
	   COUNT(order_id) AS orders,
	   SUM(units) AS units,
	   SUM(subtotal) AS revenue,
	   SUM(discount_amount) AS discount_amount,
	   SUM(gross_profit) AS gross_profit,
	   ROUND(SUM(gross_profit) / SUM(subtotal)
	   		* 100, 2) AS gross_margin,
	   ROUND(SUM(subtotal) / COUNT(order_id) 
	   		, 2) AS aov
FROM discount_band_performance
GROUP BY discount_band;

		

/*==============================================================
  2. DISCOUNT BAND RANKING
==============================================================*/

WITH delivered_orders AS (
		SELECT o.order_id,
			   SUM(oi.quantity) AS units,
			   o.subtotal,
			   o.discount_amount,
			   ROUND((o.discount_amount / o.subtotal)
			   		* 100, 2) AS discount_percentage,
			   SUM(oi.gross_profit) AS gross_profit
		FROM sales.orders o
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY o.order_id),

	discount_band_ranking AS (
		SELECT order_id,
				CASE
					WHEN discount_percentage <= 0 THEN '0%'
					WHEN discount_percentage <= 5 THEN '1-5%'
					WHEN discount_percentage <= 10 THEN '5-10%'
					WHEN discount_percentage <= 20 THEN '10-20%'
					ELSE '>20%'
				END AS discount_band,
				units,
				subtotal,
				discount_amount,
				gross_profit
		FROM delivered_orders)
		
SELECT discount_band,
	   COUNT(order_id) AS orders,
	   SUM(units) AS units,
	   SUM(subtotal) AS revenue,
	   RANK()
	   		OVER(ORDER BY SUM(subtotal) DESC)
			   AS revenue_rank,
	   SUM(discount_amount) AS discount_amount,
	   SUM(gross_profit) AS gross_profit,
	   ROUND(SUM(gross_profit) / SUM(subtotal)
	   		* 100, 2) AS gross_margin,
	   ROUND(SUM(subtotal) / COUNT(order_id) 
	   		, 2) AS aov
FROM discount_band_ranking
GROUP BY discount_band
ORDER BY revenue_rank;



/*==============================================================
  3. DISCOUNTED vs NON-DISCOUNTED PERFORMANCE
==============================================================*/

WITH delivered_orders AS (
		SELECT o.order_id,
			   SUM(oi.quantity) AS units,
			   o.subtotal,
			   o.discount_amount,
			   ROUND((o.discount_amount / o.subtotal)
			   		* 100, 2) AS discount_percentage,
			   SUM(oi.gross_profit) AS gross_profit
		FROM sales.orders o
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY o.order_id),

	discount_band_performance AS (
		SELECT order_id,
				CASE
					WHEN discount_percentage <= 0 THEN 'Non-Discounted'
					ELSE 'Discounted'
				END AS discount_status,
				units,
				subtotal,
				discount_amount,
				gross_profit
		FROM delivered_orders)
		
SELECT discount_status,
	   COUNT(order_id) AS orders,
	   SUM(units) AS units,
	   SUM(subtotal) AS revenue,
	   SUM(discount_amount) AS discount_amount,
	   SUM(gross_profit) AS gross_profit,
	   ROUND(SUM(gross_profit) / SUM(subtotal)
	   		* 100, 2) AS gross_margin,
	   ROUND(SUM(subtotal) / COUNT(order_id) 
	   		, 2) AS aov
FROM discount_band_performance
GROUP BY discount_status;



/*==============================================================
  4. DISCOUNT STATUS COMPARISON
==============================================================*/

WITH delivered_orders AS (
		SELECT o.order_id,
			   o.discount_amount,
			   o.subtotal,
			   SUM(oi.gross_profit) AS gross_profit
		FROM sales.orders o
		JOIN sales.order_items oi
			ON o.order_id = oi.order_id
		WHERE o.order_status = 'Delivered'
		GROUP BY o.order_id),

	discount_status_performance AS (
		SELECT *,
			   CASE
					WHEN discount_amount = 0 THEN 'Non-Discounted'
					ELSE 'Discounted'
			   END AS discount_status
		FROM delivered_orders)

SELECT discount_status,
       COUNT(order_id) AS orders,
       ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER()
	   		, 2) AS order_share,
       SUM(subtotal) AS revenue,
       ROUND(SUM(subtotal) * 100.0 / SUM(SUM(subtotal)) OVER()
	   		, 2) AS revenue_contribution,
       ROUND(AVG(discount_amount), 2) AS average_discount,
       SUM(gross_profit) AS gross_profit,
       ROUND(SUM(gross_profit) / SUM(subtotal) * 100 
	   		, 2) AS gross_margin,
       ROUND(SUM(subtotal) / COUNT(order_id), 2) AS aov
FROM discount_status_performance
GROUP BY discount_status;



/*==============================================================
  5. DISCOUNT SUMMARY
==============================================================*/

SELECT COUNT(*) AS total_orders,
	   COUNT(*) FILTER (WHERE discount_amount <> 0)
	   		AS discounted_orders,
	   COUNT(*) FILTER (WHERE discount_amount = 0)
	   		AS non_discounted_orders,
	   ROUND((COUNT(*) FILTER (WHERE discount_amount <> 0))::NUMERIC /
	   		COUNT(*) * 100, 2) AS discounted_order_percentage,
	   SUM(discount_amount) AS total_discount,
	   ROUND(AVG(discount_amount), 2) AS average_discount,
	   ROUND(SUM(discount_amount) / SUM(subtotal)
	   		* 100, 2) AS discount_rate_percentage   
FROM sales.orders
WHERE order_status = 'Delivered';
			   


/*==============================================================
 DISCOUNT IMPACT ANALYSIS COMPLETE
 Output: Discount-band performance, discount status comparison,
         and overall discount summary.
 Analysis Note: Results are descriptive and do not establish
                that discounts caused performance changes.
==============================================================*/
