{{ config(
    materialized='table',
    schema='sales_mart'
) }}

SELECT
    *
from {{ ref('stg_date') }}