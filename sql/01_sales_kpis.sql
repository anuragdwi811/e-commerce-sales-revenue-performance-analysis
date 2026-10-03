/*==============================================================
 Project     : E-Commerce Sales & Revenue Performance Analysis
 File        : 01_sales_kpis.sql
 Module      : Sales KPI Analysis
 Purpose     : Calculate core sales KPIs for delivered orders
 Sales Rule  : Delivered orders are treated as realized sales
 Output      : One-row KPI summary
==============================================================*/

WITH sales_data AS (
	    SELECT
	        o.order_id,
	        o.customer_id,
	        o.subtotal,
	        o.discount_amount,
	        SUM(oi.quantity) AS total_units_sold,
	        SUM(oi.gross_profit) AS gross_profit
	    FROM sales.orders o
	    INNER JOIN sales.order_items oi
	        ON o.order_id = oi.order_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY o.order_id,
	        	 o.customer_id,
	        	 o.subtotal,
	        	 o.discount_amount
)

SELECT
	-- Revenue
    ROUND(SUM(subtotal), 2) AS total_revenue,

    -- Gross Profit
    ROUND(SUM(gross_profit), 2) AS total_gross_profit,

    -- Gross Margin %
    ROUND(SUM(gross_profit) / NULLIF(SUM(subtotal), 0) * 100
        , 2) AS gross_margin_percentage,

    -- Total Orders
    COUNT(order_id) AS total_orders,

    -- Total Units Sold
    SUM(total_units_sold) AS total_units_sold,

    -- Average Order Value
    ROUND(SUM(subtotal) / NULLIF(COUNT(order_id), 0)
        , 2) AS average_order_value,

    -- Total Customers
    COUNT(DISTINCT customer_id) AS total_customers,

    -- Total Discount
    ROUND(SUM(discount_amount), 2) AS total_discount,

    -- Average Discount per Delivered Order
    ROUND(AVG(discount_amount), 2) AS average_discount,

    -- Discount Rate %
    ROUND(SUM(discount_amount) / NULLIF(SUM(subtotal), 0) * 100
        , 2) AS discount_rate_percentage

FROM sales_data;

/*==============================================================
 KPI SUMMARY COMPLETE
 Output: One-row summary containing the 10 core sales KPIs.
==============================================================*/
