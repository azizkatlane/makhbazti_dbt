{% snapshot employees_snapshot %}

{{
    config(
        target_schema='snapshots',
        strategy='timestamp',
        unique_key='_id',
        updated_at='updated_at',
        invalidate_hard_deletes=True,    )
}}

SELECT * FROM {{ source('public', 'employees') }}

{% endsnapshot %}