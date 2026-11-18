USE ecommerce_analysis;

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT order_id) AS unique_order_ids,

    SUM(
        CASE
            WHEN order_id IS NULL OR TRIM(order_id) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_order_ids,

    SUM(
        CASE
            WHEN customer_id IS NULL OR TRIM(customer_id) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_customer_ids

FROM raw_orders;