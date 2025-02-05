with salary_range as (
    select *, 'dev_IT_jobs'  as source from {{ ref('int_devitjobs__salary') }}
        union all
    select *, 'No_Fluff_Jobs' as source from {{ ref('int_nofluffjobs__salary') }}
)
select
    offer_id,
    migration_batch_id,
    (rate_from + COALESCE(rate_to, rate_from)) / 2 as rate,
    currency,
    source,
    job_type,
    created_at
from salary_range