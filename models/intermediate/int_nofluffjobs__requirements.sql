with requirements_musts as
(
    select
        id,
        requirements::json->'musts' as musts
    from  {{ ref('stg_nofluffjobs') }}
)
select
    distinct
    rm.id,
    musts.value::json->>'value' as requirement
from  requirements_musts rm, json_array_elements(musts) as musts