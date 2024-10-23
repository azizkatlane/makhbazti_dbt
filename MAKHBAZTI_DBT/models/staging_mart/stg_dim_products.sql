WITH products_staging as (select
    {{ dbt_utils.generate_surrogate_key(['products_snapshot._id','products_snapshot._dlt_id']) }} as product_sk,
    _id as product_id,
    name,
    selling_by_piece,
    store_id,
    sales_count,
    case
        when category = 0 then 'PainNormal'
        when category = 1 then 'PainSuper'
        when category = 2 then 'Gateaux'
        when category = 3 then 'Sucrier'
        when category = 4 then 'Viennoiserie'
        when category = 5 then 'Sale'
        when category = 6 then 'Oriental'
        when category = 7 then 'Boisson'
        else 'Unknown'
    end as category,
    weight,
    price,
    points,
    _dlt_id,
    dbt_valid_from,
    CASE
        when dbt_valid_to is NULL then cast('9999-12-31 01:00:00+01' as TIMESTAMP)
        ELSE dbt_valid_to
    end as dbt_valid_to
 from {{ ref('products_snapshot') }}

)

select * from products_staging