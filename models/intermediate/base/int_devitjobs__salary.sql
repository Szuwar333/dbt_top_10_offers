with salary as (
    select
        offer_id,
        migration_batch_id,
        'GBP' as currency,
        annual_salary_from,
        annual_salary_to,
        created_at
    from {{ ref('stg_devitjobs') }}
)
select
    offer_id,
    migration_batch_id,
    currency,
    'b2b' job_type,
    cast(annual_salary_from as numeric)/12 as rate_from,
    cast(annual_salary_to as numeric)/12 as rate_to,
    created_at
from salary

