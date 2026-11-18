SELECT 
    -- 1. Core Identifiers
    user_id,
    created_date,
    
    -- 2. Date Formatting & Extraction 
    -- (Used for grouping in BI tools like Looker Studio)
    DATE(created_date) AS transaction_date, -- Strips time for daily grouping
    FORMAT_TIMESTAMP('%B', created_date) AS month, -- e.g., 'January'
    FORMAT_TIMESTAMP('%Y', created_date) AS year, -- e.g., '2019'
    FORMAT_TIMESTAMP('%B %Y', created_date) AS month_yr, -- e.g., 'January 2019'
    
    -- 3. Transaction Details
    transaction_id,
    transactions_type,
    transactions_currency,
    amount_usd,
    
    -- 4. Window Function: Daily Transaction Count
    -- Counts total transactions per user per day WITHOUT collapsing the rows.
    -- (e.g., If a user makes 3 transactions today, this column will show '3' on all 3 rows)
    COUNT(transaction_id) OVER (PARTITION BY user_id, DATE(created_date)) AS daily_transaction_count,
    
    -- 5. Merchant Enrichment
    ea_cardholderpresence,
    ea_merchant_mcc,
    ea_merchant_city,
    
    -- Fixing ISO country code anomaly: 'ROM' is invalid, replacing with 'ROU' (Romania)
    CASE 
        WHEN ea_merchant_country = 'ROM' THEN 'ROU' 
        ELSE ea_merchant_country 
    END AS ea_merchant_country,
    
    -- 6. Transaction State & Direction
    direction, -- Inflow vs Outflow
    transactions_state, -- Completed, Declined, Pending, etc.

FROM `neo-bank-project-509212.raw_data.transactions`

-- 7. Data Cleaning: Filter out "dust" transactions (test or micro-transactions)
WHERE amount_usd > 0.01
