from datetime import datetime, timedelta

from airflow.decorators import task, dag
from airflow.providers.docker.operators.docker import DockerOperator

@task(task_id="introduce_task")
def introduce_task() -> None:
    print("Hello, Airflow! I'm going to start the task of the bus load")

GCP_REGION='australia-southeast1'
GCP_PROJECT_ID='glossy-apex-462002-i3'
GCP_ARTIFACT_REPOSITORY='python-projects'
DOCKER_IMAGE_NAME=f"{GCP_REGION}-docker.pkg.dev/{GCP_PROJECT_ID}/{GCP_ARTIFACT_REPOSITORY}/at-bus-load:latest"


@task.docker(
    task_id="at_bus_load_hello",
    image=DOCKER_IMAGE_NAME,
    # image = f"{GCP_ARTIFACT_REPOSITORY}/at-bus-load:latest",
    entrypoint='uv run python_entrypoint',
    mount_tmp_dir = False
    # docker_conn_id='docker_gcp'
    # auto_remove="force"
)
def say_hello_in_docker_image() -> None:
    pass

@task.docker(
    task_id="at_bus_load_gcs",
    image=DOCKER_IMAGE_NAME,
    # image = f"{GCP_ARTIFACT_REPOSITORY}/at-bus-load:latest",
    entrypoint='uv run check_gcs',
    mount_tmp_dir = False
    # docker_conn_id='docker_gcp'
    # auto_remove="force"
)
def check_gcs() -> None:
    pass

@dag(
    schedule='*/20 * * * *',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["at-bus-load"],
)
def DAG_at_bus_load():
    
    introduce_task() >> say_hello_in_docker_image() >> check_gcs()


DAG_at_bus_load()