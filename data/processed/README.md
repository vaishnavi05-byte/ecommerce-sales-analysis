# Processed data

## Monthly delivery performance
monthly_delivery_performance.csv contains one row per
purchase month for eligible delivered orders.

Generated using: sql/06_delivery_by_month.sql

- eligible_orders: orders included in delivery analysis.
- late_orders: orders delivered after the estimated date.
- late_delivery_pct: percentage late; 6.77 means 6.77%.
- avg_delivery_days: average elapsed purchase-to-delivery days.

Dataset source:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

## State delivery performance
state_delivery_performance.csv contains one row per
customer state code for eligible delivered orders.

Generated using: sql/10_delivery_by_state.sql

The delivery metrics use the same definitions as the
monthly export. customer_state identifies the customer's
location.

## Sales exports

- overall_sales_performance.csv: one summary row.
- monthly_sales_performance.csv: one row per purchase month.

Generated using:
- sql/15_sales_performance.sql
- sql/16_sales_by_month.sql
Scope: Orders with delivered status.
Merchandise sales value is the sum of item prices.
Freight is reported separately.
## Category and state sales exports

- category_sales_performance.csv:
  Generated using sql/21_category_sales.sql.
  Contains category ranks, item counts, order counts,
  merchandise value, and sales shares.

- state_sales_performance.csv:
  Generated using sql/22_sales_by_state.sql.
  Contains delivered-order counts, item counts,
  merchandise value, AOV, and sales shares by customer state.

Both exports use delivered orders and exclude freight
from merchandise value.

Category order counts may overlap because one order can
contain products from multiple categories.
Average order value excludes freight and is calculated
at the order level.
