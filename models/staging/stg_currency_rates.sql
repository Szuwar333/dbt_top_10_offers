select
    ---------- ids
    id,

    ---------- strings
    base,
    target,

    ---------- numbers
    rate,

    ---------- timestamps
    created_at

from {{ source('raw', 'currency_rates') }}
