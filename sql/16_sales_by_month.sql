USE ecommerce_analysis;

SELECT
    DATE_FORMAT(
        o.purchased_at, '%Y-%m'
    ) AS purchase_month,

    COUNT(*) AS delivered_orders,

    SUM(t.item_count) AS items_sold,

    ROUND(
        SUM(t.merchandise_value), 2
    ) AS merchandise_sales_value,

    ROUND(
        SUM(t.freight_value), 2
    ) AS total_freight_value,

    ROUND(
        AVG(t.merchandise_value), 2
    ) AS average_order_value

FROM orders_analysis AS o

INNER JOIN order_item_totals AS t
    ON o.order_id = t.order_id

WHERE o.order_status = 'delivered'

GROUP BY DATE_FORMAT(o.purchased_at, '%Y-%m')
ORDER BY purchase_month;