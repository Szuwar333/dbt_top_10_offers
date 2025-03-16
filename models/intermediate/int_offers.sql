with offers as (
    select
        offer_id,
        migration_batch_id,
        source_id,
        url,
        name,
        'dev_IT_jobs' as origin_source,
        created_at
    from {{ ref('int_devitjobs__offers') }}
    union all
    select
        offer_id,
        migration_batch_id,
        source_id,
        url,
        name,
        'No_Fluff_Jobs' as origin_source,
        created_at
    from {{ ref('int_nofluffjobs__offers') }}
)

select
    ---------- ids
    offer_id,
    migration_batch_id,
    source_id,

    ---------- strings
    url,
    name,
    origin_source,

    ---------- timestamps
    created_at

from offers
