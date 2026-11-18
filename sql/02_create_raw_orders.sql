USE ecommerce_analysis;

-- Preserve the original CSV values as text.
CREATE TABLE raw_orders (
    order_id VARCHAR(255),
    customer_id VARCHAR(255),
    order_status VARCHAR(255),
    order_purchase_timestamp VARCHAR(255),
    order_approved_at VARCHAR(255),
    order_delivered_carrier_date VARCHAR(255),
    order_delivered_customer_date VARCHAR(255),
    order_estimated_delivery_date VARCHAR(255)
);