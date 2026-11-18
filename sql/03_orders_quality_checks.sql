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

USE ecommerce_analysis;

-- Check order counts and missing delivery dates by status.
SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN order_delivered_customer_date IS NULL
                 OR TRIM(order_delivered_customer_date) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_delivery_dates
FROM raw_orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Inspect inconsistencies between status and delivery date.
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM raw_orders
WHERE
    (
        order_status = 'delivered'
        AND NULLIF(
            TRIM(order_delivered_customer_date), ''
        ) IS NULL
    )
    OR
    (
        order_status = 'canceled'
        AND NULLIF(
            TRIM(order_delivered_customer_date), ''
        ) IS NOT NULL
    )
ORDER BY order_status, order_id;

USE ecommerce_analysis;

-- Collect the three dates needed for delivery analysis.
WITH date_checks AS (
    SELECT
        'purchase' AS date_field,
        order_purchase_timestamp AS raw_value
    FROM raw_orders

    UNION ALL

    SELECT
        'actual_delivery',
        order_delivered_customer_date
    FROM raw_orders

    UNION ALL

    SELECT
        'estimated_delivery',
        order_estimated_delivery_date
    FROM raw_orders
)
SELECT
    date_field,
    COUNT(*) AS values_checked,

    SUM(
        CASE
            WHEN NULLIF(TRIM(raw_value), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_values,

    SUM(
        CASE
            WHEN NULLIF(TRIM(raw_value), '') IS NOT NULL
                 AND TRIM(raw_value) NOT REGEXP
                 '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
            THEN 1 ELSE 0
        END
    ) AS unexpected_formats

FROM date_checks
GROUP BY date_field
ORDER BY date_field;

USE ecommerce_analysis;

-- Test date conversion without changing the raw table.
WITH parsed_orders AS (
    SELECT
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

    FROM raw_orders
)
SELECT
    COUNT(*) AS total_orders,
    COUNT(purchased_at) AS parsed_purchase_dates,
    COUNT(delivered_at) AS parsed_delivery_dates,
    COUNT(estimated_at) AS parsed_estimated_dates,

    SUM(
        CASE WHEN delivered_at < purchased_at
             THEN 1 ELSE 0 END
    ) AS delivery_before_purchase,

    SUM(
        CASE WHEN DATE(estimated_at) < DATE(purchased_at)
             THEN 1 ELSE 0 END
    ) AS estimate_before_purchase_date

FROM parsed_orders;