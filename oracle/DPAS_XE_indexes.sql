-- payment_transaction

-- Search for outgoing transactions from an account
CREATE INDEX idx_pt_from_account
    ON payment_transaction(from_account_id);

-- Search for incoming transactions to an account
CREATE INDEX idx_pt_to_account
    ON payment_transaction(to_account_id);

-- Used in sp_batch_fail_stuck_transactions
CREATE INDEX idx_pt_status_created
    ON payment_transaction(status, created_at);

-- Used in ETL and anomaly.py: WHERE processed_at >= SYSDATE - N
CREATE INDEX idx_pt_processed_at
    ON payment_transaction(processed_at);

-- Used in sp_close_account
CREATE INDEX idx_pt_from_status
    ON payment_transaction(from_account_id, status);

CREATE INDEX idx_pt_to_status
    ON payment_transaction(to_account_id, status);



-- accounts

-- Used in all procedures: WHERE user_id = ...
CREATE INDEX idx_accounts_user_id
    ON accounts(user_id);

-- Used in anomaly.py: new_account_high_balance
CREATE INDEX idx_accounts_created_at
    ON accounts(created_at);

-- Used in vw_high_risk_users and report_gen.py
CREATE INDEX idx_accounts_status
    ON accounts(status);



-- aml_alert

-- Used in vw_open_alerts_details and fetch_open_alerts
CREATE INDEX idx_aml_status
    ON aml_alert(status);

-- Used in anomaly.py and reporting
CREATE INDEX idx_aml_user_status
    ON aml_alert(user_id, status);

-- Used in queries:
-- WHERE account_id = ...
--   AND alert_type = ...
--   AND TRUNC(created_at) = TRUNC(SYSDATE)
CREATE INDEX idx_aml_account_type_date
    ON aml_alert(account_id, alert_type, created_at);



-- transaction_audit

-- Lookup by transaction_id
CREATE INDEX idx_ta_transaction_id
    ON transaction_audit(transaction_id);



-- daily_account_balance

-- Used in vw_daily_summary_today and fetch_daily_summary
CREATE INDEX idx_dab_balance_date
    ON daily_account_balance(balance_date);



-- users

-- Used in vw_high_risk_users
CREATE INDEX idx_users_risk_score
    ON users(risk_score DESC);

-- Used in sp_block_user_and_account and sp_process_payment
CREATE INDEX idx_users_status
    ON users(status);