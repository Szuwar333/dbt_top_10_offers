select
    id,
    source_id,
    url,
    name,
    created_at,
    requirements,
    essentials,
    migration_batch_id
from   {{ source('raw', 'nofluffjobs_jobs') }}
