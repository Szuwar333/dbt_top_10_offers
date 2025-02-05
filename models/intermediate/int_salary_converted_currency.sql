with salary as (
    select *
    from {{ ref('int_salary') }}
),
currency as (
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
	from migration_batches join currency cur_1 on migration_batches.started_at>cur_1.created_at
	where  cur_1.created_at = (select max(cur_2.created_at) from currency as cur_2 where cur_2.base=cur_1.base and cur_2.target=cur_1.target)
),
salary_with_currency as(
    select
        salary.offer_id,
		salary.migration_batch_id,
        salary.source,
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
			salary.source,
			salary.job_type,
			case when salary.currency='PLN' then salary.rate
				when salary_with_currency.base='PLN' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='PLN' then salary.rate*salary_with_currency.cur_rate
			end as rate_pln,
			salary.migration_batch_id
		from salary
		left join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='PLN'  and
			(salary_with_currency.target='PLN' or salary_with_currency.base='PLN')
		)
),
salary_eur as(
	select
			salary.offer_id,
			salary.migration_batch_id,
			salary.source,
			salary.job_type,
			salary_with_currency.cur_created_at,
			case when salary.currency='EUR' then salary.rate
				when salary_with_currency.base='EUR' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='EUR' then salary.rate*salary_with_currency.cur_rate
			end as rate_eur
		from salary left  join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='EUR'  and
			(salary_with_currency.target='EUR' or salary_with_currency.base='EUR')
		)
),
salary_usd as(
	select
			salary.offer_id,
			salary.migration_batch_id,
			salary.source,
			salary.job_type,
			case when salary.currency='USD' then salary.rate
				when salary_with_currency.base='USD' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='USD' then salary.rate*salary_with_currency.cur_rate
			end as rate_usd
		from salary left  join salary_with_currency on (
 			salary.offer_id=salary_with_currency.offer_id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='USD'  and
			(salary_with_currency.target='USD' or salary_with_currency.base='USD')
		)
)
select
    salary_eur.offer_id,
	salary_eur.migration_batch_id,
    salary_eur.source,
    salary_eur.job_type,
    salary_eur.rate_eur,
    salary_usd.rate_usd,
    salary_pln.rate_pln,
	{{ calc_sum('salary_eur.rate_eur', 'salary_usd.rate_usd') }} as sum_eur_usd
from salary_eur
	join salary_usd on
		salary_usd.offer_id=salary_eur.offer_id and
		salary_usd.source=salary_eur.source and
		salary_usd.job_type=salary_eur.job_type and
		salary_usd.migration_batch_id=salary_eur.migration_batch_id
	join salary_pln on
		salary_pln.offer_id=salary_eur.offer_id and
		salary_pln.source=salary_eur.source and
		salary_pln.job_type=salary_eur.job_type and
		salary_pln.migration_batch_id=salary_eur.migration_batch_id
order by salary_eur.offer_id