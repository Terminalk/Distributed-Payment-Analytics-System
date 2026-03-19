CREATE OR REPLACE VIEW vw_high_risk_users AS
    SELECT
        u.user_id,
        u.external_id,
        u.user_type,
        u.status AS user_status,
        u.risk_score,
        a.account_id,
        a.account_number,
        a.currency_code,
        a.balance,
        a.available_balance,
        a.status AS account_status
    FROM users u INNER JOIN accounts a ON u.user_id = a.user_id
    WHERE u.risk_score >= 30
    ORDER BY u.risk_score DESC;
/


CREATE OR REPLACE VIEW vw_open_alerts_details AS
    SELECT
        al.alert_id,
        al.alert_type,
        al.alert_score,
        al.threshold_value,
        al.created_at,
        al.generated_by,
        u.user_id,
        u.external_id,
        u.risk_score,
        a.account_id,
        a.account_number
    FROM aml_alert al INNER JOIN users u ON al.user_id = u.user_id
    INNER JOIN accounts a ON al.account_id = a.account_id
    WHERE al.status = 'OPEN'
    ORDER BY al.alert_score DESC;
/


CREATE OR REPLACE VIEW vw_daily_summary_today AS
    SELECT
        dab.account_id,
        a.account_number,
        a.currency_code,
        dab.opening_balance,
        dab.closing_balance,
        dab.total_incoming,
        dab.total_outgoing,
        dab.transaction_count,
        dab.balance_date
    FROM daily_account_balance dab
    INNER JOIN accounts a ON dab.account_id = a.account_id
    WHERE dab.balance_date = TRUNC(SYSDATE)
    ORDER BY dab.total_incoming + dab.total_outgoing DESC;
/