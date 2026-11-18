USE ecommerce_analysis;

CREATE TABLE raw_customers (
    customer_id VARCHAR(255),
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix VARCHAR(255),
    customer_city VARCHAR(255),
    customer_state VARCHAR(255)
) DEFAULT CHARACTER SET utf8mb4;