SELECT
    *
from {{ source('public', 'stores__accepted_payment_methods') }}