Welcome to your new dbt project!

### Run project

To run project you can use:
    dbt run --select tag:main_project

To run tests:
    dbt test

### Environment Variables

All required environment variables with example values can be found in the .env_template

### Docker

The project is fully containerized with Docker. It can be launched in 4 modes, depending on the environment variable `DBT_ACTION`

    * `run` - launch dbt run
    * `test` - launch tests
    * `report` - create elementary report and send to AWS S3
    * `monitor` - send notification to slack using elementary


### Style and rules
- Models should be pluralized, for example, customers, orders, products.
- Each model should have a primary key.
- The primary key of a model should be named <object>_id, for example, account_id. This makes it easier to know what id is being referenced in downstream joined models.
- Use underscores for naming dbt models; avoid dots.
- Consistency is key! Use the same field names across models where possible. For example, a key to the customers table should be named customer_id rather than user_id or 'id'.
- Booleans should be prefixed with is_
- Timestamp columns should be named <event>_at(for example, created_at)
- Dates should be named <event>_date. For example, created_date.
- Events dates and times should be past tense — created, updated, or deleted.
- Price/revenue fields should be in decimal currency (19.99 for $19.99; many app databases store prices as integers in cents). If a non-decimal currency is used, indicate this with a suffix (price_in_cents).
- Schema, table and column names should be in snake_case.
- Use a consistent ordering of data types and consider grouping and labeling columns by type, as in the example below. We prefer to use the following order: ids, strings, numerics, booleans, dates, and timestamps.

