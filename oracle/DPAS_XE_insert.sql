/*users*/
INSERT INTO users (external_id, user_type, status, risk_score)
VALUES ('EXT_CUST_001','CUSTOMER','ACTIVE',15.20);

INSERT INTO users (external_id, user_type, status, risk_score)
VALUES ('EXT_CUST_002','CUSTOMER','ACTIVE',42.50);

INSERT INTO users (external_id, user_type, status, risk_score)
VALUES ('EXT_CUST_003','CUSTOMER','BLOCKED',78.90);

INSERT INTO users (external_id, user_type, status, risk_score)
VALUES ('EXT_MERCH_001','MERCHANT','ACTIVE',22.10);

INSERT INTO users (external_id, user_type, status, risk_score)
VALUES ('EXT_MERCH_002','MERCHANT','ACTIVE',65.70);


/*accounts*/
INSERT INTO accounts (user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (1,'US0000000001','USD',12500,12500,'ACTIVE',1);

INSERT INTO accounts (user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (2,'US0000000002','USD',8200,8200,'ACTIVE',1);

INSERT INTO accounts (user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (3,'US0000000003','USD',1500,1500,'ACTIVE',1);

INSERT INTO accounts (user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (4,'US0000000004','USD',0,0,'ACTIVE',1);

INSERT INTO accounts (user_id, account_number, currency_code, balance, available_balance, status, version_number)
VALUES (5,'US0000000005','USD',0,0,'ACTIVE',1);


/*payment_transaction*/
INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (1,4,'PAYMENT',120.50,'USD','COMPLETED','WEB','US',SYSTIMESTAMP,'REF001',1,'DESKTOP','192.168.1.10','ELECTRONICS');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (2,4,'PAYMENT',80, 'USD','COMPLETED','MOBILE','US', SYSTIMESTAMP,'REF002',1, 'MOBILE','192.168.1.11','GROCERY');

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (1,2,'TRANSFER',500, 'USD','COMPLETED','API','US', SYSTIMESTAMP,'REF003',1, 'SERVER','10.0.0.1',NULL);
 
 INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (3,4,'PAYMENT',200, 'USD','FAILED','WEB','US', 'REF004',1, 'DESKTOP','192.168.1.12','GAMBLING');
 
 INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (2,5,'TRANSFER',25000, 'USD','COMPLETED','API','US', SYSTIMESTAMP,'REF005',2, 'SERVER','10.0.0.5',NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (1,5,'TRANSFER',9900, 'USD','COMPLETED','WEB','US', SYSTIMESTAMP,'REF006',2, 'DESKTOP','192.168.1.15',NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (1,5,'TRANSFER',9900, 'USD','COMPLETED','WEB','US', SYSTIMESTAMP,'REF007',2, 'DESKTOP','192.168.1.15',NULL);

INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
VALUES (1,5,'TRANSFER',9900, 'USD','COMPLETED','WEB','US', SYSTIMESTAMP,'REF008',2, 'DESKTOP','192.168.1.15',NULL);
 
 INSERT INTO payment_transaction (from_account_id, to_account_id, transaction_type, amount,
 currency_code, status, channel, country_code,
 processed_at, reference_id, batch_id,
 device_type, ip_address, merchant_category)
 VALUES (2,4,'PAYMENT',150, 'USD','COMPLETED','MOBILE','NG', SYSTIMESTAMP,'REF009',2, 'UNKNOWN','105.112.23.1','CRYPTO');


/*transaction_audit*/
INSERT INTO transaction_audit (transaction_id, old_status, new_status, changed_by)
VALUES (4,'PENDING','FAILED','SYSTEM_ENGINE');

INSERT INTO transaction_audit (transaction_id, old_status, new_status, changed_by)
VALUES (5,'PENDING','COMPLETED','BATCH_ENGINE');


/*daily_account_balance*/
INSERT INTO daily_account_balance (account_id, balance_date, opening_balance, 
closing_balance, total_incoming, total_outgoing, transaction_count)
VALUES (1,TRUNC(SYSDATE), 12500,8200, 500,14800, 5);

INSERT INTO daily_account_balance (account_id, balance_date,opening_balance, 
closing_balance,total_incoming, total_outgoing,
 transaction_count)
VALUES (2,TRUNC(SYSDATE), 8200,1500, 500,7200, 4);

INSERT INTO daily_account_balance (account_id, balance_date, opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count)
VALUES (5,TRUNC(SYSDATE),0,54700,54700,0,5);


/*aml_alert*/
INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value, status, generated_by)
VALUES (2,2,'HIGH_VOLUME', 0.92,10000,'OPEN','PYTHON_ENGINE');

INSERT INTO aml_alert (user_id, account_id, alert_type,alert_score, threshold_value,status, generated_by)
VALUES (1,1,'STRUCTURING',0.88,10000,'OPEN','PYTHON_ENGINE');

INSERT INTO aml_alert (user_id, account_id, alert_type,alert_score, threshold_value,status, generated_by)
VALUES (2,2,'OUTLIER',0.73,0.65,'REVIEWED','PYTHON_ENGINE');


/*batch_process_log*/
INSERT INTO batch_process_log (status, processed_records, error_count)
VALUES ('COMPLETED', 15, 1);

INSERT INTO batch_process_log (status, processed_records, error_count)
VALUES ('COMPLETED', 8, 0);


