USE ecommerce_analysis;

WITH eligible_orders AS (
    SELECT
        purchased_at,

        CASE
            WHEN DATE(delivered_at) > DATE(estimated_at)
            THEN 1 ELSE 0
        END AS is_late,

        TIMESTAMPDIFF(
            SECOND, purchased_at, delivered_at
        ) / 86400.0 AS delivery_days

    FROM orders_analysis
    WHERE order_status = 'delivered'
      AND purchased_at IS NOT NULL
      AND delivered_at IS NOT NULL
      AND estimated_at IS NOT NULL
      AND delivered_at >= purchased_at
      AND DATE(estimated_at) >= DATE(purchased_at)
)
SELECT
    DATE_FORMAT(purchased_at, '%Y-%m') AS purchase_month,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    ROUND(100.0 * AVG(is_late), 2) AS late_delivery_pct,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days

FROM eligible_orders
GROUP BY DATE_FORMAT(purchased_at, '%Y-%m')
ORDER BY purchase_month;