WITH stores AS(
    SELECT
        {{ dbt_utils.generate_surrogate_key(['stores_snapshot._id']) }} as store_sk,
        _dlt_id,
        _id,
        name,
        address,
        type,
        phone,
        dbt_valid_from,
        CASE
            WHEN dbt_valid_to is NULL THEN cast('9999-12-31 01:00:00+01' as TIMESTAMP)
        end as dbt_valid_to
    FROM {{ source('snapshots', 'stores_snapshot') }}
)



SELECT
    stores.store_sk,
    stores._id,
    stores.name,
    stores.address,
    stores.type,
    stores.dbt_valid_from,
    stores.dbt_valid_to,
    coalesce(stores.phone,'no phone number indicated') as phone
FROM stores  