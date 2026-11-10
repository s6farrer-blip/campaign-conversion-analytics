# Campaign Conversion Analytics

A portfolio project demonstrating SQL-first analytics engineering with PostgreSQL. It uses synthetic customer and campaign-conversion data to build tested, reusable models for campaign reporting.

## Business questions

- How do recorded conversion events and conversion value trend by campaign, platform, and month?
- What was each customer's most recently recorded conversion?

## Data and grain

All records are synthetic. The source fixture has two tables:

- `portfolio_acquisition.dim_customers`: one row per customer.
- `portfolio_acquisition.stg_campaign_conversions`: one row per recorded conversion event. A customer can have multiple events.

The campaign and platform fields describe the campaign associated with each recorded conversion. They are not a complete marketing-touch history, so this project does **not** claim causal or multi-touch attribution.

## Models

`portfolio_acquisition.mart_campaign_performance_monthly` aggregates conversion events and value by month, campaign, and platform. It reports both event count and distinct converting customers.

`portfolio_acquisition.mart_latest_customer_conversion` returns one most-recent event per customer. `converted_at` is the primary sort key; `conversion_id` breaks timestamp ties deterministically. This is a latest-event lookup, not a customer's lifetime value or first-touch model.

## Run with PostgreSQL

Run the scripts in order against a development database:

1. `portfolio/01_setup.sql` creates the project schema, tables, and repeatable synthetic fixture.
2. `portfolio/02_models.sql` creates the reporting views.
3. `portfolio/03_data_quality_tests.sql` checks referential integrity and that the aggregate preserves source event counts and revenue.

For example, with `psql` installed and `DATABASE_URL` set to a development database connection:

```shell
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f portfolio/01_setup.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f portfolio/02_models.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f portfolio/03_data_quality_tests.sql
```

In VS Code with SQLTools, connect to a development database, open each script, and run them in the same order. The setup script creates a dedicated `portfolio_acquisition` schema rather than using `public`. Do not run portfolio experiments against a production database.

Example report query:

```sql
SELECT *
FROM portfolio_acquisition.mart_campaign_performance_monthly
ORDER BY month, campaign_name, ad_platform;
```

## Design choices

- **Explicit grain:** a conversion event is not deduplicated merely because its customer has another event.
- **Repeatable setup:** fixture inserts use `ON CONFLICT DO NOTHING`, so rerunning setup does not duplicate rows.
- **Deterministic latest record:** ties on conversion timestamp are resolved with the conversion ID.
- **Data quality:** SQL assertions check customer relationships and reconciliation between source events and the monthly mart.
- **Privacy:** fixtures contain no real customer data, and local editor settings and environment files are excluded from Git.

## Next steps

- Add a dashboard backed by the monthly mart and document the intended audience and decisions it supports.
- Expand the fixture to cover refunds, missing campaign values, and late-arriving events.
- Add dbt project structure and automated CI checks if the project grows beyond these standalone SQL models.
