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
salary as(
    select
        offer_id,
        migration_batch_id,
        currency,
        currencies.currency_name as currency_name,
        origin_source,
        job_type,
        (rate_from + COALESCE(rate_to, rate_from)) / 2 as rate,
        created_at
    from salary_range
        left join currencies on currencies.currency_code = salary_range.currency
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

    ---------- dates
    created_at

from salary
