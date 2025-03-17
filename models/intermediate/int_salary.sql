with salary_range as (
    select
        offer_id,
        migration_batch_id,
        currency,
        job_type,
        rate_from,
        rate_to,
        'dev_IT_jobs' as origin_source,
        created_at
    from {{ ref('int_devitjobs__salary') }}
    union all
    select
        offer_id,
        migration_batch_id,
        currency,
        job_type,
        rate_from,
        rate_to,
        'No_Fluff_Jobs' as origin_source,
        created_at
    from {{ ref('int_nofluffjobs__salary') }}
),

currencies as (
    select
        currency_code,
        currency_name
    from {{ ref('currencies') }}
),

salary as (
    select
        salary_range.offer_id,
        salary_range.migration_batch_id,
        salary_range.currency,
        currencies.currency_name,
        salary_range.origin_source,
        salary_range.job_type,
        salary_range.created_at,
        (salary_range.rate_from + coalesce(salary_range.rate_to, salary_range.rate_from)) / 2 as rate
    from salary_range
    left join currencies on salary_range.currency = currencies.currency_code
)

select
    ---------- ids
    offer_id,
    migration_batch_id,

    ---------- strings
    currency,
    currency_name,
    origin_source,
    job_type,

    ---------- numbers
    rate,

    ---------- timestamps
    created_at

from salary
