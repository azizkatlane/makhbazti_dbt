{{
    config(
        materialized='incremental',
    )
}}


SELECT
    *,
    DATE(created_at) as date_oftransaction,
    TO_TIMESTAMP(TO_CHAR(created_at, 'HH24:MI:SS'), 'HH24:MI:SS')::TIME AS time_oftransaction
FROM
    {{ source('public', 'sales') }}


{% if is_incremental() %}
where created_at > (SELECT max(created_at) FROM {{ this }})
{% endif %}