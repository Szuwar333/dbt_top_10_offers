with requirement as (
    select *
    from {{ ref('int_requirements') }}
),

requirements_with_quantity as (
    select
        requirement,
        migration_batch_id,
        count(1) as quantity
    from requirement
    group by requirement, migration_batch_id
),

requirements_with_ranking as (
    select
        row_number() over (
            partition by migration_batch_id order by quantity desc
        ) as ranking_within_batch_id,
        requirement,
        migration_batch_id,
        quantity
    from requirements_with_quantity
)

select
    ranking_within_batch_id,
    requirement,
    migration_batch_id,
    quantity
from
    requirements_with_ranking
where ranking_within_batch_id <= 10
order by
    migration_batch_id desc,
    ranking_within_batch_id
