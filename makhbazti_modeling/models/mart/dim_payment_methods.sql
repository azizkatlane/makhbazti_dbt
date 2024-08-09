{{ config(
    materialized='table',
    schema='sales_mart'
) }}

SELECT
    *
FROM {{ ref('stg_dim_payment_methods') }}