USE ecommerce_analysis;

CREATE OR REPLACE VIEW dashboard_orders AS
WITH base AS (
    SELECT
        o.order_id,
        o.purchased_at,
        o.delivered_at,
        o.estimated_at,
        UPPER(TRIM(c.customer_state)) AS customer_state,
        t.item_count,
        t.merchandise_value,

        CASE
            WHEN o.purchased_at IS NOT NULL
             AND o.delivered_at IS NOT NULL
             AND o.estimated_at IS NOT NULL
             AND o.delivered_at >= o.purchased_at
             AND DATE(o.estimated_at) >= DATE(o.purchased_at)
            THEN 1 ELSE 0
        END AS delivery_eligible

    FROM orders_analysis AS o

    INNER JOIN order_item_totals AS t
        ON o.order_id = t.order_id

    INNER JOIN raw_customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
)
SELECT
    order_id,
    DATE(purchased_at) AS purchase_date,
    YEAR(purchased_at) AS purchase_year,
    DATE_FORMAT(purchased_at, '%Y-%m') AS purchase_month,
    customer_state,
    1 AS order_count,
    item_count,
    merchandise_value,
    delivery_eligible,

    CASE
        WHEN delivery_eligible = 1
         AND DATE(delivered_at) > DATE(estimated_at)
        THEN 1 ELSE 0
    END AS late_order,

    CASE
        WHEN delivery_eligible = 1
        THEN TIMESTAMPDIFF(
            SECOND, purchased_at, delivered_at
        )
        ELSE 0
    END AS eligible_delivery_seconds

FROM base;

SELECT
    COUNT(*) AS delivered_orders,
    SUM(merchandise_value) AS merchandise_sales_value,
    SUM(delivery_eligible) AS eligible_delivery_orders,
    SUM(late_order) AS late_orders,

    ROUND(
        SUM(eligible_delivery_seconds)
        / NULLIF(SUM(delivery_eligible), 0)
        / 86400.0,
        2
    ) AS avg_delivery_days

FROM ecommerce_analysis.dashboard_orders;

SELECT *
FROM ecommerce_analysis.dashboard_orders
ORDER BY purchase_date, order_id;