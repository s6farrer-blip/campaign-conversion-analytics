DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM portfolio_acquisition.stg_campaign_conversions AS conversions
        LEFT JOIN portfolio_acquisition.dim_customers AS customers
            ON conversions.customer_id = customers.customer_id
        WHERE customers.customer_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Data quality test failed: conversion references an unknown customer';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM portfolio_acquisition.mart_latest_customer_conversion
    ) <> (
        SELECT COUNT(DISTINCT customer_id)
        FROM portfolio_acquisition.stg_campaign_conversions
    ) THEN
        RAISE EXCEPTION 'Data quality test failed: latest-conversion mart does not return one row per active customer';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM portfolio_acquisition.stg_campaign_conversions AS conversions
        JOIN portfolio_acquisition.mart_latest_customer_conversion AS latest
            ON conversions.customer_id = latest.customer_id
        WHERE (conversions.converted_at, conversions.conversion_id)
            > (latest.converted_at, latest.conversion_id)
    ) THEN
        RAISE EXCEPTION 'Data quality test failed: latest-conversion mart omitted a more recent event';
    END IF;

    IF (
        SELECT COALESCE(SUM(conversion_events), 0)
        FROM portfolio_acquisition.mart_campaign_performance_monthly
    ) <> (
        SELECT COUNT(*)
        FROM portfolio_acquisition.stg_campaign_conversions
    ) THEN
        RAISE EXCEPTION 'Data quality test failed: monthly mart does not reconcile to source event count';
    END IF;

    IF (
        SELECT COALESCE(SUM(conversion_revenue), 0)
        FROM portfolio_acquisition.mart_campaign_performance_monthly
    ) <> (
        SELECT COALESCE(SUM(conversion_value), 0)
        FROM portfolio_acquisition.stg_campaign_conversions
    ) THEN
        RAISE EXCEPTION 'Data quality test failed: monthly mart does not reconcile to source revenue';
    END IF;
END;
$$;

SELECT
    'PASS' AS test_status,
    COUNT(*) AS source_conversion_events,
    SUM(conversion_value)::NUMERIC(12, 2) AS source_conversion_revenue
FROM portfolio_acquisition.stg_campaign_conversions;
