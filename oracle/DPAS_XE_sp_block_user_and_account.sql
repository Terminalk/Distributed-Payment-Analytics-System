CREATE PROCEDURE sp_block_user_and_account(
p_user_id IN NUMBER
)

AS
v_exists NUMBER;
v_status VARCHAR2(10);

BEGIN
    SELECT COUNT(*), MAX(status) INTO v_exists, v_status
    FROM users 
    WHERE user_id = p_user_id;
    
    IF v_exists = 0 THEN RAISE_APPLICATION_ERROR(-20001, 'User '||p_user_id||' not found!');
    END IF;
    
    IF v_status = 'BLOCKED' THEN RAISE_APPLICATION_ERROR(-20002,'User '||p_user_id||' is already blocked!');
    END IF;
    
    UPDATE users
    SET status = 'BLOCKED', updated_at = SYSDATE
    WHERE user_id = p_user_id;
    
    UPDATE accounts
    SET status = 'BLOCKED', updated_at = SYSDATE
    WHERE user_id = p_user_id;
    
    COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK;
        RAISE;

END sp_block_user_and_account;
/