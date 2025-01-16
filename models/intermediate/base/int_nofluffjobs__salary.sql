with salary as(
	select
		id,
		COALESCE(
			essentials::json->'convertedSalary',
			essentials::json->'originalSalary'
		) as salary,
		created_at,
		migration_batch_id
	from{{ ref('stg_nofluffjobs') }}
),
salary_divided as (
	select
		id,
		salary::json->>'currency' as currency,
		salary::json->'types'->'b2b' as b2b,
		salary::json->'types'->'permanent' as permanent,
		created_at,
		migration_batch_id
	from  salary
),
salary_b2b as (
	select
		id,
		b2b as salary,
		currency,
		created_at,
		migration_batch_id
	from salary_divided
	where b2b is not null
		and b2b::json->'range' is not null
),
salary_permanent as (
	select
		id,
		permanent as salary,
		currency,
		created_at,
		migration_batch_id
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
		id as id_source,
		salary::json->'range'->>0 rate_from ,
		salary::json->'range'->>1  rate_to,
		case when lower(salary::json->>'period') = 'hour' then 168
			when lower(salary::json->>'period') = 'year' then 1/12
			else 1
		end as multiplier,
		currency,
		created_at,
		job_type,
		migration_batch_id
	from salary_all
)
select
	id_source,
	cast(rate_from as numeric)*multiplier as rate_from,
	cast(rate_to as numeric)*multiplier as rate_to,
	currency,
	created_at,
	job_type,
	migration_batch_id
from salary_period