CREATE OR REPLACE VIEW portfolio_acquisition.mart_campaign_performance_monthly AS
SELECT
    DATE_TRUNC('month', converted_at)::DATE AS month,
    campaign_name,
    ad_platform,
    COUNT(*) AS conversion_events,
    COUNT(DISTINCT customer_id) AS converting_customers,
    SUM(conversion_value)::NUMERIC(12, 2) AS conversion_revenue
FROM portfolio_acquisition.stg_campaign_conversions
GROUP BY
    DATE_TRUNC('month', converted_at)::DATE,
    campaign_name,
    ad_platform;

CREATE OR REPLACE VIEW portfolio_acquisition.mart_latest_customer_conversion AS
WITH ranked_conversions AS (
    SELECT
        conversion_id,
        customer_id,
        campaign_name,
        ad_platform,
        conversion_value,
        converted_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY converted_at DESC, conversion_id DESC
        ) AS row_num
    FROM portfolio_acquisition.stg_campaign_conversions
)
SELECT
    conversion_id,
    customer_id,
    campaign_name,
    ad_platform,
    conversion_value,
    converted_at
FROM ranked_conversions
WHERE row_num = 1;
