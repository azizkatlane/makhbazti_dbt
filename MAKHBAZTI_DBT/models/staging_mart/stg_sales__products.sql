with sales_joined_to_products_table as(
    select
        s._id,
        s.price,
        s.category,
        s.quantity__unit,
        s._dlt_parent_id,
        s._dlt_list_idx,
        s._dlt_id,
        s.variant_name,
        s.variant,
        CASE
            WHEN p.selling_by_piece is false then ROUND(s.quantity__value / 1000.0, 3)
            ELSE s.quantity__value
        END as quantity__value
    FROM {{ source('public', 'sales__products') }} s
    left join {{ source('public', 'products') }} p on s._id = p._id
)

select
 *
from sales_joined_to_products_table