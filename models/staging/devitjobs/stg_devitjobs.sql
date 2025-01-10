select * from   {{ source('raw', 'devitjobs_jobs') }} where tech_category='Data'
