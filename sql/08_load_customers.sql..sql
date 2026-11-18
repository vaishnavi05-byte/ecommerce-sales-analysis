-- Import customer data.
-- Run only once, when raw_customers is empty.
-- Copy the CSV into the server's Uploads folder first.

USE ecommerce_analysis;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 26.7/Uploads/olist_customers_dataset.csv'
INTO TABLE raw_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
);

-- Check import warnings before running other queries.
SHOW WARNINGS;

-- Check the imported record count.
SELECT COUNT(*) AS imported_customers
FROM raw_customers;