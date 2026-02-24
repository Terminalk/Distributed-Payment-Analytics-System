import logging

import pandas as pd
from db_connector import get_connection

logs_format = "%(asctime)s [%(levelname)s] %(message)s"
file = 'logs.log'
logging.basicConfig(level=logging.INFO, format=logs_format,filename= file, filemode='a')
logger = logging.getLogger(__name__)

HIGH_INCOMING = 100000
HIGH_OUTGOING = 100000
HIGH_TX_COUNT = 100
HIGH_HOURLY_TX = 20
RISK_SCORE_INCREMENT = 10
HIGH_NA_BALANCE = 70000

def high_daily_volume(conn):
    logger.info('Searching for high daily volume')

    query = "select ACCOUNT_ID,TOTAL_INCOMING, TOTAL_OUTGOING, TRANSACTION_COUNT from daily_account_balance WHERE balance_date = TRUNC(SYSDATE)"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("high_daily_volume: no data found!")
        return 0

    anomalies = df[ (df["TOTAL_INCOMING"] >= HIGH_INCOMING) | (df["TOTAL_OUTGOING"] >= HIGH_OUTGOING) | (df["TRANSACTION_COUNT"] >= HIGH_TX_COUNT)]

    if anomalies.empty:
        logger.info("high_daily_volume: no anomalies found!")
        return 0
    logger.info(f"high_daily_volume: {len(anomalies)} anomalies found!")

    cursor = conn.cursor()
    update_query = """
                            UPDATE users
                             SET RISK_SCORE = RISK_SCORE + :1 , UPDATED_AT = sysdate
                             WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)"""
    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row["ACCOUNT_ID"])
            try:
                cursor.execute(update_query,[RISK_SCORE_INCREMENT, acc_id])
                conn.commit()
            except Exception as e:
                conn.rollback()
                logger.error("high_daily_volume: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("high_daily_volume: completed analysis!")


def high_daily_hour_volume(conn):
    logger.info('Searching for high daily hour volume')

    query = "select FROM_ACCOUNT_ID, TO_ACCOUNT_ID, PROCESSED_AT from payment_transaction WHERE processed_at >= SYSDATE - 1"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("high_daily_hour_volume: no anomalies found!")
        return 0

    senders = df[['FROM_ACCOUNT_ID','PROCESSED_AT']].rename(columns={'FROM_ACCOUNT_ID':'ACCOUNT_ID'})
    receivers = df[['TO_ACCOUNT_ID','PROCESSED_AT']].rename(columns={'TO_ACCOUNT_ID':'ACCOUNT_ID'})

    all_transactions = pd.concat([senders, receivers])

    all_transactions["HOUR_BUCKET"] = all_transactions["PROCESSED_AT"].dt.to_period('h')

    hourly_counts = all_transactions.groupby(['ACCOUNT_ID','HOUR_BUCKET']).size().reset_index(name='TRANSACTION_COUNT')

    anomalies = hourly_counts[hourly_counts['TRANSACTION_COUNT'] > HIGH_HOURLY_TX]

    if anomalies.empty:
        logger.info("high_daily_hour_volume: no anomalies found!")
        return 0
    logger.info(f"high_daily_hour_volume: {len(anomalies)} anomalies found!")


    cursor = conn.cursor()
    update_query = (""" UPDATE users
                          SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = sysdate
                          WHERE  USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)""")
    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row['ACCOUNT_ID'])

            try:
                cursor.execute(update_query,[RISK_SCORE_INCREMENT, acc_id])
                conn.commit()
                logger.info(f"high_daily_hour_volume: successfully updated risk_score for acc_id={acc_id}!")

            except Exception as e:
                conn.rollback()
                logger.error("high_daily_hour_volume: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("high_daily_hour_volume: completed analysis!")


def new_account_high_balance(conn):
    logger.info('new_account_high_balance: starting analysing')
    query = ''' SELECT USER_ID, BALANCE, ACCOUNT_ID  FROM accounts WHERE CREATED_AT >= TRUNC(sysdate) - 7'''
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("new_account_high_balance: no data found!")
        return 0
    anomalies = df[df['BALANCE'] >= HIGH_NA_BALANCE]
    if anomalies.empty:
        logger.info("new_account_high_balance: no anomalies found!")
        return 0
    logger.info(f"new_account_high_balance: {len(anomalies)} anomalies found!")

    cursor = conn.cursor()
    update_query = """ UPDATE users SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = sysdate WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)"""
    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row['ACCOUNT_ID'])
            try:
                cursor.execute(update_query,[RISK_SCORE_INCREMENT, acc_id])
                conn.commit()
                logger.info(f"new_account_high_balance: successfully updated risk_score for acc_id={acc_id}!")

            except Exception as e:
                conn.rollback()
                logger.error("new_account_high_balance: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("new_account_high_balance: completed analysis!")


def account_outlier(conn):
    logger.info('account_outlier: starting analysing')
    query = "SELECT FROM_ACCOUNT_ID, TO_ACCOUNT_ID, PROCESSED_AT, AMOUNT from payment_transaction WHERE processed_at >= SYSDATE - 30"
    df = pd.read_sql(query, conn)
    if df.empty:
        logger.info("account_outlier: no data found!")
        return 0

    senders = df[["FROM_ACCOUNT_ID","PROCESSED_AT","AMOUNT"]].rename(columns={'FROM_ACCOUNT_ID':'ACCOUNT_ID'})
    receivers = df[["TO_ACCOUNT_ID","PROCESSED_AT","AMOUNT"]].rename(columns={'TO_ACCOUNT_ID':'ACCOUNT_ID'})

    all_transactions = pd.concat([senders, receivers])

    all_transactions['mean'] = (all_transactions.groupby('ACCOUNT_ID')['AMOUNT'].transform('mean'))

    all_transactions['std'] = (all_transactions.groupby('ACCOUNT_ID')['AMOUNT'].transform('std'))

    anomalies = all_transactions[(all_transactions['std'] > 0) & (all_transactions['AMOUNT'] > all_transactions['mean'] + 3 * all_transactions['std'])]

    if anomalies.empty:
        logger.info("account_outlier: no anomalies found!")
        return 0
    logger.info(f"account_outlier: {len(anomalies)} anomalies found!")

    cursor = conn.cursor()
    update_query = """ UPDATE users SET RISK_SCORE = RISK_SCORE + :1, UPDATED_AT = sysdate WHERE USER_ID = (SELECT USER_ID FROM accounts WHERE ACCOUNT_ID = :2)"""

    try:
        for _, row in anomalies.iterrows():
            acc_id = int(row['ACCOUNT_ID'])
            try:
                cursor.execute(update_query,[RISK_SCORE_INCREMENT, acc_id])
                conn.commit()
                logger.info(f"account_outlier:successfully updated risk_score for acc_id={acc_id}!")
            except Exception as e:
                conn.rollback()
                logger.error("account_outlier: rollback for acc_id=%d — %s", acc_id, e)
    finally:
        cursor.close()
        logger.info("account_outlier: completed analysis!")


def anomaly():
    conn = get_connection()
    high_daily_volume(conn)
    high_daily_hour_volume(conn)
    new_account_high_balance(conn)
    account_outlier(conn)
    conn.close()


if __name__ == '__main__':
    anomaly()