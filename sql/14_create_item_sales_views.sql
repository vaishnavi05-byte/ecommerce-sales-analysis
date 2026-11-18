USE ecommerce_analysis;

-- One row per order item, with numeric money fields.
CREATE OR REPLACE VIEW order_items_analysis AS
SELECT
    TRIM(order_id) AS order_id,
    TRIM(order_item_id) AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,

    CAST(TRIM(price) AS DECIMAL(10,2))
        AS item_price,

    CAST(TRIM(freight_value) AS DECIMAL(10,2))
        AS freight_value

FROM raw_order_items;


-- One row per order, combining its items.
CREATE OR REPLACE VIEW order_item_totals AS
SELECT
    order_id,
    COUNT(*) AS item_count,
    SUM(item_price) AS merchandise_value,
    SUM(freight_value) AS freight_value

FROM order_items_analysis
GROUP BY order_id;

SELECT
    COUNT(*) AS orders_with_items,
    SUM(item_count) AS total_items
FROM ecommerce_analysis.order_item_totals;