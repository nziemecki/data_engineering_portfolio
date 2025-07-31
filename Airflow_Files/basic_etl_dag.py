'''extract dag'''

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow import DAG
from datetime import datetime
import pandas as pd

with DAG('basic_etl_dag',
         schedule_interval=None,
         start_date=datetime(2025, 1, 1),
         catchup=False) as dag:
    
    extract_task = BashOperator(
        task_id='extract_task',
        bash_command='wget -c https://datahub.io/core/top-level-domain-names/r/top-level-domain-names.csv.csv -O /workspaces/hands-on-introduction-data-engineering-4395021/lab/orchestrated/orchestrated-extract-data.csv'
    )

    def transform_data():
        """Read in the file, and write a transformed file out"""
        today = datetime.today().date()
        df = pd.readx_csv("/workspaces/hands-on-introduction-data-engineering-4395021/lab/orchestrated/orchestrated-extract-data.csv")
        generic_type_df = df[df["Type"]=="generic"]
        generic_type_df["Date"]=today.strftime("%Y-%m-%d")
        generic_type_df.to_csv('/workspaces/hands-on-introduction-data-engineering-4395021/lab/orchestrated/orchestrated-transform-data.csv', index=False)

    transform_task = PythonOperator(
        task_id='transform_task',
        python_callable=transform_data,
        dag=dag
    )

    load_task = BashOperator(
        task_id='load_task',
        bash_command='echo -e ".separator ","\n.import --skip 1 /workspaces/hands-on-introduction-data-engineering-4395021/lab/orchestrated/orchestrated-transform-data.csv top_level_domains" | sqlite3 /workspaces/hands-on-introduction-data-engineering-4395021/lab/orchestrated/airflow-load-db.db',
        dag=dag
    )
    extract_task >> transform_task >> load_task
