with top_10 as (
    select
        migration_batch_id,
        requirement
    from {{ ref('int_requirements_10_most_common') }}
),

req as (
    select
        migration_batch_id,
        offer_id,
        requirement,
        origin_source
    from {{ ref('int_requirements') }}
),

salary as (
    select
        migration_batch_id,
        offer_id,
        rate_eur,
        rate_usd,
        rate_pln,
        job_type,
        origin_source
    from {{ ref('int_salary_converted_currency') }}
),

migration_batches as (
    select
        migration_batch_id,
        started_at as migration_started_at,
        status as migration_status
    from {{ ref('stg_migration_batches') }}
),

top_10_with_salary as (
    select
        req.migration_batch_id,
        top_10.requirement,
        salary.rate_eur,
        salary.rate_usd,
        salary.rate_pln,
        salary.offer_id,
        salary.job_type,
        salary.origin_source
    from top_10
    inner join req
        on
            top_10.requirement = req.requirement
            and top_10.migration_batch_id = req.migration_batch_id
    inner join salary
        on
            req.offer_id = salary.offer_id
            and req.origin_source = salary.origin_source
            and req.migration_batch_id = salary.migration_batch_id

),

top_10_with_salary_with_grouped_rates as (
    select
        migration_batch_id,
        requirement,
        min(rate_eur) as min_rate_eur,
        min(rate_usd) as min_rate_usd,
        min(rate_pln) as min_rate_pln,
        max(rate_eur) as max_rate_eur,
        max(rate_usd) as max_rate_usd,
        max(rate_pln) as max_rate_pln,
        avg(rate_eur) as avg_rate_eur,
        avg(rate_usd) as avg_rate_usd,
        avg(rate_pln) as avg_rate_pln,
        percentile_cont(0.5) within group (
            order by rate_eur
        ) as median_rate_eur,
        percentile_cont(0.5) within group (
            order by rate_usd
        ) as median_rate_usd,
        percentile_cont(0.5) within group (
            order by rate_pln
        ) as median_rate_pln,
        count(*) as row_count
    from top_10_with_salary
    group by
        migration_batch_id,
        requirement
),

top_10_with_salary_with_grouped_rates_and_migration_batches as (
    select
        top_10.migration_batch_id,
        top_10.requirement,
        top_10.min_rate_eur,
        top_10.min_rate_usd,
        top_10.min_rate_pln,
        top_10.max_rate_eur,
        top_10.max_rate_usd,
        top_10.max_rate_pln,
        top_10.avg_rate_eur,
        top_10.avg_rate_usd,
        top_10.avg_rate_pln,
        top_10.median_rate_eur,
        top_10.median_rate_usd,
        top_10.median_rate_pln,
        top_10.row_count,
        migration_batches.migration_started_at,
        migration_batches.migration_status
    from top_10_with_salary_with_grouped_rates as top_10
    inner join migration_batches
        on top_10.migration_batch_id = migration_batches.migration_batch_id
)

select
    ----------------- ids
    migration_batch_id,

    ----------------- strings
    requirement,
    migration_status,

    ----------------- numbers
    min_rate_eur,
    min_rate_usd,
    min_rate_pln,
    max_rate_eur,
    max_rate_usd,
    max_rate_pln,
    avg_rate_eur,
    avg_rate_usd,
    avg_rate_pln,
    median_rate_eur,
    median_rate_usd,
    median_rate_pln,
    row_count,

    ----------------- dates
    migration_started_at

from top_10_with_salary_with_grouped_rates_and_migration_batches
order by
    migration_batch_id asc, row_count desc
