WITH
  Monthly_Aggregates AS (
    -- STEP 1: Roll up daily activity to the monthly level
    -- We pull from the intermediate daily activity table to get core engagement metrics.
    SELECT
      user_id,
      DATE_TRUNC(transaction_date, MONTH) AS activity_month,
      
      -- Count unique days the user was active in this month
      COUNT(DISTINCT transaction_date) AS active_days_in_month,
      
      -- Total volume of transactions
      SUM(total_valid_transactions) AS monthly_transactions,
      
      -- Time span between first and last transaction of the month
      DATE_DIFF(MAX(transaction_date), MIN(transaction_date), DAY) AS days_spanned,
      
      -- Average time between transactions (gap calculation)
      -- SAFE_DIVIDE prevents "divide by zero" crashes if a user only has 1 active day.
      IFNULL(
        SAFE_DIVIDE(
          DATE_DIFF(MAX(transaction_date), MIN(transaction_date), DAY),
          NULLIF(COUNT(DISTINCT transaction_date) - 1, 0)),
        0) AS avg_days_between_tx,
      
      -- Financial totals
      SUM(total_amount_usd) AS monthly_amount_usd,
      SUM(funding_transactions_count) AS monthly_funding_tx,
      SUM(spending_transactions_count) AS monthly_spending_tx
      
    FROM `neo-bank-project-509212.intermediate.int_user_daily_activity`
    GROUP BY 1, 2
  ),

  Feature_Depth AS (
    -- STEP 2: Aggregate feature usage and split Funding vs. Spending amounts
    -- We must go back to the staging layer to look at specific transaction types and directions.
    SELECT
      user_id,
      DATE_TRUNC(transaction_date, MONTH) AS activity_month,
      
      -- How many different types of features did this user touch this month?
      COUNT(DISTINCT transactions_type) AS distinct_features_used,

      -- Calculate inbound money (Funding)
      -- We use a CASE statement to only sum amounts where the direction is INBOUND.
      SUM(CASE WHEN UPPER(direction) = 'INBOUND' THEN amount_usd ELSE 0 END) AS monthly_funding_amount,

      -- Calculate outbound money (Spending)
      -- We use a CASE statement to only sum amounts where the direction is OUTBOUND.
      SUM(CASE WHEN UPPER(direction) = 'OUTBOUND' THEN amount_usd ELSE 0 END) AS monthly_spending_amount,

      -- Create a comma-separated string of the exact features used (great for Looker Studio tooltips)
      STRING_AGG(DISTINCT transactions_type, ', ') AS transactions_types_used

    FROM `neo-bank-project-509212.staging.stg_transactions`
    WHERE transactions_state = 'COMPLETED' -- Only look at successful money movements
      AND transactions_type IN ('CARD_PAYMENT', 'TRANSFER', 'TOPUP', 'EXCHANGE', 'ATM') -- Filter out irrelevant noise
    GROUP BY 1, 2 
    -- Note: We group ONLY by user and month, so the aggregations above apply across all transaction types.
  )

-- STEP 3: Join the tables and calculate final derived KPIs
SELECT
  -- Base Engagement Metrics
  m.user_id,
  m.activity_month,
  m.active_days_in_month,
  m.monthly_transactions,
  m.days_spanned,
  ROUND(m.avg_days_between_tx, 2) AS Avg_days_bet_tx,
  ROUND(m.monthly_amount_usd, 2) AS monthly_amount,
  m.monthly_funding_tx,
  m.monthly_spending_tx,

  -- Financial Amounts (Using IFNULL to replace nulls with 0 if a user had no activity in this category)
  ROUND(IFNULL(f.monthly_funding_amount, 0), 2) AS monthly_funding_amount,
  ROUND(IFNULL(f.monthly_spending_amount, 0), 2) AS monthly_spending_amount,

  -- Feature Segmentation Logic
  IFNULL(f.distinct_features_used, 0) AS distinct_features_used,
  CASE
    -- If they used 2 or more features, they are "Multi-Feature"
    WHEN f.distinct_features_used > 1 THEN 'Multi-Feature'
    -- Otherwise, they are "Single-Feature"
    ELSE 'Single-Feature'
  END AS feature_segment,
  f.transactions_types_used,

  -- Derived KPIs for the Looker Studio Dashboard
  -- Stickiness: What % of the month were they active? (Assuming a 31-day month)
  ROUND(SAFE_DIVIDE(m.active_days_in_month, 31), 2) AS monthly_stickiness_ratio,
  
  -- Intensity: How many transactions do they make on the days they actually open the app?
  ROUND(SAFE_DIVIDE(m.monthly_transactions, m.active_days_in_month), 2) AS avg_tx_per_active_day

FROM Monthly_Aggregates m
-- Left join ensures we keep all users from the base activity table, 
-- even if they somehow didn't have any completed transactions in the staging table.
LEFT JOIN Feature_Depth f
  ON m.user_id = f.user_id
  AND m.activity_month = f.activity_month
WHERE m.activity_month < '2019-05-01' -- Time-bound the dataset (e.g., exclude incomplete future months)
ORDER BY m.user_id, m.activity_month;