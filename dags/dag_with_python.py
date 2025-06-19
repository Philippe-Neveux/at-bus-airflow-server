from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 10,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='DAG_with_Python',
    default_args=default_args,
    description='A simple example Airflow DAG',
    schedule='*/2 * * * *',  # Runs daily at midnight
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
) as dag:

    task_hello = PythonOperator(
        task_id='print_hello',
        python_callable=lambda: print("Hello, Airflow!")
    )

    task_bye = PythonOperator(
        task_id='print_bye',
        python_callable=lambda: print("Goodbye, Airflow!")
    )

    task_hello >> task_bye