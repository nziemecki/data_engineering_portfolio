'''transform dag'''
from datetime import datetime, date
from airflow.operators.python import PythonOperator
from airflow import DAG
import pandas as pd


with DAG(dag_id = 'transform_dag',
         schedule_interval=None,
         start_date=datetime(2025, 1, 1),
         catchup=False) as dag:
    
    def transform_data():
        """Read in the file, and write a transformed file out"""
        today = datetime.today().date()
        df = pd.read_csv("orchestrated-extract-data.csv")
        generic_type_df = df[df["Type"]=="generic"]
        generic_type_df["Date"]=today.strftime("%Y-%m-%d")
        generic_type_df.to_csv('orchestrated/airflow-transform-data.csv', index=False)

    transform_task = PythonOperator(
        task_id='transform_task',
        python_callable=transform_data,
        dag=dag
    )