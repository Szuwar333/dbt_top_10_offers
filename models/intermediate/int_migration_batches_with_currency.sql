{{
    config(
        materialized='table'
    )
}}
with currency as (
    select
        *
    from {{ ref('stg_currency_rates') }}
),
migration_batches as (
	select *
	from {{ ref('stg_migration_batches') }}
),
migration_batches_with_currency as (
	select
		migration_batches.migration_batch_id,
		cur_1.rate,
		cur_1.base,
		cur_1.target,
		migration_batches.started_at,
		cur_1.created_at cur_created_at
	from migration_batches join currency cur_1 on  cur_1.created_at = (
	 select max(cur_2.created_at) from currency as cur_2
	 where cur_2.base=cur_1.base
	 and cur_2.target=cur_1.target
	 and migration_batches.started_at>=cur_2.created_at
	)
)
select * from migration_batches_with_currency
