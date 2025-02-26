{% macro add_performance_summarize(course) -%}
    {%- if course=="start" %}
        create table if not exists mw_jobs_marts.performance_summarize(
            id serial primary key,
            start_at timestamp default current_timestamp,
            end_at timestamp,
            runtime time,
            migration_batch_id int,
            status varchar(255) default 'active'
        );

        update mw_jobs_marts.performance_summarize set
            end_at = current_timestamp,
            status = 'error'
        where status = 'active';

        insert into mw_jobs_marts.performance_summarize(migration_batch_id)
            select max(id) from mw_jobs.migration_batches;
    {%- elif course=="end" %}
        update mw_jobs_marts.performance_summarize set
            end_at = current_timestamp,
            runtime = current_timestamp - start_at,
            status = 'finished'
        where status = 'active';
    {%- endif %}
    -- alter table demp_mw.mw_jobs_marts.mrt_top_10_requirements_with_salary add column status varchar(255) default 'active';
    -- update demp_mw.mw_jobs_marts.mrt_top_10_requirements_with_salary set status = 'old';
{%- endmacro %}