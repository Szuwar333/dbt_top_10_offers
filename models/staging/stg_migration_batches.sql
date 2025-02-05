select
    id migration_batch_id,
    status,
    error_message,
    migrated_records_count,
    started_at,
    finished_at
from   {{ source('raw', 'migration_batches') }}