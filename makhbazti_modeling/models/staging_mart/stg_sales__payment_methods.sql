SELECT
    *
from {{ source('public', 'sales__payment_methods') }}