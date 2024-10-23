{{ config(
    materialized='table',
    schema=generate_schema_name('sales_mart', this)
) }}

select * from {{ ref('stg_time_of_day') }}