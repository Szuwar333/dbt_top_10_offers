select
    ---------- ids
    id offer_id,
    source_id,
    migration_batch_id,

    ---------- strings
    url,
    name,
    technologies as requirements,

    ---------- dates
    annual_salary_from,
    annual_salary_to,
    created_at
from {{ source('raw', 'devitjobs_jobs') }}
where tech_category='Data'
