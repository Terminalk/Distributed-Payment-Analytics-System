CREATE OR REPLACE TRIGGER trg_account_updated_at
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END trg_account_updated_at;
/


CREATE OR REPLACE TRIGGER trg_user_updated_at 
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSDATE;
END trg_user_updated_at;
/


CREATE OR REPLACE TRIGGER trg_block_blocked_user
BEFORE INSERT ON payment_transaction
FOR EACH ROW
DECLARE
    v_user_status VARCHAR2(20);
BEGIN
    SELECT u.status INTO v_user_status
    FROM users u INNER JOIN accounts a ON u.user_id = a.user_id
    WHERE a.account_id = :NEW.from_account_id;

    IF v_user_status = 'BLOCKED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'User is blocked');
    END IF;
END trg_block_blocked_user;
/


CREATE OR REPLACE TRIGGER trg_audit_transaction_status
AFTER UPDATE ON payment_transaction
FOR EACH ROW
BEGIN
    IF :OLD.status != :NEW.status THEN
        INSERT INTO transaction_audit (transaction_id, old_status, new_status, changed_by)
        VALUES (:NEW.transaction_id, :OLD.status, :NEW.status, 
                SYS_CONTEXT('USERENV', 'SESSION_USER'));
    END IF;
END trg_audit_transaction_status;
/


CREATE OR REPLACE TRIGGER trg_check_version_conflict
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF :OLD.version_number != :NEW.version_number - 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Version conflict detected');
    END IF;

    :NEW.version_number := :OLD.version_number + 1;
END trg_check_version_conflict;
/