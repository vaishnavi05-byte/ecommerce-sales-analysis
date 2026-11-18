USE ecommerce_analysis;

CREATE TABLE raw_products (
    product_id VARCHAR(32),
    product_category_name VARCHAR(255),
    product_name_lenght VARCHAR(50),
    product_description_lenght VARCHAR(50),
    product_photos_qty VARCHAR(50),
    product_weight_g VARCHAR(50),
    product_length_cm VARCHAR(50),
    product_height_cm VARCHAR(50),
    product_width_cm VARCHAR(50),

    UNIQUE KEY uq_product (product_id)
) DEFAULT CHARACTER SET utf8mb4;


CREATE TABLE raw_category_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255),

    UNIQUE KEY uq_category_name (
        product_category_name
    )
) DEFAULT CHARACTER SET utf8mb4;

SELECT
    (SELECT COUNT(*)
     FROM ecommerce_analysis.raw_products)
        AS existing_products,

    (SELECT COUNT(*)
     FROM ecommerce_analysis.raw_category_translation)
        AS existing_translations;