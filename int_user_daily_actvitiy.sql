SELECT
user_id,
DATE(created_date) AS transaction_date,
ROUND(SUM(amount_usd),2)AS total_amount_usd,
-- 1 & 2: Count valid transactions per customer per day
COUNT(transaction_id) AS total_valid_transactions,

-- 3: Count funding transactions separately (TOPUP + inbound TRANSFER)
COUNT(CASE 
         WHEN transactions_type = 'TOPUP' 
          OR (transactions_type = 'TRANSFER' AND direction = 'INBOUND') 
         THEN transaction_id 
      END) AS funding_transactions_count,
-- 4: Count spending transactions separately (outbound CARD_PAYMENT)
COUNT(CASE 
         WHEN transactions_type = 'CARD_PAYMENT' AND direction = 'OUTBOUND' 
         THEN transaction_id 
      END) AS spending_transactions_count

FROM `neo-bank-project-509212.staging.stg_transactions` 

-- Filter for COMPLETED and the 5 agreed types
WHERE transactions_state = 'COMPLETED'
  AND transactions_type IN ('CARD_PAYMENT', 'TRANSFER', 'TOPUP', 'EXCHANGE', 'ATM')

-- Keep one row per customer per active day
GROUP BY 
    user_id,
    DATE(created_date)

ORDER BY transaction_date ASC;
