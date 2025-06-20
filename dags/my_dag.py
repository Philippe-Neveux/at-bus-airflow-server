from datetime import datetime, timedelta

from airflow.decorators import task, dag


@task.bash(task_id="print_hello")
def print_hello() -> str:
    return 'echo "Hello, Airflow!"'

@task.bash(task_id="print_goodbye")
def print_goodbye() -> str:
    return 'echo "Goodbye Airflow!"'


@dag(
    schedule='*/2 * * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["example"],
)
def My_Simple_DAG():

    print_hello()
    print_goodbye()

My_Simple_DAG()
