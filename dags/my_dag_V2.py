from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='My_Simple_DAG_V2',
    default_args=default_args,
    description='A simple example Airflow DAG',
    schedule='*/2 * * * *',  # Runs daily at midnight
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
) as dag:

    task_hello = BashOperator(
        task_id='print_hello',
        bash_command='echo "Hello, Airflow! V2"'
    )

    task_bye = BashOperator(
        task_id='print_bye',
        bash_command='echo "Goodbye, Airflow! V2"'
    )

    task_hello >> task_bye