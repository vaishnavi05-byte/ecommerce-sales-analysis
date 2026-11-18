# E-commerce Sales and Delivery Analysis

## Project status
In progress — orders imported and initial validation completed.

## Overview
This personal portfolio project explores historical
e-commerce orders to understand sales trends, product
category performance, customer locations, and delivery delays.

## Business questions
1. How do sales and order counts change month by month?
2. Which product categories generate the most sales?
3. Which customer states contribute the most sales?
4. What percentage of delivered orders arrive late?

## Tools
- MySQL Workbench: importing, checking, and analysing data
- Microsoft Excel: dashboard and visualisation
- GitHub: project documentation and file history

## Dataset
Brazilian E-Commerce Public Dataset by Olist.
The dataset contains historical orders from 2016–2018.

Source:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## Planned deliverables
- Data quality checks
- SQL analysis scripts
- Excel dashboard
- Findings, limitations, and recommendations

## Results
Results will be added after the analysis is completed
and checked.

## Initial orders data checks
- Imported rows: 99,441
- Unique order IDs: 99,441
- Missing order IDs: 0
- Missing customer IDs: 0

## Orders data quality checks

| Check | Result |
|---|---:|
| Imported rows | 99,441 |
| Unique order IDs | 99,441 |
| Missing order IDs | 0 |
| Missing customer IDs | 0 |
| Missing actual delivery dates | 2,965 |
| Missing purchase dates | 0 |
| Missing estimated delivery dates | 0 |
| Unexpected formats across the three checked date fields | 0 |
| Actual deliveries before purchase | 0 |
| Estimated delivery dates before purchase date | 0 |

### Flagged inconsistencies
- 8 delivered orders have no actual delivery date.
- 6 canceled orders have an actual delivery date.
- These records are preserved in the raw table.

### Planned analysis rule
Delivery metrics will use delivered orders with valid
required dates. Excluded records will be reported.
