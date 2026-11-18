USE ecommerce_analysis;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/olist_order_items_dataset.csv'
INTO TABLE raw_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
);

SHOW WARNINGS;

SELECT
    COUNT(*) AS imported_items,
    COUNT(DISTINCT order_id) AS orders_with_items
FROM ecommerce_analysis.raw_order_items;