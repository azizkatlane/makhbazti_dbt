with payment_methods AS(
    SELECT
        {{ dbt_utils.generate_surrogate_key(['payment_methods._id']) }} as payment_method_sk,
        _dlt_id,
        _id,
        name,
        description,
        CASE
            WHEN type = 0 THEN 'espece'
            WHEN type = 1 THEN 'carte bancaire'
            WHEN type = 3 THEN 'ticket resto'
            ELSE 'Unknown'
        END AS type
    FROM {{ source('public', 'payment_methods') }}
)


SELECT
    p.payment_method_sk,
    p._id,
    p.name,
    p.type,
    p.description
FROM payment_methods p 