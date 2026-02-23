CREATE PROCEDURE sp_close_account(
p_account_number IN VARCHAR2
)
AS
v_chk_account_exist NUMBER;
v_chk_account_status VARCHAR2(20);
v_chk_account_balance NUMBER;
v_chk_pending_operations NUMBER;
v_chk_account_count NUMBER;
v_user_id NUMBER;

BEGIN

    SELECT COUNT(*), MAX(status), MAX(balance), MAX(user_id) INTO v_chk_account_exist, v_chk_account_status,v_chk_account_balance,v_user_id
    FROM accounts
    WHERE account_number = p_account_number;
    
    IF v_chk_account_exist = 0 THEN RAISE_APPLICATION_ERROR(-20001,'Account with this number not exist!');
    END IF;
    
    IF v_chk_account_status = 'CLOSED' THEN RAISE_APPLICATION_ERROR(-20002,'Account is already closed!');
    END IF;
    
    IF v_chk_account_balance > 0  THEN RAISE_APPLICATION_ERROR(-20003,'Account balance is not 0!');
    END IF;
    
    SELECT COUNT(*) INTO v_chk_pending_operations
    FROM accounts a INNER JOIN payment_transaction pt ON a.account_id = pt.from_account_id OR a.account_id = pt.to_account_id
    WHERE a.account_number = p_account_number AND pt.status = 'PENDING';
    
    IF v_chk_pending_operations > 0  THEN RAISE_APPLICATION_ERROR(-20004,'Account has pending operation!');
    END IF;
    
    UPDATE accounts
    SET status = 'CLOSED', updated_at = SYSDATE
    WHERE account_number = p_account_number;
    
    SELECT COUNT(*) INTO v_chk_account_count
    FROM accounts
    WHERE user_id = v_user_id AND status = 'ACTIVE';
    
    IF v_chk_account_count = 0  THEN 
    UPDATE users
    SET status = 'CLOSED', updated_at = SYSDATE
    WHERE user_id = v_user_id;
    END IF;
    
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE;


END sp_close_account;
/