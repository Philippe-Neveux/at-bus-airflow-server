from datetime import datetime, timedelta

from airflow.decorators import task, dag


@task(task_id="print_hello")
def python_callable() -> None:
    print("Hello, Airflow!")

@dag(
    schedule='*/2 * * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["example"],
)
def DAG_with_Python():

    python_callable()

DAG_with_Python()