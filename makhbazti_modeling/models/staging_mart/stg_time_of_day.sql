with time_range as (
    SELECT generate_series(
            '2024-01-01 00:00:00'::timestamp,
            '2024-01-01 23:59:00'::timestamp,
            '1 second'::interval
        ) as t
)


SELECT
    (extract(hour from t) * 10000 + extract(minute from t) * 100 + extract(second from t))::int as time_key,
    t::time as time_value,
    extract(hour from t) as hour,
    extract(minute from t) as minute,
    extract(second from t)::int as second,
    case
        when extract(hour from t) between 4 and 7 then 'early morning'
        when extract(hour from t) between 8 and 11 then 'late morning'
        when extract(hour from t) between 12 and 15 then 'afternoon'
        when extract(hour from t) between 16 and 19 then 'evening'
        else 'night'
    end as day_time
FROM
    time_range