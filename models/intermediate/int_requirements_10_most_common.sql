with requirements_with_count as (
	select
			requirement,
			count(1) quantity
	from {{ ref('int_requirements') }}
		group by requirement
		order by 2 desc
)
select * from requirements_with_count limit 10