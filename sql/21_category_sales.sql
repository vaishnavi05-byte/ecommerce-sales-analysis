USE ecommerce_analysis;

WITH category_sales AS (
    SELECT
        COALESCE(
            p.category_label, 'Unknown product'
        ) AS category_label,

        COUNT(*) AS items_sold,

        COUNT(DISTINCT i.order_id)
            AS orders_containing_category,

        SUM(i.item_price) AS merchandise_sales_value

    FROM order_items_analysis AS i

    INNER JOIN orders_analysis AS o
        ON i.order_id = o.order_id

    LEFT JOIN products_analysis AS p
        ON i.product_id = p.product_id

    WHERE o.order_status = 'delivered'

    GROUP BY COALESCE(
        p.category_label, 'Unknown product'
    )
)
SELECT
    DENSE_RANK() OVER (
        ORDER BY merchandise_sales_value DESC
    ) AS sales_rank,

    category_label,
    items_sold,
    orders_containing_category,

    ROUND(
        merchandise_sales_value, 2
    ) AS merchandise_sales_value,

    ROUND(
        100.0 * merchandise_sales_value
        / NULLIF(
            SUM(merchandise_sales_value) OVER (), 0
        ),
        2
    ) AS sales_share_pct

FROM category_sales
ORDER BY merchandise_sales_value DESC, category_label;