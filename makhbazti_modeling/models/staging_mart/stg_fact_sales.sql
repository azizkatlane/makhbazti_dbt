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

staging_sales__payment_methods as(
    select
        id as payment_method_id,
        _dlt_parent_id
    from {{ ref('stg_sales__payment_methods') }}
),

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
    staging_sales__products.sales_product_id,
    staging_sales__products.price as unit_price,
    staging_sales__products.quantity__value as quantity,
    coalesce( staging_sales__payment_methods.payment_method_id,'no payment method indicated') as payment_method_id
from staging_sales
join staging_sales__products
on staging_sales._dlt_id = staging_sales__products._dlt_parent_id
left join staging_sales__payment_methods
on staging_sales._dlt_id = staging_sales__payment_methods._dlt_parent_id )


SELECT
    combined.transaction_id,
    date_oftransaction,
    time_oftransaction,
    combined._dlt_id,
    store_id,
    employee_id,
    transaction_amount,
    {{ dbt_utils.generate_surrogate_key(['products._id','products._dlt_id']) }} as product_key,
    unit_price,
    quantity,
    {{ total_amount('unit_price','quantity') }} as product_amount,
    payment_method_id
FROM stg_sales_payment_method_products_combined as combined
left outer JOIN {{ ref('stg_dim_products') }} as products
ON combined.sales_product_id = products._id
and created_at >= products.dbt_valid_from and created_at < products.dbt_valid_to
