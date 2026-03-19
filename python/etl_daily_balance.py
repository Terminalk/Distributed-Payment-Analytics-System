import pandas as pd
import logging
from datetime import date, timedelta
from db_connector import get_connection
import os

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGS_DIR = os.path.join(PROJECT_ROOT, 'logs')

os.makedirs(LOGS_DIR, exist_ok=True)

logs_format = "%(asctime)s [%(levelname)s] %(message)s"
log_file = os.path.join(LOGS_DIR, 'etl_daily_balance_logs.log')
logging.basicConfig(level=logging.INFO, format=logs_format, filename=log_file, filemode='a')
logger = logging.getLogger(__name__)


def fetch_transactions(conn, target_date: date) -> pd.DataFrame:
    query = """ SELECT from_account_id, to_account_id, amount FROM   payment_transaction WHERE  status = 'COMPLETED' AND  TRUNC(processed_at) = :1 """
    return pd.read_sql(query, conn, params=[target_date])

def aggregate_by_account(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        return pd.DataFrame(columns=['ACCOUNT_ID', 'TOTAL_INCOMING', 'TOTAL_OUTGOING', 'TRANSACTION_COUNT'])

    incoming = (
        df.groupby('TO_ACCOUNT_ID')['AMOUNT']
        .agg(total_incoming='sum', tx_in='count')
        .reset_index()
        .rename(columns={'TO_ACCOUNT_ID': 'ACCOUNT_ID'})
    )
    outgoing = (
        df.groupby('FROM_ACCOUNT_ID')['AMOUNT']
        .agg(total_outgoing='sum', tx_out='count')
        .reset_index()
        .rename(columns={'FROM_ACCOUNT_ID': 'ACCOUNT_ID'})
    )

    merged = pd.merge(incoming, outgoing, on='ACCOUNT_ID', how='outer').fillna(0)
    merged['TRANSACTION_COUNT'] = merged['tx_in'] + merged['tx_out']

    return merged[['ACCOUNT_ID', 'total_incoming', 'total_outgoing', 'TRANSACTION_COUNT']].rename(
        columns={'total_incoming': 'TOTAL_INCOMING', 'total_outgoing': 'TOTAL_OUTGOING'}
    )

def get_opening_balance(conn, account_id: int, target_date: date) -> float:
    prev_date = target_date - timedelta(days=1)

    cursor = conn.cursor()
    cursor.execute("SELECT closing_balance FROM daily_account_balance WHERE account_id = :1 AND balance_date = :2",[account_id, prev_date])
    row = cursor.fetchone()
    cursor.close()

    if row:
        return float(row[0])

    cursor = conn.cursor()
    cursor.execute("SELECT balance FROM accounts WHERE account_id = :1", [account_id])
    row = cursor.fetchone()
    cursor.close()

    return float(row[0]) if row else 0.0

def upsert_daily_balance(conn, account_id: int, target_date: date,
                         opening_balance: float, closing_balance: float,
                         total_incoming: float, total_outgoing: float,
                         transaction_count: int) -> None:
    merge_query = """
        MERGE INTO daily_account_balance dab
        USING (SELECT :1 AS account_id, :2 AS balance_date FROM dual) src
        ON    (dab.account_id = src.account_id AND dab.balance_date = src.balance_date)
        WHEN MATCHED THEN
            UPDATE SET
                opening_balance   = :3,
                closing_balance   = :4,
                total_incoming    = :5,
                total_outgoing    = :6,
                transaction_count = :7
        WHEN NOT MATCHED THEN
            INSERT (account_id, balance_date, opening_balance, closing_balance,
                    total_incoming, total_outgoing, transaction_count)
            VALUES (:8, :9, :10, :11, :12, :13, :14)
    """
    cursor = conn.cursor()
    cursor.execute(merge_query, [
        account_id, target_date,
        opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count,
        account_id, target_date, opening_balance, closing_balance, total_incoming, total_outgoing, transaction_count
    ])
    cursor.close()

def run_etl(target_date: date = None) -> None:
    if target_date is None:
        target_date = date.today() - timedelta(days=1)

    logger.info(f"etl_daily_balance: starting for date={target_date}")

    conn = get_connection()
    processed = 0
    errors = 0

    try:
        df_transactions = fetch_transactions(conn, target_date)

        if df_transactions.empty:
            logger.info(f"etl_daily_balance: no completed transactions found for {target_date}")
            return

        df_aggregated = aggregate_by_account(df_transactions)
        logger.info(f"etl_daily_balance: {len(df_aggregated)} accounts to process")

        for _, row in df_aggregated.iterrows():
            account_id        = int(row['ACCOUNT_ID'])
            total_incoming    = float(row['TOTAL_INCOMING'])
            total_outgoing    = float(row['TOTAL_OUTGOING'])
            transaction_count = int(row['TRANSACTION_COUNT'])

            try:
                opening_balance = get_opening_balance(conn, account_id, target_date)
                closing_balance = opening_balance + total_incoming - total_outgoing

                upsert_daily_balance(
                    conn, account_id, target_date,
                    opening_balance, closing_balance,
                    total_incoming, total_outgoing, transaction_count
                )
                conn.commit()
                processed += 1
                logger.info(
                    f"etl_daily_balance: account_id={account_id}  "
                    f"opening={opening_balance:.2f}  closing={closing_balance:.2f}  "
                    f"in={total_incoming:.2f}  out={total_outgoing:.2f}  tx={transaction_count}"
                )

            except Exception as e:
                conn.rollback()
                errors += 1
                logger.error(f"etl_daily_balance: error for account_id={account_id} — {e}")

    finally:
        conn.close()
        logger.info(f"etl_daily_balance: finished — processed={processed}, errors={errors}")

if __name__ == '__main__':
    run_etl()