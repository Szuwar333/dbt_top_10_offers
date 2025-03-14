select
    id,
    base,
    target,
    rate,
    created_at
from {{ source('raw', 'currency_rates') }}