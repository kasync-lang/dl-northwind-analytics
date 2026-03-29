select
    format_date('%F',d) as id,
    d as full_date,
    extract(year from d) as year,
extract(week from d) as year_week,
extract(day from d) as day,
extract(year from d) as fiscal_year,
format_date('%Q', d) as fiscal_quarter,
extract(month from d) as month,
format_date('%B', d) as month_name,
format_date('%W', d) as week_day,
format_date('%A', d) as day_name,
(case when extract(dayofweek from d) in (1,7) then true else false end) as is_weekend,
from(
    select * from
    unnest(generate_date_array('2014-01-01', '2030-12-31', interval 1 day)) as d
    )
