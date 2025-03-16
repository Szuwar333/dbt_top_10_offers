with salary as (
    select
        offer_id,
        migration_batch_id,
        created_at,
        coalesce(
            essentials::json -> 'convertedSalary',
            essentials::json -> 'originalSalary'
        ) as salary
    from {{ ref('stg_nofluffjobs') }}
),

salary_divided as (
    select
        offer_id,
        migration_batch_id,
        created_at,
        salary::json ->> 'currency' as currency,
        salary::json -> 'types' -> 'b2b' as b2b,
        salary::json -> 'types' -> 'permanent' as permanent
    from salary
),

salary_b2b as (
    select
        offer_id,
        migration_batch_id,
        b2b as salary,
        currency,
        created_at
    from salary_divided
    where
        b2b is not null
        and b2b::json -> 'range' is not null
),

salary_permanent as (
    select
        offer_id,
        migration_batch_id,
        permanent as salary,
        currency,
        created_at
    from salary_divided
    where
        permanent is not null
        and permanent::json -> 'range' is not null
),

salary_all as (
    select
        *,
        'permanent' as job_type
    from salary_permanent
    union all
    select
        *,
        'b2b' as job_type
    from salary_b2b
),

salary_period as (
    select
        offer_id,
        migration_batch_id,
        currency,
        job_type,
        created_at,
        case
            when lower(salary::json ->> 'period') = 'hour' then 168
            when lower(salary::json ->> 'period') = 'year' then 1 / 12
            else 1
        end as multiplier,
        salary::json -> 'range' ->> 0 as rate_from,
        salary::json -> 'range' ->> 1 as rate_to
    from salary_all
),

salary_period_rates_monthly as (
    select
        offer_id,
        migration_batch_id,
        currency,
        job_type,
        created_at,
        (rate_from::numeric) * multiplier as rate_from,
        (rate_to::numeric) * multiplier as rate_to
    from salary_period
)

select
    ---------- ids
    offer_id,
    migration_batch_id,

    ---------- strings
    currency,
    job_type,

    ---------- numbers
    rate_from,
    rate_to,

    ---------- timestamps
    created_at
from salary_period_rates_monthly
