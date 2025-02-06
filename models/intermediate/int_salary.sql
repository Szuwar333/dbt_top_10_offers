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
)

select
    ---------- ids
    offer_id,
    migration_batch_id,

    ---------- strings
    currency,
    origin_source,
    job_type,

    ---------- numbers
    (rate_from + COALESCE(rate_to, rate_from)) / 2 as rate,

    ---------- dates
    created_at

from salary_range
