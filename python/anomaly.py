import logging
import os
import pandas as pd
from db_connector import get_connection

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGS_DIR = os.path.join(PROJECT_ROOT, 'logs')

os.makedirs(LOGS_DIR, exist_ok=True)

logs_format = "%(asctime)s [%(levelname)s] %(message)s"
log_file = os.path.join(LOGS_DIR, 'anomaly_detector_logs.log')
logging.basicConfig(level=logging.INFO, format=logs_format, filename=log_file, filemode='a')
logger = logging.getLogger(__name__)

HIGH_INCOMING = 100000
HIGH_OUTGOING = 100000
HIGH_TX_COUNT = 100
HIGH_HOURLY_TX = 20
RISK_SCORE_INCREMENT = 10
HIGH_NA_BALANCE = 70000
FAN_IN_PATTERN_THRESHOLD = 20


def high_daily_volume(conn):
    logger.info('high_daily_volume: starting analysis')

    query = "SELECT ACCOUNT_ID, TOTAL_INCOMING, TOTAL_OUTGOING, TRANSACTION_COUNT FROM daily_account_balance WHERE balance_date = TRUNC(SYSDATE)"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("high_daily_volume: no data found!")
        return 0

    anomalies = df[
        (df["TOTAL_INCOMING"]    >= HIGH_INCOMING) |
        (df["TOTAL_OUTGOING"]    >= HIGH_OUTGOING) |
        (df["TRANSACTION_COUNT"] >= HIGH_TX_COUNT)
    ]

    if anomalies.empty:
        logger.info("high_daily_volume: no anomalies found!")
        return 0

    logger.info(f"high_daily_volume: {len(anomalies)} anomalies found!")

    update_query = """
        UPDATE users
        SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = SYSDATE
        WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)
    """
    insert_alert_query = """
        INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value)
        SELECT user_id, :1, 'HIGH_VOLUME', :2, :3
        FROM accounts WHERE account_id = :4
    """

    cursor = conn.cursor()
    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row["ACCOUNT_ID"])
            alert_score = max(
                row["TOTAL_INCOMING"]    / HIGH_INCOMING,
                row["TOTAL_OUTGOING"]    / HIGH_OUTGOING,
                row["TRANSACTION_COUNT"] / HIGH_TX_COUNT
            )
            try:
                cursor.execute(update_query, [RISK_SCORE_INCREMENT, acc_id])
                cursor.execute(insert_alert_query, [acc_id, alert_score, HIGH_INCOMING, acc_id])
                conn.commit()
                logger.info(f"high_daily_volume: updated acc_id={acc_id}, alert_score={alert_score:.4f}")
            except Exception as e:
                conn.rollback()
                logger.error("high_daily_volume: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("high_daily_volume: completed analysis!")


def high_daily_hour_volume(conn):
    logger.info('high_daily_hour_volume: starting analysis')

    query = "SELECT FROM_ACCOUNT_ID, TO_ACCOUNT_ID, PROCESSED_AT FROM payment_transaction WHERE processed_at >= SYSDATE - 1"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("high_daily_hour_volume: no data found!")
        return 0

    senders   = df[['FROM_ACCOUNT_ID', 'PROCESSED_AT']].rename(columns={'FROM_ACCOUNT_ID': 'ACCOUNT_ID'})
    receivers = df[['TO_ACCOUNT_ID',   'PROCESSED_AT']].rename(columns={'TO_ACCOUNT_ID':   'ACCOUNT_ID'})
    all_transactions = pd.concat([senders, receivers])

    all_transactions["HOUR_BUCKET"] = all_transactions["PROCESSED_AT"].dt.to_period('h')
    hourly_counts = all_transactions.groupby(['ACCOUNT_ID', 'HOUR_BUCKET']).size().reset_index(name='TRANSACTION_COUNT')

    anomalies = hourly_counts[hourly_counts['TRANSACTION_COUNT'] > HIGH_HOURLY_TX]
    if anomalies.empty:
        logger.info("high_daily_hour_volume: no anomalies found!")
        return 0

    logger.info(f"high_daily_hour_volume: {len(anomalies)} anomalies found!")

    update_query = """
        UPDATE users
        SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = SYSDATE
        WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)
    """
    insert_alert_query = """
        INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value)
        SELECT user_id, :1, 'HIGH_VOLUME', :2, :3
        FROM accounts WHERE account_id = :4
    """

    cursor = conn.cursor()
    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row['ACCOUNT_ID'])
            alert_score = row['TRANSACTION_COUNT'] / HIGH_HOURLY_TX
            try:
                cursor.execute(update_query, [RISK_SCORE_INCREMENT, acc_id])
                cursor.execute(insert_alert_query, [acc_id, alert_score, HIGH_HOURLY_TX, acc_id])
                conn.commit()
                logger.info(f"high_daily_hour_volume: updated acc_id={acc_id}, alert_score={alert_score:.4f}")
            except Exception as e:
                conn.rollback()
                logger.error("high_daily_hour_volume: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("high_daily_hour_volume: completed analysis!")


def new_account_high_balance(conn):
    logger.info('new_account_high_balance: starting analysis')

    query = "SELECT ACCOUNT_ID, USER_ID, BALANCE FROM accounts WHERE CREATED_AT >= TRUNC(SYSDATE) - 7"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("new_account_high_balance: no data found!")
        return 0

    anomalies = df[df['BALANCE'] >= HIGH_NA_BALANCE]
    if anomalies.empty:
        logger.info("new_account_high_balance: no anomalies found!")
        return 0

    logger.info(f"new_account_high_balance: {len(anomalies)} anomalies found!")

    update_query = """
        UPDATE users
        SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = SYSDATE
        WHERE USER_ID = :2
    """
    insert_alert_query = """
        INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value)
        VALUES (:1, :2, 'STRUCTURING', :3, :4)
    """

    cursor = conn.cursor()
    try:
        for _, row in anomalies.iterrows():
            acc_id      = int(row['ACCOUNT_ID'])
            user_id     = int(row['USER_ID'])
            alert_score = row['BALANCE'] / HIGH_NA_BALANCE
            try:
                cursor.execute(update_query, [RISK_SCORE_INCREMENT, user_id])
                cursor.execute(insert_alert_query, [user_id, acc_id, alert_score, HIGH_NA_BALANCE])
                conn.commit()
                logger.info(f"new_account_high_balance: updated acc_id={acc_id}, alert_score={alert_score:.4f}")
            except Exception as e:
                conn.rollback()
                logger.error("new_account_high_balance: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("new_account_high_balance: completed analysis!")


def account_outlier(conn):
    logger.info('account_outlier: starting analysis')

    query = "SELECT FROM_ACCOUNT_ID, TO_ACCOUNT_ID, PROCESSED_AT, AMOUNT FROM payment_transaction WHERE processed_at >= SYSDATE - 30"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("account_outlier: no data found!")
        return 0

    senders   = df[["FROM_ACCOUNT_ID", "PROCESSED_AT", "AMOUNT"]].rename(columns={'FROM_ACCOUNT_ID': 'ACCOUNT_ID'})
    receivers = df[["TO_ACCOUNT_ID",   "PROCESSED_AT", "AMOUNT"]].rename(columns={'TO_ACCOUNT_ID':   'ACCOUNT_ID'})
    all_transactions = pd.concat([senders, receivers])

    all_transactions['mean'] = all_transactions.groupby('ACCOUNT_ID')['AMOUNT'].transform('mean')
    all_transactions['std']  = all_transactions.groupby('ACCOUNT_ID')['AMOUNT'].transform('std')

    anomalies = all_transactions[
        (all_transactions['std'] > 0) &
        (all_transactions['AMOUNT'] > all_transactions['mean'] + 3 * all_transactions['std'])
    ].copy()

    if anomalies.empty:
        logger.info("account_outlier: no anomalies found!")
        return 0

    anomalies['z_score']         = (anomalies['AMOUNT'] - anomalies['mean']) / anomalies['std']
    anomalies['threshold_value'] = anomalies['mean'] + 3 * anomalies['std']

    logger.info(f"account_outlier: {len(anomalies)} anomalies found!")

    update_query = """
        UPDATE users
        SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = SYSDATE
        WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)
    """
    insert_alert_query = """
        INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value)
        SELECT user_id, :1, 'OUTLIER', :2, :3
        FROM accounts WHERE account_id = :4
    """

    cursor = conn.cursor()
    try:
        for _, row in anomalies.iterrows():
            acc_id          = int(row['ACCOUNT_ID'])
            z_score         = float(row['z_score'])
            threshold_value = float(row['threshold_value'])
            try:
                cursor.execute(update_query, [RISK_SCORE_INCREMENT, acc_id])
                cursor.execute(insert_alert_query, [acc_id, z_score, threshold_value, acc_id])
                conn.commit()
                logger.info(f"account_outlier: updated acc_id={acc_id}, z_score={z_score:.4f}")
            except Exception as e:
                conn.rollback()
                logger.error("account_outlier: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("account_outlier: completed analysis!")


def fan_in_pattern(conn):
    logger.info("fan_in_pattern: starting analysis")

    query = """
        SELECT FROM_ACCOUNT_ID, TO_ACCOUNT_ID
        FROM payment_transaction
        WHERE processed_at >= SYSDATE - 1
          AND status = 'COMPLETED'
    """
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("fan_in_pattern: no data found")
        return

    fan_in_counts = (
        df.groupby("TO_ACCOUNT_ID")["FROM_ACCOUNT_ID"]
        .nunique()
        .reset_index()
        .rename(columns={"FROM_ACCOUNT_ID": "unique_senders"})
    )

    anomalies = fan_in_counts[fan_in_counts["unique_senders"] > FAN_IN_PATTERN_THRESHOLD]
    if anomalies.empty:
        logger.info("fan_in_pattern: no anomalies found")
        return

    logger.info(f"fan_in_pattern: {len(anomalies)} anomalies found")

    update_query = """
        UPDATE users
        SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = SYSDATE
        WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)
    """
    insert_alert_query = """
        INSERT INTO aml_alert (user_id, account_id, alert_type, alert_score, threshold_value)
        SELECT user_id, :1, 'HIGH_VOLUME', :2, :3
        FROM accounts WHERE account_id = :4
    """

    cursor = conn.cursor()
    try:
        for _, row in anomalies.iterrows():
            acc_id      = int(row["TO_ACCOUNT_ID"])
            alert_score = float(row["unique_senders"]) / FAN_IN_PATTERN_THRESHOLD
            try:
                cursor.execute(update_query, [RISK_SCORE_INCREMENT, acc_id])
                cursor.execute(insert_alert_query, [acc_id, alert_score, FAN_IN_PATTERN_THRESHOLD, acc_id])
                conn.commit()
                logger.info(f"fan_in_pattern: updated acc_id={acc_id}, unique_senders={int(row['unique_senders'])}")
            except Exception as e:
                conn.rollback()
                logger.error("fan_in_pattern: rollback for account_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("fan_in_pattern: analysis completed")


def anomaly():
    conn = get_connection()
    high_daily_volume(conn)
    high_daily_hour_volume(conn)
    new_account_high_balance(conn)
    account_outlier(conn)
    fan_in_pattern(conn)
    conn.close()


if __name__ == '__main__':
    anomaly()