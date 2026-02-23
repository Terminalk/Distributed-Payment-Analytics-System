CREATE OR REPLACE PROCEDURE sp_batch_fail_stuck_transactions(
    p_hours_threshold IN NUMBER,
    p_changed_by      IN VARCHAR2,
    p_processed       OUT NUMBER
) AS
    v_batch_id  NUMBER;
    v_processed NUMBER := 0;
    v_errors    NUMBER := 0;

    CURSOR c_stuck IS
        SELECT transaction_id
        FROM payment_transaction
        WHERE status = 'PENDING'
          AND created_at < SYSTIMESTAMP - (p_hours_threshold / 24.0);

BEGIN
    INSERT INTO batch_process_log (status)
    VALUES ('STARTED')
    RETURNING batch_id INTO v_batch_id;

    FOR rec IN c_stuck LOOP
        BEGIN
            UPDATE payment_transaction
            SET status       = 'FAILED',
                processed_at = SYSTIMESTAMP
            WHERE transaction_id = rec.transaction_id;

            INSERT INTO transaction_audit (transaction_id, old_status, new_status, changed_by)
            VALUES (rec.transaction_id, 'PENDING', 'FAILED', p_changed_by);

            v_processed := v_processed + 1;

        EXCEPTION
            WHEN OTHERS THEN
                v_errors := v_errors + 1;
        END;
    END LOOP;

    UPDATE batch_process_log
    SET status           = 'COMPLETED',
        finished_at      = SYSTIMESTAMP,
        processed_records = v_processed,
        error_count      = v_errors
    WHERE batch_id = v_batch_id;

    p_processed := v_processed;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        UPDATE batch_process_log
        SET status      = 'FAILED',
            finished_at = SYSTIMESTAMP,
            error_count = 1
        WHERE batch_id = v_batch_id;
        COMMIT;
        RAISE;
END sp_batch_fail_stuck_transactions;