--  CLEANUP – usuwa dane w odwrotnej kolejności FK
DELETE FROM aml_alert;
DELETE FROM daily_account_balance;
DELETE FROM transaction_audit;
DELETE FROM payment_transaction;
DELETE FROM accounts;
DELETE FROM users;
DELETE FROM batch_process_log;
COMMIT;

--  USERS
INSERT INTO users (user_id, external_id, user_type, status, risk_score)
VALUES (1, 'EXT_CUST_001', 'CUSTOMER', 'ACTIVE', 15.20);

INSERT INTO users (user_id, external_id, user_type, status, risk_score)
VALUES (2, 'EXT_CUST_002', 'CUSTOMER', 'ACTIVE', 42.50);

INSERT INTO users (user_id, external_id, user_type, status, risk_score)
VALUES (3, 'EXT_CUST_003', 'CUSTOMER', 'BLOCKED', 78.90);

INSERT INTO users (user_id, external_id, user_type, status, risk_score)
VALUES (4, 'EXT_MERCH_001', 'MERCHANT', 'ACTIVE', 22.10);

INSERT INTO users (user_id, external_id, user_type, status, risk_score)
VALUES (5, 'EXT_MERCH_002', 'MERCHANT', 'ACTIVE', 65.70);

COMMIT;

--  ACCOUNTS
INSERT INTO accounts (account_id, user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (1, 1, 'US0000000001', 'USD', 12500, 12500, 'ACTIVE', 1);

INSERT INTO accounts (account_id, user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (2, 2, 'US0000000002', 'USD', 8200, 8200, 'ACTIVE', 1);

INSERT INTO accounts (account_id, user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (3, 3, 'US0000000003', 'USD', 1500, 1500, 'ACTIVE', 1);

INSERT INTO accounts (account_id, user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (4, 4, 'US0000000004', 'USD', 0, 0, 'ACTIVE', 1);

INSERT INTO accounts (account_id, user_id, account_number, currency_code, balance, available_balance, status, version_number, created_at)
VALUES (5, 5, 'US0000000005', 'USD', 75000, 75000, 'ACTIVE', 1, SYSDATE);

COMMIT;

--  PAYMENT_TRANSACTION:
INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 10, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 25, 'HIST001', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 12, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 24, 'HIST002', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 8,  'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 23, 'HIST003', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 15, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 22, 'HIST004', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 11, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 21, 'HIST005', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 9,  'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 20, 'HIST006', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 13, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 19, 'HIST007', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 14, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 18, 'HIST008', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 10, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 17, 'HIST009', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 12, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 16, 'HIST010', 1, 'DESKTOP', '192.168.1.1', 'GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (3, 4, 'PAYMENT', 5000, 'USD', 'COMPLETED', 'WEB', 'US', SYSDATE - 1, 'OUTLIER001', 2, 'DESKTOP', '192.168.1.12', 'CRYPTO');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV001', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV002', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV003', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV004', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV005', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV006', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV007', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV008', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV009', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV010', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV011', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV012', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV013', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV014', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV015', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV016', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV017', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV018', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV019', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV020', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV021', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV022', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV023', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV024', 3, 'SERVER', '10.0.0.2', NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount, currency_code, status, channel, country_code, processed_at, reference_id, batch_id, device_type, ip_address, merchant_category)
VALUES (2, 4, 'TRANSFER', 100, 'USD', 'COMPLETED', 'API', 'US', SYSDATE - 1/48, 'HHV025', 3, 'SERVER', '10.0.0.2', NULL);

COMMIT;

--  TRANSACTION_AUDIT
INSERT INTO transaction_audit (transaction_id, old_status, new_status, changed_by)
SELECT transaction_id, 'PENDING', 'COMPLETED', 'SYSTEM_ENGINE'
FROM payment_transaction
WHERE reference_id = 'HIST001';

COMMIT;

--  DAILY_ACCOUNT_BALANCE
INSERT INTO daily_account_balance (account_id, balance_date, opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count)
VALUES (1, TRUNC(SYSDATE), 200000, 80000, 0, 120000, 5);

INSERT INTO daily_account_balance (account_id, balance_date, opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count)
VALUES (2, TRUNC(SYSDATE), 50000, 40000, 0, 10000, 110);

INSERT INTO daily_account_balance (account_id, balance_date, opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count)
VALUES (5, TRUNC(SYSDATE), 0, 75000, 75000, 0, 5);

COMMIT;

--  AML_ALERT
INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value, status, generated_by)
VALUES (2, 2, 'HIGH_VOLUME', 0.92, 10000, 'OPEN', 'PYTHON_ENGINE');

INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value, status, generated_by)
VALUES (1, 1, 'STRUCTURING', 0.88, 10000, 'OPEN', 'PYTHON_ENGINE');

INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value, status, generated_by)
VALUES (2, 2, 'OUTLIER', 0.73, 0.65, 'REVIEWED', 'PYTHON_ENGINE');

COMMIT;

--  BATCH_PROCESS_LOG
INSERT INTO batch_process_log (status, processed_records, error_count)
VALUES ('COMPLETED', 15, 1);

INSERT INTO batch_process_log (status, processed_records, error_count)
VALUES ('COMPLETED', 8, 0);

COMMIT;