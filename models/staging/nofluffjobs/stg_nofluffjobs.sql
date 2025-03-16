select
    ---------- ids
    id as offer_id,
    source_id,
    migration_batch_id,

    ---------- strings
    url,
    name,

    ---------- jsons
    requirements,
    essentials,

    ---------- timestamps
    created_at

from {{ source('raw', 'nofluffjobs_jobs') }}
