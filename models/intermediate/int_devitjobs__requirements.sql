select
    distinct id,
    requirement
from {{ ref('stg_devitjobs') }}, jsonb_array_elements_text(requirements) as requirement
