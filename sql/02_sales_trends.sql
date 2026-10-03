/*==============================================================
 Project     : E-Commerce Sales & Revenue Performance Analysis
 File        : 02_sales_trends.sql
 Module      : Sales Trend & Growth Analysis
 Purpose     : Analyze sales performance across monthly,
               quarterly, and yearly time periods
 Sales Rule  : Delivered orders are treated as realized sales
 Output      : Time-based sales performance and growth metrics
==============================================================*/



/*==============================================================
  1. MONTHLY SALES TREND
==============================================================*/

WITH order_level_sales AS (
	    SELECT o.order_id,
	           o.order_date,
	           o.subtotal,
	           SUM(oi.quantity) AS units,
	           SUM(oi.gross_profit) AS gross_profit
	    FROM sales.orders o
	    INNER JOIN sales.order_items oi
	        ON o.order_id = oi.order_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY o.order_id,
	             o.order_date,
	        	 o.subtotal),

monthly_sales_analysis AS (
	    SELECT EXTRACT(YEAR FROM order_date) AS year,
	           EXTRACT(QUARTER FROM order_date) AS quarter,
	           EXTRACT(MONTH FROM order_date) AS month,
	           ROUND(SUM(subtotal), 2) AS revenue,
	           COUNT(order_id) AS orders,
	           SUM(units) AS units,
	           ROUND(SUM(gross_profit), 2) AS gross_profit,
			   
	           ROUND(SUM(gross_profit) / SUM(subtotal) * 100
			   		, 2) AS gross_margin,
					   
	           ROUND(SUM(subtotal) / COUNT(order_id), 2) AS aov
	    FROM order_level_sales
	    GROUP BY year,
	             quarter,
	        	 month)

SELECT year,
       quarter,
       month,
       revenue,
       orders,
       units,
       gross_profit,
       gross_margin,
       aov,
       LAG(revenue)
       		OVER(ORDER BY year, month) AS previous_month_revenue,
			   
       ROUND((revenue - LAG(revenue) OVER(ORDER BY year, month))
        	/ LAG(revenue) OVER(ORDER BY year, month) * 100
        		, 2) AS mom_growth_percentage,
				
       LAG(revenue, 12)
        	OVER(ORDER BY year, month) AS previous_year_revenue,

       ROUND((revenue - LAG(revenue, 12) OVER(ORDER BY year, month))
        	/ LAG(revenue, 12) OVER(ORDER BY year, month) * 100
        		, 2) AS yoy_growth_percentage,

       SUM(revenue)
        	OVER(ORDER BY year, month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       			 ) AS running_revenue

FROM monthly_sales_analysis;



/*==============================================================
  2. QUARTERLY SALES PERFORMANCE
==============================================================*/

WITH order_level_sales AS (
	    SELECT o.order_id,
	           o.order_date,
	           o.subtotal,
	           SUM(oi.quantity) AS units,
	           SUM(oi.gross_profit) AS gross_profit
	    FROM sales.orders o
	    INNER JOIN sales.order_items oi
	        ON o.order_id = oi.order_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY o.order_id,
	        	 o.order_date,
	        	 o.subtotal),

quarterly_sales AS (
	    SELECT EXTRACT(YEAR FROM order_date) AS year,
	           EXTRACT(QUARTER FROM order_date) AS quarter,
	           ROUND(SUM(subtotal), 2) AS revenue,
	           COUNT(order_id) AS orders,
	           SUM(units) AS units,
	           ROUND(SUM(gross_profit), 2) AS gross_profit,
	           ROUND(SUM(gross_profit) / SUM(subtotal) * 100
	           		, 2) AS gross_margin,
	           ROUND(SUM(subtotal) / COUNT(order_id), 2) AS aov
	    FROM order_level_sales
	    GROUP BY year,
	        	 quarter)

