with salary as(
	select
		offer_id,
		migration_batch_id,
		COALESCE(
			essentials::json->'convertedSalary',
			essentials::json->'originalSalary'
		) as salary,
		created_at
	from{{ ref('stg_nofluffjobs') }}
),
salary_divided as (
	select
		offer_id,
		migration_batch_id,
		salary::json->>'currency' as currency,
		salary::json->'types'->'b2b' as b2b,
		salary::json->'types'->'permanent' as permanent,
		created_at
	from  salary
),
salary_b2b as (
	select
		offer_id,
		migration_batch_id,
		b2b as salary,
		currency,
		created_at
	from salary_divided
	where b2b is not null
		and b2b::json->'range' is not null
),
salary_permanent as (
	select
		offer_id,
		migration_batch_id,
		permanent as salary,
		currency,
		created_at
	from salary_divided
	where permanent is not null
		and permanent::json->'range' is not null
),
salary_all as (
	select *, 'permanent' job_type from salary_permanent
	union all
	select *, 'b2b' job_type from salary_b2b
),
salary_period as (
	select
		offer_id,
		migration_batch_id,
		currency,
		job_type,
		case when lower(salary::json->>'period') = 'hour' then 168
			when lower(salary::json->>'period') = 'year' then 1/12
			else 1
		end as multiplier,
		salary::json->'range'->>0 rate_from ,
		salary::json->'range'->>1  rate_to,
		created_at
	from salary_all
)
select
	offer_id,
	migration_batch_id,
	currency,
	job_type,
	cast(rate_from as numeric)*multiplier as rate_from,
	cast(rate_to as numeric)*multiplier as rate_to,
	created_at
from salary_period