USE ecommerce_analysis;

CREATE OR REPLACE VIEW products_analysis AS
SELECT
    TRIM(p.product_id) AS product_id,

    NULLIF(
        TRIM(p.product_category_name), ''
    ) AS original_category,

    CASE
        WHEN NULLIF(
            TRIM(p.product_category_name), ''
        ) IS NULL
            THEN 'Unknown category'

        WHEN NULLIF(
            TRIM(t.product_category_name_english), ''
        ) IS NOT NULL
            THEN TRIM(t.product_category_name_english)

        ELSE CONCAT(
            'Untranslated: ',
            TRIM(p.product_category_name)
        )
    END AS category_label,

    CASE
        WHEN NULLIF(
            TRIM(p.product_category_name), ''
        ) IS NULL
            THEN 'missing_category'

        WHEN NULLIF(
            TRIM(t.product_category_name_english), ''
        ) IS NULL
            THEN 'missing_translation'

        ELSE 'translated'
    END AS category_status

FROM raw_products AS p

LEFT JOIN raw_category_translation AS t
    ON TRIM(p.product_category_name)
       = TRIM(t.product_category_name);
       
SELECT
    COUNT(*) AS delivered_item_rows,

    ROUND(
        SUM(i.item_price), 2
    ) AS merchandise_sales_value

FROM ecommerce_analysis.order_items_analysis AS i

INNER JOIN ecommerce_analysis.orders_analysis AS o
    ON i.order_id = o.order_id

LEFT JOIN ecommerce_analysis.products_analysis AS p
    ON i.product_id = p.product_id

WHERE o.order_status = 'delivered';