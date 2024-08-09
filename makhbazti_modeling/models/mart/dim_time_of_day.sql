{{
    config(
        materialized="table",
        schema="sales_mart",
    )
}}

select * from {{ ref('stg_time_of_day') }}