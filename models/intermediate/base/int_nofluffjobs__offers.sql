select
    id,
    source_id,
    url,
    name,
    created_at,
    migration_batch_id
from {{ ref('stg_nofluffjobs') }}
