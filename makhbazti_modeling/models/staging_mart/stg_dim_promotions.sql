with promotions AS(
    SELECT
        _dlt_id,
        _id,
        name,
        description,
        type,
        value,
        store_id
    from {{ source('public','promotions') }}
),

surrogate AS(
    SELECT
        _dlt_id,
        ROW_NUMBER() OVER(ORDER BY _dlt_id) as promotion_sk
    FROM promotions
)

SELECT
    s.promotion_sk,
    p._id,
    p.name,
    p.type,
    p.value,
    p.description
FROM promotions p join surrogate s
on p._dlt_id=s._dlt_id