with salary_range as (
    select *, 'dev_IT_jobs'  as source from {{ ref('int_devitjobs__salary') }}
        union all
    select *, 'No_Fluff_Jobs' as source from {{ ref('int_nofluffjobs__salary') }}
)
select
    id,
    (rate_from + rate_to) / 2 as rate,
    currency,
    source,
    created_at,
    job_type,
    migration_batch_id
from salary_range