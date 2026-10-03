# E-Commerce Sales & Revenue Performance Analysis

An end-to-end e-commerce sales analysis project using **PostgreSQL, Excel, and Power BI**. The project analyzes revenue, profitability, growth, product and category performance, regional and sales-channel performance, discounts, and target achievement.

## Project Objective

To analyze e-commerce sales performance across revenue, profitability, growth, products, categories, regions, sales channels, discounts, and target achievement using PostgreSQL, Excel, and Power BI.

## Business Questions

The project addresses key business questions across the following areas:

- **Sales & Revenue:** How much revenue is generated and how many orders and units are sold?
- **Profitability:** How much gross profit is generated and what is the gross margin?
- **Growth:** How is revenue changing monthly, quarterly, and yearly?
- **Product & Category:** Which products and categories contribute most to revenue and profit?
- **Region:** Which regions generate the most revenue and profit?
- **Sales Channel:** How do Website, Mobile App, and Marketplace performance differ?
- **Discount & Target:** How does discounting vary, and how closely does actual revenue track sales targets?

## Data Source

This project uses the PostgreSQL database created through the **E-Commerce Analytics Database ETL Pipeline**.

The ETL project transforms raw e-commerce CSV data into a clean, validated, relational, and analysis-ready PostgreSQL database.

**Source Database Project:**  
[E-Commerce Analytics Database ETL Pipeline](https://github.com/anuragdwi811/e-commerce-analytics-database-etl)

### Data Flow

```text
Raw CSV Data
      ↓
ETL Pipeline
      ↓
Validated PostgreSQL Database
      ↓
E-Commerce Sales & Revenue Analysis
