# E-Commerce Sales & Revenue Performance Analysis

An end-to-end e-commerce sales analytics project built using **PostgreSQL, SQL, Microsoft Excel, and Power BI**.

The project analyzes sales performance across **revenue, profitability, growth, products, categories, regions, sales channels, discounts, and target achievement**. PostgreSQL is used as the primary data source and analytical database, Excel is used for independent validation and KPI reconciliation, and Power BI is used to build the final interactive dashboard.

---

## Project Overview

This project focuses on analyzing the sales and revenue performance of an e-commerce business using an existing, structured PostgreSQL database.

The analysis combines SQL-based business analysis, Excel validation, and Power BI visualization to provide both detailed analytical results and management-level insights.

The project is designed around a simple principle:

> **Use SQL for analysis, Excel for validation, and Power BI for business reporting and visualization.**

The final output includes:

- 7 SQL analysis modules
- 1 Excel validation workbook
- 1 Power BI report with 4 dashboard pages
- KPI reconciliation between SQL and Excel
- Interactive Power BI data model
- Business insights and recommendations
- Project documentation

---

## Project Objective

The objective of this project is to analyze e-commerce sales performance across:

- Revenue
- Gross profit
- Gross margin
- Orders
- Units sold
- Average Order Value (AOV)
- Monthly, quarterly, and yearly growth
- Product performance
- Category and subcategory performance
- Regional performance
- Sales channel performance
- Discount performance
- Target vs actual performance

The analysis is intended to support business understanding and management decision-making through structured sales reporting and interactive dashboards.

---

## Business Need

A structured sales analysis is required to answer important business questions such as:

### Revenue

- How much revenue is the business generating?
- How is revenue distributed across products, categories, regions, and channels?

### Profitability

- How much gross profit is being generated?
- What is the overall gross margin?
- Which products and categories contribute more to profit?

### Growth

- How is revenue changing over time?
- What is the monthly, quarterly, and yearly performance?
- What are the MoM and YoY growth rates?

### Product & Category

- Which products generate the most revenue?
- Which products generate the most gross profit?
- Which categories contribute the largest share of revenue?
- Are high-revenue products also highly profitable?

### Region

- Which regions generate the most revenue?
- Which regions contribute the most profit?
- How does AOV vary across regions?

### Sales Channel

- How do Website, Mobile App, and Marketplace compare?
- Which channel contributes the most revenue and profit?

### Discount

- How much discount is being provided?
- How does performance vary across discount bands?
- How do discounted and non-discounted orders compare?

### Target

- Is actual revenue meeting the business target?
- Which regions and categories are above or below target?

---

# Data Source

The project uses an existing PostgreSQL database created through the following ETL project:

**[E-Commerce Analytics Database ETL Pipeline](https://github.com/anuragdwi811/e-commerce-analytics-database-etl)**

The ETL project transforms raw e-commerce CSV data into a clean, validated, relational, and analysis-ready PostgreSQL database.

### Upstream Data Pipeline

```text
Raw CSV Data
      ↓
Staging Tables
      ↓
Data Profiling
      ↓
Data Validation
      ↓
Cleaning & Transformation
      ↓
Final Relational Tables
      ↓
Validated PostgreSQL Database
      ↓
This Sales Analysis Project
