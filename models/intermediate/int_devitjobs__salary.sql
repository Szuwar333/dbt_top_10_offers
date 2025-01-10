with salary as (
    select
        id,
        annual_salary_from,
        annual_salary_to,
        currency,
        created_at
    from {{ ref('stg_devitjobs') }}
)
select
    id,
    cast(annual_salary_from as numeric)/12 as rate_from,
    cast(annual_salary_to as numeric)/12 as rate_to,
    currency,
    created_at,
    'b2b' job_type
from salary

