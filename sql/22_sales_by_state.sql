USE ecommerce_analysis;

WITH state_sales AS (
    SELECT
        UPPER(TRIM(c.customer_state)) AS customer_state,

        COUNT(*) AS delivered_orders,

        SUM(t.item_count) AS items_sold,

        SUM(t.merchandise_value)
            AS merchandise_sales_value

    FROM orders_analysis AS o

    INNER JOIN order_item_totals AS t
        ON o.order_id = t.order_id

    INNER JOIN raw_customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'

    GROUP BY UPPER(TRIM(c.customer_state))
)
SELECT
    customer_state,
    delivered_orders,
    items_sold,

    ROUND(
        merchandise_sales_value, 2
    ) AS merchandise_sales_value,

    ROUND(
        merchandise_sales_value
        / NULLIF(delivered_orders, 0),
        2
    ) AS average_order_value,

    ROUND(
        100.0 * merchandise_sales_value
        / NULLIF(
            SUM(merchandise_sales_value) OVER (), 0
        ),
        2
    ) AS sales_share_pct

FROM state_sales
ORDER BY merchandise_sales_value DESC, customer_state;