'''etl for number of companies in S&P 500 index'''

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow import DAG
from datetime import datetime
import pandas as pd
import sqlite3

with DAG('basic_etl_dag',
         schedule_interval=None,
         start_date=datetime(2025, 1, 1),
         catchup=False) as dag:
    
    extract_task = BashOperator(
        task_id='extract_task',
        bash_command='wget -c https://datahub.io/core/s-and-p-500-companies/r/constituents.csv -O sp500_data.csv'
    )

    def transform_load_data():
        """Count total companies and write to SQLite DB with today's date"""
        today = datetime.today().date().strftime('%Y-%m-%d')
        df = pd.read_csv("sp500_data.csv")
        total_companies = len(df)
        db_path = "airflow-load-db.db"
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
#create table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS sp500_daily_counts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT,
                count INTEGER
            )
        ''')
#insert values into table
        cursor.execute('''
            INSERT OR REPLACE INTO sp500_daily_counts (date, count)
            VALUES (?, ?)
        ''', (today, total_companies))

        conn.commit()
        conn.close()

    transform_load_task = PythonOperator(
        task_id='transform_load_task',
        python_callable=transform_load_data,
        dag=dag
    )

    extract_task >> transform_load_task
