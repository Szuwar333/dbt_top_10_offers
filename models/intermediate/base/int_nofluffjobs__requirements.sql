with requirements_musts as
(
    select
        offer_id,
        migration_batch_id,
        requirements::json->'musts' as musts
    from  {{ ref('stg_nofluffjobs') }}
)
select
    distinct
    rm.offer_id,
    migration_batch_id,
    musts.value::json->>'value' as requirement
from  requirements_musts rm, json_array_elements(musts) as musts