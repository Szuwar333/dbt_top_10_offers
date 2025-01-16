select
    distinct id,
    requirement,
     migration_batch_id
from {{ ref('stg_devitjobs') }}, jsonb_array_elements_text(requirements) as requirement
