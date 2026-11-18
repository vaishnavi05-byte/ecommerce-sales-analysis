USE ecommerce_analysis;

-- Define the eligible orders and flag late deliveries.
WITH eligible_orders AS (
    SELECT
        purchased_at,
        delivered_at,

        CASE
            WHEN DATE(delivered_at) > DATE(estimated_at)
            THEN 1 ELSE 0
        END AS is_late

    FROM orders_analysis
    WHERE order_status = 'delivered'
      AND purchased_at IS NOT NULL
      AND delivered_at IS NOT NULL
      AND estimated_at IS NOT NULL
      AND delivered_at >= purchased_at
      AND DATE(estimated_at) >= DATE(purchased_at)
)
SELECT
    COUNT(*) AS eligible_orders,

    SUM(is_late) AS late_orders,

    COUNT(*) - SUM(is_late) AS on_time_orders,

    ROUND(
        100.0 * AVG(is_late), 2
    ) AS late_delivery_pct,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                SECOND, purchased_at, delivered_at
            ) / 86400.0
        ), 2
    ) AS avg_delivery_days

FROM eligible_orders;