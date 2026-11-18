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
### Delivery performance

| Metric | Result |
|---|---:|
| Eligible delivered orders | 96,470 |
| Late orders | 6,534 |
| On-time orders | 89,936 |
| Late-delivery rate | 6.77% |
| Average purchase-to-delivery time | 12.56 days |

Scope: Delivered orders with the required dates and valid
date sequence. Eight delivered orders with missing actual
delivery dates were excluded.

Late means the actual delivery calendar date was after
the estimated delivery calendar date.

Average delivery time measures elapsed time from purchase
to customer delivery, including fractional days.

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
- 6 cancelled orders have an actual delivery date.
- These records are preserved in the raw table.

### Planned analysis rule
Delivery metrics will use delivered orders with valid
required dates. Excluded records will be reported.
## Monthly delivery findings

- March 2018 recorded 1,328 late orders among 7,003
  eligible orders: a late-delivery rate of 18.96%.
- This was 12.19 percentage points above the overall
  late-delivery rate of 6.77%.
- September 2016 recorded 100% late delivery, but had
  only one eligible order, limiting interpretation.
- Months are based on purchase date.
- Further analysis is needed to investigate the
  locations and product categories associated with delays.

  ## Customer and join validation

- Customer records: 99,441.
- Distinct shoppers: 96,096.
- No missing customer IDs, shopper IDs, or states.
- Joining orders to customers preserved 99,441 orders.
- No orders lacked a matching customer record.

## State delivery findings

| State | Eligible orders | Late orders | Late rate |
|---|---:|---:|---:|
| SP | 40,494 | 1,820 | 4.49% |
| RJ | 12,350 | 1,495 | 12.11% |
| MA | 717 | 125 | 17.43% |
| AL | 397 | 85 | 21.41% |

- RJ combined substantial order volume with an above-average
  late-delivery rate.
- SP had the largest number of late orders, despite a
  below-average late rate.
- SP and RJ together accounted for 50.73% of late orders.
- Further analysis is needed to explain these differences.

[View state delivery results](data/processed/state_delivery_performance.csv)

## Sales analysis

### Data validation
- Imported 112,650 items across 98,666 order IDs.
- No missing required item identifiers.
- No missing or unexpected price or freight formats.
- Every item matched an order.
- All 96,478 delivered orders had item records.

### Delivered-order results

| Metric | Result |
|---|---:|
| Delivered orders | 96,478 |
| Items sold | 110,197 |
| Merchandise sales value | 13,221,498.11 |
| Freight value | 2,198,275.64 |
| Average order value, excluding freight | 137.04 |

### Monthly findings
- November 2017 merchandise value was 987,765.37,
  up 52.37% from October.
- Delivered order count increased 62.77%, while AOV
  declined from 144.76 to 135.51.
- May 2018 generated merchandise value of 977,544.69
  from 6,749 delivered orders, with AOV of 144.84.

Sales calculations include all delivered orders with
item records. Delivery-time calculations additionally
require valid delivery dates.
