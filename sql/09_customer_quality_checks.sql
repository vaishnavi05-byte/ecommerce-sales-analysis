USE ecommerce_analysis;

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT customer_unique_id)
        AS distinct_customers,

    SUM(
        CASE
            WHEN NULLIF(TRIM(customer_id), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_customer_ids,

    SUM(
        CASE
            WHEN NULLIF(TRIM(customer_unique_id), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_unique_ids,

    SUM(
        CASE
            WHEN NULLIF(TRIM(customer_state), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_states

FROM raw_customers;

USE ecommerce_analysis;

SELECT COUNT(*) AS invalid_state_records
FROM raw_customers
WHERE NULLIF(TRIM(customer_state), '') IS NULL
   OR UPPER(TRIM(customer_state)) NOT IN (
       'AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF',
       'ES', 'GO', 'MA', 'MG', 'MS', 'MT', 'PA',
       'PB', 'PE', 'PI', 'PR', 'RJ', 'RN', 'RO',
       'RR', 'RS', 'SC', 'SE', 'SP', 'TO'
   );
   
   SELECT
    COUNT(*) AS joined_rows,

    COUNT(DISTINCT o.order_id) AS unique_orders,

    SUM(
        CASE
            WHEN c.customer_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS orders_without_customer

FROM ecommerce_analysis.orders_analysis AS o

LEFT JOIN ecommerce_analysis.raw_customers AS c
    ON o.customer_id = c.customer_id;