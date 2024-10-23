with stores as (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['stores._id']) }} as store_sk,
		_id,
		name,
		type,
		address,
		gouvernorat,
		_dlt_id
	FROM {{ source('public','stores') }}
),

latitude as (
	select 
		c.value as latitude ,
		c._dlt_parent_id
	from {{ source('public','stores__location__coordinates') }} c
	join stores
	on c._dlt_parent_id=stores._dlt_id
	where _dlt_list_idx=0
),

longitude as (
	select 
		c.value as longitude ,
		c._dlt_parent_id
	from {{ source('public','stores__location__coordinates') }} c
	join stores
	on c._dlt_parent_id=stores._dlt_id
	where _dlt_list_idx=1
)

select
	s.*,
	lat.latitude,
	long.longitude
from stores s 
join latitude lat on lat._dlt_parent_id=s._dlt_id
join longitude long on long._dlt_parent_id=s._dlt_id