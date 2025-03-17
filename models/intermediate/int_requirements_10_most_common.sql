with requirement as (
    select
        migration_batch_id,
        requirement
    from {{ ref('int_requirements') }}
),

requirements_with_quantity as (
    select
        requirement,
        migration_batch_id,
        count(*) as quantity
    from requirement
    group by requirement, migration_batch_id
),

requirements_with_ranking as (
    select
        requirement,
        migration_batch_id,
        quantity,
        row_number() over (
            partition by migration_batch_id
            order by quantity desc
        ) as ranking_within_batch_id
    from requirements_with_quantity
)

select
    ---------------- ids
    ranking_within_batch_id,
    migration_batch_id,

    ---------------- strings
    requirement,

    ---------------- numbers
    quantity
from
    requirements_with_ranking
where ranking_within_batch_id <= 10
order by
    migration_batch_id desc,
    ranking_within_batch_id asc
