SELECT 
    -- 1. Core Identifiers
    user_id,
    
    -- 2. Date Formatting
    -- The source table stores dates as DATETIME (includes hours/minutes).
    -- We cast it to DATE so Looker Studio plots it correctly on a time-series X-axis.
    DATE(activity_month) AS activity_date, 
    
    -- 3. Financial Metric
    -- Rounds the predicted cash flow to 2 decimal places to keep the dashboard clean
    ROUND(net_cash_flow, 2) AS forecasted_net_cash_flow

FROM `neo-bank-project-509212.mart.mart_net_cash_flow_forecast`

-- 4. Data Filtering
-- Restricts the dataset to a specific 3-year window (2018 to 2020) 
-- to prevent incomplete future data from skewing the visual forecast.
WHERE DATE(activity_month) BETWEEN DATE('2018-01-01') AND DATE('2020-12-31')
