with requirements_musts as
(
    select
        id,
        requirements::json->'musts' as musts,
        migration_batch_id
    from  {{ ref('stg_nofluffjobs') }}
)
select
    distinct
    rm.id,
    musts.value::json->>'value' as requirement,
    migration_batch_id
from  requirements_musts rm, json_array_elements(musts) as musts