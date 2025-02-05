select
    id offer_id,
    source_id,
    migration_batch_id,
    url,
    name,
    requirements,
    essentials,
    created_at
from   {{ source('raw', 'nofluffjobs_jobs') }}
