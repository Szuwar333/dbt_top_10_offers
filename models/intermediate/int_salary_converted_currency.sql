with salary as (
    select *
    from {{ ref('int_salary') }}
),
migration_batches_with_currency as (
	select
		migration_batch_id,
		rate,
		base,
		target,
		started_at,
		cur_created_at
	from {{ ref('int_migration_batches_with_currency') }}
),
salary_with_currency as(
    select
        salary.offer_id,
		salary.migration_batch_id,
        salary.origin_source,
        salary.currency,
        salary.rate,
        salary.job_type,
        migr_cur.rate cur_rate,
        migr_cur.base,
        migr_cur.target,
        salary.created_at,
        migr_cur.cur_created_at
    from salary
	join migration_batches_with_currency migr_cur
		on  migr_cur.migration_batch_id=salary.migration_batch_id
		and (
			salary.currency=migr_cur.base or salary.currency=migr_cur.target
		)
),
salary_pln as(
	select
			salary.offer_id,
			salary.origin_source,
			salary.job_type,
			case when salary.currency='PLN' then salary.rate
				when salary_with_currency.base='PLN' then {{ dbt_utils.safe_divide('salary.rate', 'salary_with_currency.cur_rate ') }}
				when salary_with_currency.target='PLN' then salary.rate*salary_with_currency.cur_rate
			end as rate_pln,
			salary.migration_batch_id
		from salary
		left join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.origin_source = salary_with_currency.origin_source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='PLN'  and
			(salary_with_currency.target='PLN' or salary_with_currency.base='PLN')
		)
),
salary_eur as(
	select
			salary.offer_id,
			salary.migration_batch_id,
			salary.origin_source,
			salary.job_type,
			salary_with_currency.cur_created_at,
			case when salary.currency='EUR' then salary.rate
				when salary_with_currency.base='EUR' then {{ dbt_utils.safe_divide('salary.rate', 'salary_with_currency.cur_rate ') }}
				when salary_with_currency.target='EUR' then salary.rate*salary_with_currency.cur_rate
			end as rate_eur
		from salary left  join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.origin_source = salary_with_currency.origin_source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='EUR'  and
			(salary_with_currency.target='EUR' or salary_with_currency.base='EUR')
		)
),
salary_usd as(
	select
			salary.offer_id,
			salary.migration_batch_id,
			salary.origin_source,
			salary.job_type,
			case when salary.currency='USD' then salary.rate
				when salary_with_currency.base='USD' then {{ dbt_utils.safe_divide('salary.rate', 'salary_with_currency.cur_rate ') }}
				when salary_with_currency.target='USD' then salary.rate*salary_with_currency.cur_rate
			end as rate_usd
		from salary left  join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.origin_source = salary_with_currency.origin_source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='USD'  and
			(salary_with_currency.target='USD' or salary_with_currency.base='USD')
		)
)
select
    salary_eur.offer_id,
	salary_eur.migration_batch_id,
    salary_eur.origin_source,
    salary_eur.job_type,
    salary_eur.rate_eur,
    salary_usd.rate_usd,
    salary_pln.rate_pln
from salary_eur
	join salary_usd on
		salary_usd.offer_id=salary_eur.offer_id and
		salary_usd.origin_source=salary_eur.origin_source and
		salary_usd.job_type=salary_eur.job_type and
		salary_usd.migration_batch_id=salary_eur.migration_batch_id
	join salary_pln on
		salary_pln.offer_id=salary_eur.offer_id and
		salary_pln.origin_source=salary_eur.origin_source and
		salary_pln.job_type=salary_eur.job_type and
		salary_pln.migration_batch_id=salary_eur.migration_batch_id
order by salary_eur.offer_id