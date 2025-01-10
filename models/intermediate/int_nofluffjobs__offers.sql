select
    id,
    source_id,
    url,
    name,
    created_at
from {{ ref('stg_nofluffjobs') }}
