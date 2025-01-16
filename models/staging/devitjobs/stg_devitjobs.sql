select
    id,
    source_id,
    url,
    name,
    created_at,
    technologies as requirements,
    annual_salary_from,
    annual_salary_to,
    migration_batch_id
from {{ source('raw', 'devitjobs_jobs') }}
where tech_category='Data'
