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
    {{ annual_to_month('annual_salary_from') }} as rate_from,
    {{ annual_to_month('annual_salary_to') }} as rate_to,
    created_at
from salary

