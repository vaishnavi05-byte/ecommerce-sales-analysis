USE ecommerce_analysis;

CREATE TABLE raw_order_items (
    order_id VARCHAR(255),
    order_item_id VARCHAR(255),
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date VARCHAR(255),
    price VARCHAR(255),
    freight_value VARCHAR(255),

    UNIQUE KEY uq_order_item (
        order_id,
        order_item_id
    )
) DEFAULT CHARACTER SET utf8mb4;

