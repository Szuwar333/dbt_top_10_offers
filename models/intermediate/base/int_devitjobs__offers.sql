select
    offer_id,
    migration_batch_id,
    source_id,
    url,
    name,
    created_at
from {{ ref('stg_devitjobs') }}
