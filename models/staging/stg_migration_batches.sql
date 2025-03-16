select
    ---------- ids
    id as migration_batch_id,

    ---------- strings
    status,
    error_message,

    ---------- numbers
    migrated_records_count,

    ---------- timestamps
    started_at,
    finished_at

from {{ source('raw', 'migration_batches') }}
