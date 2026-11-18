USE ecommerce_analysis;

WITH eligible_orders AS (
    SELECT
        UPPER(TRIM(c.customer_state)) AS customer_state,

        CASE
            WHEN DATE(o.delivered_at) > DATE(o.estimated_at)
            THEN 1 ELSE 0
        END AS is_late,

        TIMESTAMPDIFF(
            SECOND, o.purchased_at, o.delivered_at
        ) / 86400.0 AS delivery_days

    FROM orders_analysis AS o

    INNER JOIN raw_customers AS c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.purchased_at IS NOT NULL
      AND o.delivered_at IS NOT NULL
      AND o.estimated_at IS NOT NULL
      AND o.delivered_at >= o.purchased_at
      AND DATE(o.estimated_at) >= DATE(o.purchased_at)
)
SELECT
    customer_state,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * AVG(is_late), 2) AS late_delivery_pct,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days

FROM eligible_orders
GROUP BY customer_state
ORDER BY eligible_orders DESC;