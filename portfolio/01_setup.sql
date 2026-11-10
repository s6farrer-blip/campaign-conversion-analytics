CREATE SCHEMA IF NOT EXISTS portfolio_acquisition;

CREATE TABLE IF NOT EXISTS portfolio_acquisition.dim_customers (
    customer_id INT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS portfolio_acquisition.stg_campaign_conversions (
    conversion_id INT PRIMARY KEY,
    customer_id INT NOT NULL
        REFERENCES portfolio_acquisition.dim_customers (customer_id),
    campaign_name VARCHAR(100) NOT NULL,
    ad_platform VARCHAR(50) NOT NULL,
    conversion_value NUMERIC(10, 2) NOT NULL
        CHECK (conversion_value >= 0),
    converted_at TIMESTAMP NOT NULL
);

INSERT INTO portfolio_acquisition.dim_customers (customer_id, created_at) VALUES
    (1, '2026-01-10 10:00:00'),
    (2, '2026-01-12 11:30:00'),
    (3, '2026-01-15 09:15:00'),
    (4, '2026-02-02 13:20:00'),
    (5, '2026-02-10 08:45:00')
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO portfolio_acquisition.stg_campaign_conversions (
    conversion_id,
    customer_id,
    campaign_name,
    ad_platform,
    conversion_value,
    converted_at
) VALUES
    (101, 1, 'Spring_Promo', 'Meta', 150.00, '2026-02-01 14:20:00'),
    (102, 1, 'Retargeting', 'Google', 200.00, '2026-02-03 16:45:00'),
    (103, 2, 'Brand_Search', 'Google', 75.50, '2026-02-02 08:10:00'),
    (104, 3, 'Spring_Promo', 'Meta', 300.00, '2026-02-04 12:00:00'),
    (105, 2, 'Spring_Promo', 'Email', 120.00, '2026-03-01 09:30:00'),
    (106, 4, 'Brand_Search', 'Google', 89.99, '2026-03-05 11:05:00'),
    (107, 5, 'Retargeting', 'Meta', 220.00, '2026-03-08 17:15:00'),
    (108, 1, 'Spring_Promo', 'Email', 180.00, '2026-03-12 10:40:00'),
    (109, 3, 'Brand_Search', 'Google', 65.00, '2026-04-02 08:25:00'),
    (110, 4, 'Retargeting', 'Meta', 140.00, '2026-04-07 14:55:00'),
    (111, 5, 'Spring_Promo', 'Email', 95.00, '2026-04-11 12:10:00'),
    (112, 2, 'Brand_Search', 'Google', 210.00, '2026-04-18 15:35:00')
ON CONFLICT (conversion_id) DO NOTHING;
