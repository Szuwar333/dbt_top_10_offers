select *, 'dev_IT_jobs' as source from {{ ref('int_devitjobs__requirements') }}
union all
select *, 'No_Fluff_Jobs' as source from {{ ref('int_nofluffjobs__requirements') }}