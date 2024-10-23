{{ config(
    materialized='table',
    schema=generate_schema_name('sales_mart', this)
) }}

SELECT
    *
from {{ ref('stg_dim_employees') }}