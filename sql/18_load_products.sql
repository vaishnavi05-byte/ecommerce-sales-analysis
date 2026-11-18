USE ecommerce_analysis;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/olist_products_dataset.csv'
INTO TABLE raw_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
);

SHOW WARNINGS;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/product_category_name_translation.csv'
INTO TABLE ecommerce_analysis.raw_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    product_category_name,
    product_category_name_english
);

SHOW WARNINGS;

SELECT
    (SELECT COUNT(*)
     FROM ecommerce_analysis.raw_products)
        AS imported_products,

    (SELECT COUNT(*)
     FROM ecommerce_analysis.raw_category_translation)
        AS imported_translations;
        