SELECT year,
       quarter,
       revenue,
       orders,
       units,
       gross_profit,
       gross_margin,
       aov,

      LAG(revenue)
      	OVER(ORDER BY year, quarter) AS previous_quarter_revenue,

      ROUND((revenue - LAG(revenue) OVER(ORDER BY year, quarter))
         / LAG(revenue) OVER(ORDER BY year, quarter) * 100
        	, 2) AS quarter_over_quarter_growth_percentage

FROM quarterly_sales;	   

 

/*==============================================================
  3. YEARLY SALES PERFORMANCE
==============================================================*/

WITH order_level_sales AS (
	    SELECT o.order_id,
	           o.order_date,
	           o.subtotal,
	           SUM(oi.quantity) AS units,
	           SUM(oi.gross_profit) AS gross_profit
	    FROM sales.orders o
	    INNER JOIN sales.order_items oi
	        ON o.order_id = oi.order_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY o.order_id,
	        	 o.order_date,
	        	 o.subtotal),

yearly_sales AS (
	    SELECT EXTRACT(YEAR FROM order_date) AS year,
	           ROUND(SUM(subtotal), 2) AS revenue,
	           COUNT(order_id) AS orders,
	           SUM(units) AS units,
	           ROUND(SUM(gross_profit), 2) AS gross_profit,
	           ROUND(SUM(gross_profit) / SUM(subtotal) * 100
	           		, 2) AS gross_margin,
	           ROUND(SUM(subtotal) / COUNT(order_id), 2) AS aov
	    FROM order_level_sales
	    GROUP BY year)

SELECT year,
       revenue,
       orders,
       units,
       gross_profit,
       gross_margin,
       aov,

       LAG(revenue)
        OVER(ORDER BY year) AS previous_year_revenue,

       ROUND((revenue - LAG(revenue) OVER(ORDER BY year))
        / LAG(revenue) OVER(ORDER BY year) * 100
        	, 2) AS yoy_growth_percentage

FROM yearly_sales;		   

 

/*==============================================================
  4. MONTHLY GROWTH & RANKING ANALYSIS
==============================================================*/

WITH order_level_sales AS (
	    SELECT o.order_id,
	           o.order_date,
	           o.subtotal,
	           SUM(oi.gross_profit) AS gross_profit
	    FROM sales.orders o
	    INNER JOIN sales.order_items oi
	        ON o.order_id = oi.order_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY o.order_id,
	        	 o.order_date,
	        	 o.subtotal),

monthly_growth_summary AS (
	    SELECT EXTRACT(YEAR FROM order_date) AS year,
	           EXTRACT(MONTH FROM order_date) AS month,
	           ROUND(SUM(subtotal), 2) AS revenue,
	           ROUND(SUM(gross_profit) / SUM(subtotal) * 100
	            	, 2) AS gross_margin
	    FROM order_level_sales
	    GROUP BY year,
	        	 month),

monthly_growth_analysis AS (
	    SELECT year,
	           month,
	           revenue,
	           ROUND((revenue - LAG(revenue) OVER(ORDER BY year, month))
	            	/ LAG(revenue) OVER(ORDER BY year, month) * 100
	            	, 2) AS mom_growth_percentage,
	           gross_margin
	    FROM monthly_growth_summary)

SELECT year,
       month,
       revenue,
       mom_growth_percentage,
       gross_margin,

       DENSE_RANK()
        OVER(ORDER BY revenue DESC) AS revenue_rank,

       CASE
        	WHEN mom_growth_percentage IS NOT NULL
        	THEN DENSE_RANK()
            		OVER(ORDER BY mom_growth_percentage DESC NULLS LAST)
       END AS growth_rank

FROM monthly_growth_analysis
ORDER BY year,
         month;



/*==============================================================
 SALES TREND & GROWTH ANALYSIS COMPLETE
 Output: Monthly, quarterly, and yearly sales performance
         with MoM, QoQ, YoY, and running revenue metrics.
==============================================================*/
