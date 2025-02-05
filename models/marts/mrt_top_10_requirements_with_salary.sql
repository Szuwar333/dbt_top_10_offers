with top_10 as (
	select
		*
	from {{ ref('int_requirements_10_most_common') }}
),
req as (
	select * from {{ ref('int_requirements') }}
),
salary as (
	select * from  {{ ref('int_salary_converted_currency') }}
),
top_10_with_salary as (
	select
		top_10.requirement,
		salary.rate_eur,
		salary.rate_usd,
		salary.rate_pln,
		salary.offer_id,
		salary.job_type,
		salary.source
	from top_10
	join req on req.requirement=top_10.requirement
	join salary on req.offer_id=salary.offer_id and salary.source=req.source
)
select
    min(rate_eur) min_rate_eur,
    min(rate_usd) min_rate_usd,
    min(rate_pln) min_rate_pln,
    max(rate_eur) max_rate_eur,
    max(rate_usd) max_rate_usd,
    max(rate_pln) max_rate_pln,
    avg(rate_eur) avg_rate_eur,
    avg(rate_usd) avg_rate_usd,
    avg(rate_pln) avg_rate_pln,
    percentile_cont(0.5) WITHIN GROUP (
            ORDER BY
                rate_eur
        ) AS  median_rate_eur,
    percentile_cont(0.5) WITHIN GROUP (
            ORDER BY
                rate_usd
        ) AS median_rate_usd,
    percentile_cont(0.5) WITHIN GROUP (
            ORDER BY
                rate_pln
        ) AS median_rate_pln,

    count(1),
    requirement
from top_10_with_salary
group by requirement