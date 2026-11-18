USE ecommerce_analysis;

SELECT
    COUNT(*) AS total_items,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_id), '') IS NULL
              OR NULLIF(TRIM(order_item_id), '') IS NULL
              OR NULLIF(TRIM(product_id), '') IS NULL
              OR NULLIF(TRIM(seller_id), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS rows_missing_ids

FROM raw_order_items;

WITH amount_checks AS (
    SELECT
        'price' AS amount_field,
        TRIM(price) AS raw_value
    FROM raw_order_items

    UNION ALL

    SELECT
        'freight_value',
        TRIM(freight_value)
    FROM raw_order_items
)
SELECT
    amount_field,
    COUNT(*) AS values_checked,

    SUM(
        CASE
            WHEN NULLIF(raw_value, '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_amounts,

    SUM(
        CASE
            WHEN NULLIF(raw_value, '') IS NOT NULL
                 AND raw_value NOT REGEXP
                 '^[0-9]{1,8}([.][0-9]{1,2})?$'
            THEN 1 ELSE 0
        END
    ) AS unexpected_amount_formats

FROM amount_checks
GROUP BY amount_field;

USE ecommerce_analysis;

SELECT
    COUNT(*) AS items_without_matching_order
FROM raw_order_items AS i

LEFT JOIN orders_analysis AS o
    ON i.order_id = o.order_id

WHERE o.order_id IS NULL;

WITH item_orders AS (
    SELECT DISTINCT order_id
    FROM raw_order_items
)
SELECT
    o.order_status,
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN i.order_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS orders_without_items

FROM orders_analysis AS o

LEFT JOIN item_orders AS i
    ON o.order_id = i.order_id

GROUP BY o.order_status
ORDER BY total_orders DESC;
