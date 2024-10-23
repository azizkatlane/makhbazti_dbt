{{ config(
    materialized='table',
    schema=generate_schema_name('sales_mart', this)
) }}


SELECT
    *
FROM {{ ref('stg_dim_payment_methods') }}