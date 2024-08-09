{{ config(
    materialized='table',
    schema='sales_mart'
) }}

SELECT
    transaction_id,
    date_sk,
    time_key,
    {{ dbt_utils.generate_surrogate_key(['store_id']) }} as store_key,
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_key,
    product_key,
    {{ dbt_utils.generate_surrogate_key(['payment_method_id']) }} as payment_method_key,
    transaction_amount,
    unit_price,
    quantity,
    product_amount as sales_amount
from {{ref('stg_fact_sales')}}
join {{ref('dim_date')}} on {{ref('stg_fact_sales')}}.date_oftransaction = {{ref('dim_date')}}.date_day
join {{ref('dim_time_of_day')}} on {{ref('stg_fact_sales')}}.time_oftransaction = {{ref('dim_time_of_day')}}.time_value
left join {{ref('dim_employees')}} on {{ref('stg_fact_sales')}}.employee_id = {{ref('dim_employees')}}._id and date_oftransaction >= dbt_valid_from and date_oftransaction < dbt_valid_to
