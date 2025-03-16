{{ config(
    materialized='incremental'
) }}

with currency as (
    select
        id,
        base,
        target,
        rate,
        created_at
    from {{ ref('stg_currency_rates') }}
),

migration_batches as (
    select
        migration_batch_id,
        started_at
    from {{ ref('stg_migration_batches') }}
),

migration_batches_with_currency as (
    select
        migration_batches.migration_batch_id,
        cur_1.rate,
        cur_1.base,
        cur_1.target,
        migration_batches.started_at,
        cur_1.created_at as cur_created_at
    from migration_batches
    inner join currency as cur_1
        on cur_1.created_at = (
            select max(cur_2.created_at) as max_created_at
            from currency as cur_2
            where
                cur_2.base = cur_1.base
                and cur_2.target = cur_1.target
                and migration_batches.started_at >= cur_2.created_at
        )
    {% if is_incremental() %}
        where migration_batches.started_at > (
            select max(this_incr.started_at) as max_started_at_incr from {{ this }} as this_incr
        )
    {% endif %}
)

select
    ---------- ids
    migration_batch_id,

    ---------- strings
    base,
    target,

    ---------- numbers
    rate,

    ---------- timestamps
    started_at,
    cur_created_at

from migration_batches_with_currency
