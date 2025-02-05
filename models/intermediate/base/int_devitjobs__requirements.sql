select
    distinct
    offer_id,
    migration_batch_id,
    requirement
from {{ ref('stg_devitjobs') }}, jsonb_array_elements_text(requirements) as requirement
