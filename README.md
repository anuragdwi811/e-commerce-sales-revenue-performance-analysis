# E-Commerce Sales & Revenue Performance Analysis

An end-to-end e-commerce sales analysis project using PostgreSQL, Excel and Power BI. The project focuses on revenue, profitability, growth, product and category performance, regional and channel performance, discounts, and target achievement.

## Project Objective

To analyze e-commerce sales performance across revenue, profitability, growth, products, categories, regions, sales channels, discounts, and target achievement using PostgreSQL, Excel and Power BI.

## Business Questions

- How is overall revenue and profitability performing?
- How has sales performance changed over time?
- Which products and categories contribute most to revenue and profit?
- Which regions and sales channels generate the most revenue?
- How does product revenue compare with gross margin?
- How does discounting vary across orders?
- How closely is actual revenue tracking against sales targets?

## Tools Used

- PostgreSQL
- SQL
- Microsoft Excel
- Power Query
- Power Pivot
- DAX
- Power BI

## Data Source

This project uses the PostgreSQL database created through the following ETL project:

[E-Commerce Analytics Database ETL Pipeline](https://github.com/anuragdwi811/e-commerce-analytics-database-etl)

The ETL project transforms raw e-commerce CSV data into a clean, validated, relational and analysis-ready PostgreSQL database used as the data source for this analysis.

## Project Scope

The analysis covers:

- Revenue and sales performance
- Gross profit and gross margin
- Orders and units sold
- Average Order Value (AOV)
- Monthly, quarterly and yearly growth
- Product performance
- Category and subcategory performance
- Regional performance
- Sales channel performance
- Discount analysis
- Target vs actual performance

For primary sales analysis, delivered orders are treated as realized sales.

## Project Workflow

```text
PostgreSQL Database
        ↓
SQL Analysis
        ↓
Excel Validation
        ↓
Power BI Data Model & DAX
        ↓
Power BI Dashboard
        ↓
Business Insights & Recommendations
