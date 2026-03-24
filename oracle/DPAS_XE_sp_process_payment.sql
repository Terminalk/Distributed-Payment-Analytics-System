CREATE OR REPLACE PROCEDURE sp_process_payment(
    p_from_account_id  IN  NUMBER,
    p_to_account_id    IN  NUMBER,
    p_amount           IN  NUMBER,
    p_currency_code    IN  CHAR,
    p_transaction_type IN  VARCHAR2,
    p_channel          IN  VARCHAR2,
    p_transaction_id   OUT NUMBER
)
IS
    v_user_id_from          NUMBER;
    v_user_status_from      VARCHAR2(20);
    v_account_status_from   VARCHAR2(20);
    v_currency_from         CHAR(3);
    v_avail_from            NUMBER;

    v_user_id_to            NUMBER;
    v_user_status_to        VARCHAR2(20);
    v_account_status_to     VARCHAR2(20);
    v_currency_to           CHAR(3);

    v_first_id              NUMBER;
    v_second_id             NUMBER;
BEGIN
    v_first_id  := LEAST(p_from_account_id, p_to_account_id);
    v_second_id := GREATEST(p_from_account_id, p_to_account_id);

    SELECT account_id INTO v_user_id_from
    FROM accounts WHERE account_id = v_first_id FOR UPDATE;

    SELECT account_id INTO v_user_id_to
    FROM accounts WHERE account_id = v_second_id FOR UPDATE;

    SELECT status, available_balance, user_id, currency_code
    INTO v_account_status_from, v_avail_from, v_user_id_from, v_currency_from
    FROM accounts
    WHERE account_id = p_from_account_id;

    SELECT status INTO v_user_status_from
    FROM users WHERE user_id = v_user_id_from;

    IF v_user_status_from = 'BLOCKED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sender user is blocked');
    END IF;

    IF v_account_status_from != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Sender account is not active');
    END IF;

    IF v_avail_from < p_amount THEN
        RAISE_APPLICATION_ERROR(-20003, 'Insufficient funds in sender account');
    END IF;

    IF v_currency_from != p_currency_code THEN
        RAISE_APPLICATION_ERROR(-20005,
            'Sender account currency (' || v_currency_from ||
            ') does not match transaction currency (' || p_currency_code || ')');
    END IF;

    SELECT a.status, a.user_id, a.currency_code
    INTO v_account_status_to, v_user_id_to, v_currency_to
    FROM accounts a
    WHERE a.account_id = p_to_account_id;

    SELECT status INTO v_user_status_to
    FROM users WHERE user_id = v_user_id_to;

    IF v_user_status_to = 'BLOCKED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Recipient user is blocked');
    END IF;

    IF v_account_status_to != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Recipient account is not active');
    END IF;

    IF v_currency_to != p_currency_code THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Recipient account currency (' || v_currency_to ||
            ') does not match transaction currency (' || p_currency_code || ')');
    END IF;

    INSERT INTO payment_transaction (
        from_account_id, to_account_id, transaction_type,
        amount, currency_code, status, channel
    ) VALUES (
        p_from_account_id, p_to_account_id, p_transaction_type,
        p_amount, p_currency_code, 'PENDING', p_channel
    ) RETURNING transaction_id INTO p_transaction_id;

    UPDATE accounts
    SET balance           = balance           - p_amount,
        available_balance = available_balance - p_amount,
        version_number    = version_number    + 1,
        updated_at        = SYSDATE
    WHERE account_id = p_from_account_id;

    UPDATE accounts
    SET balance           = balance           + p_amount,
        available_balance = available_balance + p_amount,
        version_number    = version_number    + 1,
        updated_at        = SYSDATE
    WHERE account_id = p_to_account_id;

    UPDATE payment_transaction
    SET status       = 'COMPLETED',
        processed_at = SYSTIMESTAMP
    WHERE transaction_id = p_transaction_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        IF p_transaction_id IS NOT NULL THEN
            UPDATE payment_transaction
            SET status = 'FAILED'
            WHERE transaction_id = p_transaction_id;
            COMMIT;
        END IF;
        RAISE;

END sp_process_payment;
/