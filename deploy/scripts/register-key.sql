-- Register adsdnsgo API key in dnsscience.io database
INSERT INTO api_keys (
    user_id,
    key_hash,
    key_prefix,
    name,
    tier,
    is_active,
    rate_limit_per_minute,
    rate_limit_per_day,
    rate_limit_per_hour,
    monthly_quota
)
VALUES (
    1,  -- ryan@afterdarksys.com
    'f9577e02facef6c4c0fdb8814b9aa932fc9bb6624dd6ed865c1fb376879ca688',
    'dns_live_304aa7a...',
    'adsdnsgo - AEIMS Integration',
    'enterprise',
    TRUE,
    1000,
    100000,
    10000,
    NULL  -- unlimited
)
ON CONFLICT (key_hash) DO UPDATE SET
    name = EXCLUDED.name,
    is_active = TRUE,
    rate_limit_per_minute = 1000,
    rate_limit_per_day = 100000
RETURNING id, name, tier, is_active;
