SELECT
    *
FROM
    {{ source('public', 'sales__products') }}