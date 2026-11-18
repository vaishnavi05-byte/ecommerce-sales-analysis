USE ecommerce_analysis;

CREATE OR REPLACE VIEW orders_analysis AS
SELECT
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    LOWER(TRIM(order_status)) AS order_status,

    STR_TO_DATE(
        NULLIF(TRIM(order_purchase_timestamp), ''),
        '%Y-%m-%d %H:%i:%s'
    ) AS purchased_at,

    STR_TO_DATE(
        NULLIF(TRIM(order_delivered_customer_date), ''),
        '%Y-%m-%d %H:%i:%s'
    ) AS delivered_at,

    STR_TO_DATE(
        NULLIF(TRIM(order_estimated_delivery_date), ''),
        '%Y-%m-%d %H:%i:%s'
    ) AS estimated_at

FROM raw_orders;

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE WHEN order_status = 'delivered'
             THEN 1 ELSE 0 END
    ) AS delivered_orders,

    SUM(
        CASE
            WHEN order_status = 'delivered'
                 AND purchased_at IS NOT NULL
                 AND delivered_at IS NOT NULL
                 AND estimated_at IS NOT NULL
                 AND delivered_at >= purchased_at
                 AND DATE(estimated_at) >= DATE(purchased_at)
            THEN 1 ELSE 0
        END
    ) AS eligible_delivery_orders

FROM orders_analysis;