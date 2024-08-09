with employees AS(
    SELECT
        {{ dbt_utils.generate_surrogate_key(['employees_snapshot._id']) }} as employee_sk,
        _dlt_id,
        _id,
        name,
        phone,
        role,
        position,
        grade,
        salary,
        points,
        store_id,
        dbt_valid_from,
        CASE
            when dbt_valid_to is NULL then cast('9999-12-31 01:00:00+01' as TIMESTAMP)
            ELSE dbt_valid_to
        end as dbt_valid_to
    FROM {{ ref('employees_snapshot') }}
)

SELECT
    employee_sk,
    _id,
    name,
    phone,
    role,
    coalesce(position,'no position indicated') as position,
    coalesce(grade,0) as grade,
    coalesce(salary,9999) as salary,
    coalesce(points,0) as points,
    dbt_valid_from,
    dbt_valid_to
FROM employees