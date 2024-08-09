WITH raw_generated_date AS(
    {{ dbt_date.get_date_dimension("2023-01-01","2029-12-31") }}
),

modified_date AS(
    select 
        rgd.*,
        case
            when month_name = 'January' then 'janvier'
            when month_name = 'February' then 'fevrier'
            when month_name = 'March' then 'mars'
            when month_name = 'April' then 'avril'
            when month_name = 'May' then 'mai'
            when month_name = 'June' then 'juin'
            when month_name = 'July' then 'juillet'
            when month_name = 'August' then 'aout'
            when month_name = 'September' then 'septembre'
            when month_name = 'October' then 'octobre'
            when month_name = 'November' then 'novembre'
            when month_name = 'December' then 'decembre'
        end as month_name_french,
        case
            when month_name_short='Jan' then 'Janv'
            when month_name_short='Feb' then 'Févr'
            when month_name_short='Mar' then 'Mars'
            when month_name_short='Apr' then 'Avril'
            when month_name_short='May' then 'Mai'
            when month_name_short='Jun' then 'Juin'
            when month_name_short='Jul' then 'Juil'
            when month_name_short='Aug' then 'Août'
            when month_name_short='Sep' then 'Sept'
            when month_name_short='Oct' then 'Oct'
            when month_name_short='Nov' then 'Nov'
            when month_name_short='Dec' then 'Déc'
        end as month_name_short_french,
        case
            when day_of_week_name = 'Monday' then 'Lundi'
            when day_of_week_name = 'Tuesday' then 'Mardi'
            when day_of_week_name = 'Wednesday' then 'Mercredi'
            when day_of_week_name = 'Thursday' then 'Jeudi'
            when day_of_week_name = 'Friday' then 'Vendredi'
            when day_of_week_name = 'Saturday' then 'Samedi'
            when day_of_week_name = 'Sunday' then 'Dimanche'
        end as day_of_week_name_french,
        case
            when day_of_week_name_short='Mon' then 'Lun'
            when day_of_week_name_short='Tue' then 'Mar'
            when day_of_week_name_short='Wed' then 'Mer'
            when day_of_week_name_short='Thu' then 'Jeu'
            when day_of_week_name_short='Fri' then 'Ven'
            when day_of_week_name_short='Sat' then 'Sam'
            when day_of_week_name_short='Sun' then 'Dim'
        end as day_of_week_name_short_french
    from raw_generated_date rgd
),

holiday_table AS(
    select
        *
    from {{ ref('Tunisia_Holidays') }}
),

added_holidays AS(
    select
        modified_date.*,
        case
            when modified_date.date_day = holiday_table.date then holiday_table.holiday
            else 'لا توجد مناسبة'
        end as holiday
    from modified_date
    left join holiday_table
    on modified_date.date_day = holiday_table.date
) 

select *,
    extract(year from date_day) * 10000 + extract(month from date_day) *100 + extract(day from date_day) as date_sk from added_holidays