USE ecommerce_analysis;

SELECT
    COUNT(*) AS product_rows_checked,

    COUNT(DISTINCT p.product_id) AS unique_products,

    SUM(
        CASE
            WHEN NULLIF(TRIM(p.product_id), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_product_ids,

    SUM(
        CASE
            WHEN NULLIF(TRIM(p.product_category_name), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS products_missing_category,

    SUM(
        CASE
            WHEN NULLIF(TRIM(p.product_category_name), '') IS NOT NULL
                 AND t.product_category_name IS NULL
            THEN 1 ELSE 0
        END
    ) AS products_without_translation,

    SUM(
        CASE
            WHEN t.product_category_name IS NOT NULL
                 AND NULLIF(
                     TRIM(t.product_category_name_english), ''
                 ) IS NULL
            THEN 1 ELSE 0
        END
    ) AS products_with_blank_english_label

FROM raw_products AS p

LEFT JOIN raw_category_translation AS t
    ON TRIM(p.product_category_name)
       = TRIM(t.product_category_name);
       
       SELECT
    COUNT(*) AS item_rows_checked,

    SUM(
        CASE
            WHEN p.product_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS items_without_product

FROM ecommerce_analysis.order_items_analysis AS i

LEFT JOIN ecommerce_analysis.raw_products AS p
    ON i.product_id = p.product_id;