# Distributed Payment & Analytics System

Portfolio project built to demonstrate practical skills in Oracle PL/SQL and Python data engineering.
The system handles payment transaction processing on the database side and AML anomaly detection on the analytics side.

> 🚧 **Work in Progress:** This project is under active development.

---

## Tech Stack

- **Oracle DB** — PL/SQL, procedures, triggers, concurrency control, aggregations
- **Python** — pandas, oracledb, scikit-learn (planned)
- **Logging** — Python `logging` module, append-mode log file
- **Anomaly Detection** — rule-based AML engine (high volume, hourly spikes, fan-in pattern, new account risk, statistical outliers)

---

## 🗄️ Database & Querying

- **Oracle PL/SQL** — stored procedures and database logic designed for payment processing and concurrency control

## 🐍 Analytics & Processing

- **Python** — scripts and modules designed for analyzing transaction data, making use of:
  - `pandas` for data manipulation and tabular analysis
  - `oracledb` for Oracle connectivity and session pooling

---

## 📁 Repository Structure

```
.
├── oracle/      # Oracle PL/SQL code
├── python/      # Python analytics scripts
└── shared/      # Shared modules and utilities
```

---

## anomaly.py

Rule-based AML detection engine. Each rule detects a different fraud pattern, updates `risk_score` in the `users` table and inserts a record into `aml_alert`:

| Rule | Logic |
|---|---|
| `high_daily_volume` | Daily incoming/outgoing > 100 000 or transaction count > 100 |
| `high_daily_hour_volume` | More than 20 transactions in a single hour |
| `new_account_high_balance` | Account younger than 7 days with balance > 70 000 |
| `account_outlier` | Transaction amount > 3 standard deviations above account mean (last 30 days) |
| `fan_in_pattern` | More than 20 unique senders to a single account within 24 hours |

---

## etl_daily_balance.py

ETL script that aggregates completed transactions for a given day and populates the `daily_account_balance` table.

- Calculates `total_incoming`, `total_outgoing`, `transaction_count` per account
- Derives `opening_balance` from the previous day's closing balance (falls back to current `accounts.balance` if no history exists)
- Uses `MERGE INTO` to safely handle reruns for the same date
- Defaults to yesterday; a specific date can be passed via `run_etl(date(...))`

---

## Planned

- `features.py` — feature engineering (rolling averages, hourly entropy, graph features)
- `anomaly_ml.py` — Isolation Forest + LOF models via scikit-learn
- `report_gen.py` — PDF and Excel reports