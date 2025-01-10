with salary as (
    select *
    from {{ ref('int_salary') }}
),
currency as (
    select
        *
    from {{ ref('stg_currency_rates') }}
),
salary_with_currency_tmp as(
    select
        salary.id,
        salary.source,
        salary.currency,
        salary.rate,
        salary.created_at,
        salary.job_type,
        cr1.rate cur_rate,
        cr1.base,
        cr1.target,
        cr1.created_at cur_created_at
    from salary left join currency as cr1 on (
        (salary.currency=cr1.base or salary.currency=cr1.target)
        and salary.created_at>cr1.created_at
    )
),
salary_with_currency as (
    select
        s1.id,
        s1.source,
        s1.currency,
        s1.rate,
        s1.created_at,
        s1.cur_rate,
        s1.base,
        s1.target,
        s1.cur_created_at,
        s1.job_type
    from salary_with_currency_tmp s1
    where s1.cur_created_at = (select max(cur.created_at) from currency as cur where cur.base=s1.base and cur.target=s1.target)
),
salary_pln as(
	select
			salary.id,
			salary.source,
			salary.job_type,
			case when salary.currency='PLN' then salary.rate
				when salary_with_currency.base='PLN' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='PLN' then salary.rate*salary_with_currency.cur_rate
			end as rate_pln
		from salary left  join salary_with_currency on (
 			salary.id=salary_with_currency.id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='PLN'  and
			(salary_with_currency.target='PLN' or salary_with_currency.base='PLN')
		)
),
salary_eur as(
	select
			salary.id,
			salary.source,
			salary.currency,
			salary_with_currency.cur_rate,
			salary_with_currency.base,
			salary_with_currency.target,
			salary.job_type,
			salary_with_currency.cur_created_at,
			case when salary.currency='EUR' then salary.rate
				when salary_with_currency.base='EUR' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='EUR' then salary.rate*salary_with_currency.cur_rate
			end as rate_eur
		from salary left  join salary_with_currency on (
 			salary.id=salary_with_currency.id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='EUR'  and
			(salary_with_currency.target='EUR' or salary_with_currency.base='EUR')
		)
),
salary_usd as(
	select
			salary.id,
			salary.source,
			salary.job_type,
			case when salary.currency='USD' then salary.rate
				when salary_with_currency.base='USD' then salary.rate/salary_with_currency.cur_rate
				when salary_with_currency.target='USD' then salary.rate*salary_with_currency.cur_rate
			end as rate_usd
		from salary left  join salary_with_currency on (
 			salary.id=salary_with_currency.id and
			salary.source = salary_with_currency.source  and
			salary.job_type = salary_with_currency.job_type  and
			salary.currency!='USD'  and
			(salary_with_currency.target='USD' or salary_with_currency.base='USD')
		)
)
select
    salary_eur.id,
    salary_eur.source,
    salary_eur.job_type,
    salary_eur.rate_eur,
    salary_usd.rate_usd,
    salary_pln.rate_pln
from salary_eur
join salary_usd on salary_usd.id=salary_eur.id and salary_usd.source=salary_eur.source and salary_usd.job_type=salary_eur.job_type
join salary_pln on salary_pln.id=salary_eur.id and salary_pln.source=salary_eur.source and salary_pln.job_type=salary_eur.job_type
order by salary_eur.id