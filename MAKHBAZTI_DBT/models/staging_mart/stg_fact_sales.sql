with staging_sales as (
    SELECT
        _id as transaction_id,
        store_id,
        employee_id,
        _dlt_id,
        total_price,
        date_oftransaction,
        time_oftransaction,
        created_at
    FROM
        {{ ref('stg_sales') }}
),

staging_sales__products as(
    select
        _id as sales_product_id,
        price,
        quantity__value,
        _dlt_parent_id
    from {{ ref('stg_sales__products') }}
),

/* staging_sales__payment_methods as(
    select
        id as payment_method_id,
        _dlt_parent_id
    from {{ ref('stg_sales__payment_methods') }}
), */

stg_sales_payment_method_products_combined as (
select
    staging_sales.transaction_id,
    staging_sales.date_oftransaction,
    staging_sales.time_oftransaction,
    staging_sales.created_at,
    staging_sales.store_id,
    staging_sales.employee_id,
    staging_sales._dlt_id,
    staging_sales.total_price as transaction_amount,
    staging_sales__products.sales_product_id as product_id,
    staging_sales__products.price as unit_price,
    staging_sales__products.quantity__value as quantity
from staging_sales
left join staging_sales__products
on staging_sales._dlt_id = staging_sales__products._dlt_parent_id
)


SELECT
    transaction_id,
    date_sk,
    time_key,
    combined.created_at,
    {{ dbt_utils.generate_surrogate_key(['combined.store_id']) }} as store_sk,
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_sk,
    product_sk,
    transaction_amount,
    unit_price,
    quantity,
    {{ total_amount('unit_price','quantity') }} as product_amount
FROM stg_sales_payment_method_products_combined as combined
left JOIN {{ ref('stg_date') }}
on combined.date_oftransaction = date_day
left JOIN {{ ref('stg_time_of_day') }}
ON combined.time_oftransaction = time_value
left  JOIN {{ ref('stg_dim_products') }} as products
ON combined.product_id = products.product_id
where combined.created_at >= products.dbt_valid_from and combined.created_at < products.dbt_valid_to
