with salary as (
    select
        id,
        annual_salary_from,
        annual_salary_to,
        'GBP' as currency,
        created_at,
        migration_batch_id
    from {{ ref('stg_devitjobs') }}
)
select
    id,
    cast(annual_salary_from as numeric)/12 as rate_from,
    cast(annual_salary_to as numeric)/12 as rate_to,
    currency,
    created_at,
    'b2b' job_type,
    migration_batch_id
from salary

